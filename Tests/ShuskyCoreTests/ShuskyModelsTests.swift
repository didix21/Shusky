//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Files
import Foundation
@testable import ShuskyCore
import XCTest
import Yams

final class ShuskyModelsTests: XCTestCase {
    let preCommit = "pre-commit:"
    let echo = "echo \"print with bash\""
    let path = "./This/path"
    var critical = true
    var verbose = true
    let yamsEncoder = YAMLEncoder()

    func getYamlContent(_ config: String) -> Any {
        guard let yaml = try? Yams.load(yaml: config) else { fatalError() }
        return yaml
    }

    func genHookConfig(_ config: [HookConfigTests]) -> String {
        HookConfigTests.mapToStr(config)
    }

    func genRunConfig(_ config: [RunConfigTests]) -> String {
        RunConfigTests.mapToStr(config)
    }

    func testRunCommand() throws {
        let config = """
        command: swift run shusky install
        """
        let run = try YAMLDecoder().decode(Run.self, from: config)
        XCTAssertEqual(run, Run(command: "swift run shusky install"))
    }

    func testRunInvalidDataInPath() throws {
        let config = """
        command: swift run shusky install
        path: true
        """
        do {
            _ = try YAMLDecoder().decode(Run.self, from: config)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch:
                break
            default:
                XCTFail("Expected DecodingError.typeMismatch but got \(error)")
            }
        }
    }

    func testRunPath() throws {
        let config = """
        command: swift run shusky install
        path: ./my/path
        """
        let run = try YAMLDecoder().decode(Run.self, from: config)
        XCTAssertEqual(run, Run(command: "swift run shusky install", path: "./my/path"))
    }

    func testRunCritical() throws {
        let config = """
        command: swift run shusky install
        critical: false
        """
        let run = try YAMLDecoder().decode(Run.self, from: config)
        XCTAssertEqual(run, Run(command: "swift run shusky install", critical: false))
    }

    func testRunVerbose() throws {
        let config = """
        command: swift run shusky install
        verbose: true
        """
        let run = try YAMLDecoder().decode(Run.self, from: config)
        XCTAssertEqual(run, Run(command: "swift run shusky install", verbose: true))
    }

    func testRunWithInvalidTypeCommand() throws {
        let config = genRunConfig([.command(true)])
        do {
            let json = try JSONSerialization.data(withJSONObject: getYamlContent(config))
            _ = try JSONDecoder().decode(Command.self, from: json)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testRunWithCommandDefined() throws {
        let config = genRunConfig([.command(echo)])
        let command = Command(run: Run(command: echo))
        let actualCommand = try YAMLDecoder().decode(Command.self, from: config)
        XCTAssertEqual(actualCommand, command)
    }

    func testRunWithCommandPathCriticalDefined() throws {
        let config = genRunConfig([.command(echo), .path(path), .critical(critical)])
        let command = Command(run: Run(command: echo, path: path, critical: critical))
        let actualCommand = try YAMLDecoder().decode(Command.self, from: config)
        XCTAssertEqual(actualCommand, command)
    }

    func testRunWithCommandPathCriticalVerboseDefined() throws {
        let config = genRunConfig([.command(echo), .path(path), .critical(critical), .verbose(verbose)])
        let command = Command(run: Run(command: echo, path: path, critical: critical, verbose: verbose))
        let actualCommand = try YAMLDecoder().decode(Command.self, from: config)
        XCTAssertEqual(actualCommand, command)
    }

    func testInvalidCommandInHook() throws {
        let config = """
        pre-commit:
           - echo print this command
           - run:
               command: true
        """
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        do {
            _ = try Hook.parse(hookType: .preCommit, data)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch:
                break
            default:
                XCTFail("Expected DecodingError.typeMismatch but got \(error)")
            }
        }
    }

    func testHookNotFound() throws {
        let config = """
        pre-commit:
           - echo print this command
        """
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        assert(try Hook.parse(hookType: .prePush, data), throws: Hook.HookError.noHookFound)
    }

    func testHookIsEmpty() throws {
        let config = """
        pre-push:
        pre-commit:
           - echo print this command
        """
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        assert(try Hook.parse(hookType: .prePush, data), throws: Hook.HookError.hookIsEmpty(.prePush))
    }

    func testInvalidRunInHook() throws {
        let config = """
        pre-push:
           - run:
        """
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        assert(
            try Hook.parse(hookType: .prePush, data),
            throws: Hook.HookError.invalidCommand(.prePush, .invalidRun)
        )
    }

    func testInvalidTypeInHookVerboseKey() throws {
        let config = """
        verbose: Invalid type
        pre-commit:
           - echo print this command
        """
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        assert(
            try Hook.parse(hookType: .preCommit, data),
            throws: Hook.HookError.invalidTypeInHookKey(.verbose, "Invalid type")
        )
    }

    func testIfVerboseIsNotDefinedIsSetTrueByDefault() throws {
        let config = """
        pre-commit:
           - run:
               command: echo run example
               verbose: true
           - echo print this please
        """
        let expectedHook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [
                Command(run: Run(command: "echo run example", verbose: true)),
                Command(run: Run(command: "echo print this please")),
            ]
        )
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        XCTAssertEqual(try Hook.parse(hookType: .preCommit, data), expectedHook)
    }

    func testValidHook() throws {
        let config = """
        verbose: false
        pre-commit:
           - run:
               command: echo run example
               verbose: true
           - echo print this please
        """
        let expectedHook = Hook(
            hookType: .preCommit,
            verbose: false,
            commands: [
                Command(run: Run(command: "echo run example", verbose: true)),
                Command(run: Run(command: "echo print this please")),
            ]
        )
        let yml = try Yams.load(yaml: config)
        guard let data = yml as? [String: Any] else { return XCTFail(" Is not a dict ") }
        XCTAssertEqual(try Hook.parse(hookType: .preCommit, data), expectedHook)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }
}
