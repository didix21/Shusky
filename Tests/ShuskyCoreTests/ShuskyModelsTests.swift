//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Files
import Foundation
@testable import ShuskyCore
import XCTest
import Yams

// swiftlint:disable type_body_length
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

    func testRunInvalidCommand() throws {
        let config = """
        bubu jfklsd
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        assert(try Run.parse(yml), throws: Run.RunError.invalidData("bubu jfklsd"))
    }

    func testRunInvalidDataInCommand() throws {
        let config = """
        command: true
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        assert(try Run.parse(yml), throws: Run.RunError.invalidTypeInRunKey(.command, "true"))
    }

    func testRunCommand() throws {
        let config = """
        command: swift run shusky install
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        let run = try Run.parse(yml)
        XCTAssertEqual(run, Run(command: "swift run shusky install"))
    }

    func testRunInvalidDataInPath() throws {
        let config = """
        command: swift run shusky install
        path: true
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        assert(try Run.parse(yml), throws: Run.RunError.invalidTypeInRunKey(.path, "true"))
    }

    func testRunPath() throws {
        let config = """
        command: swift run shusky install
        path: ./my/path
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        let run = try Run.parse(yml)
        XCTAssertEqual(run, Run(command: "swift run shusky install", path: "./my/path"))
    }

    func testRunInvalidDataInCritical() throws {
        let config = """
        command: swift run shusky install
        critical: Invalid data
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        assert(try Run.parse(yml), throws: Run.RunError.invalidTypeInRunKey(.critical, "Invalid data"))
    }

    func testRunCritical() throws {
        let config = """
        command: swift run shusky install
        critical: false
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        let run = try Run.parse(yml)
        XCTAssertEqual(run, Run(command: "swift run shusky install", critical: false))
    }

    func testRunInvalidDataInVerbose() throws {
        let config = """
        command: swift run shusky install
        verbose: Invalid data
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        assert(try Run.parse(yml), throws: Run.RunError.invalidTypeInRunKey(.verbose, "Invalid data"))
    }

    func testRunVerbose() throws {
        let config = """
        command: swift run shusky install
        verbose: true
        """
        guard let yml = try Yams.load(yaml: config) else { return XCTFail("Can not parse yaml file") }
        let run = try Run.parse(yml)
        XCTAssertEqual(run, Run(command: "swift run shusky install", verbose: true))
    }

    func testInvalidCommand() throws {
        let config = """
        - This is an invalid command
        - Another invalid command
        """
        assert(
            try Command.parse(getYamlContent(config)),
            throws: Command.CommandError.invalidData("[\"This is an invalid command\", \"Another invalid command\"]")
        )
    }

    func testRunWithInvalidTypeCommand() throws {
        let config = genRunConfig([.command(true)])
        do {
            _ = try Command.parse(getYamlContent(config))
        } catch {
            XCTAssertNotNil(error as? Command.CommandError)
        }
    }

    func testRunWithCommandDefined() throws {
        let config = genRunConfig([.command(echo)])
        let command = Command(run: Run(command: echo))
        let actualCommand = try Command.parse(getYamlContent(config))
        XCTAssertEqual(actualCommand, command)
    }

    func testRunWithCommandPathCriticalDefined() throws {
        let config = genRunConfig([.command(echo), .path(path), .critical(critical)])
        let command = Command(run: Run(command: echo, path: path, critical: critical))
        let actualCommand = try Command.parse(getYamlContent(config))
        XCTAssertEqual(actualCommand, command)
    }

    func testRunWithCommandPathCriticalVerboseDefined() throws {
        let config = genRunConfig([.command(echo), .path(path), .critical(critical), .verbose(verbose)])
        let command = Command(run: Run(command: echo, path: path, critical: critical, verbose: verbose))
        let actualCommand = try Command.parse(getYamlContent(config))
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
        assert(
            try Hook.parse(hookType: .preCommit, data),
            throws: Hook.HookError.invalidCommand(
                .preCommit,
                .invalidRun(
                    .run,
                    .invalidTypeInRunKey(.command, "true")
                )
            )
        )
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
            throws: Hook.HookError.invalidCommand(
                .prePush,
                .invalidRun(.run, .invalidData("<null>"))
            )
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
