//
//  CommandTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Files
import Foundation
@testable import ShuskyCore
import XCTest
import Yams

class CommandTests: XCTestCase {
    private let tmpFolder = Folder.temporary
    private let tmpFolderName = "CommandTests"
    private var testFolder: Folder!
    private let echo = "echo \"print with bash\""
    private let path = "./This/path"
    private var critical = true
    private var verbose = true
    private let buildPath = "./.build-test/builds"
    private let configuration = ConfigurationType.release
    private let packagePath = "BuildTools"

    override func setUpWithError() throws {
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try tmpFolder.createSubfolderIfNeeded(
            withName: tmpFolderName
        )
        // Empty the test folder to ensure a clean state
        try testFolder.empty(includingHidden: true)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    private func getYamlContent(_ config: String) -> Any {
        guard let yaml = try? Yams.load(yaml: config) else { fatalError() }
        return yaml
    }

    private func genRunConfig(_ config: [RunConfigTests]) -> String {
        RunConfigTests.mapToStr(config)
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

    func testDefaultSwiftRun() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
        """
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(
            run: Run(command: "swift run swiftformat ./")
        )
        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testCustomSwiftRun() throws {
        verbose = true
        critical = false
        let jobs = 10
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            verbose: \(verbose)
            critical: \(critical)
            build-path: \(buildPath)
            configuration: \(configuration.rawValue)
            jobs: \(jobs)
            package-path: \(packagePath)
        """
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(
            run: Run(
                command: "swift run -c release --build-path ./.build-test/builds --package-path BuildTools --jobs 10 swiftformat ./"
            )
        )
        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldRunBinary() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
        """
        _ = try testFolder.createFile(at: "./.build/debug/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./.build/debug/swiftformat ./"))

        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldRunDebugBinary_WithPackagePath() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            package-path: \(packagePath)
        """
        _ = try testFolder.createFile(at: "./BuildTools/.build/debug/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./BuildTools/.build/debug/swiftformat ./"))

        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldRunReleaseBinary_WithPackagePath() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            configuration: \(configuration.rawValue)
            package-path: \(packagePath)
        """

        _ = try testFolder.createFile(at: "./BuildTools/.build/release/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./BuildTools/.build/release/swiftformat ./"))

        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldAvoidAddingCurrentPath_WhenRunningBinary() throws {
        // if ./ is already defined, should not be added again
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            configuration: \(configuration.rawValue)
            package-path: ./BuildTools
        """

        _ = try testFolder.createFile(at: "./BuildTools/.build/release/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./BuildTools/.build/release/swiftformat ./"))

        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldRunDebugBinary_WithBuildPath() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            build-path: \(buildPath)
            package-path: \(packagePath)
        """

        _ = try testFolder.createFile(at: "./.build-test/builds/debug/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./.build-test/builds/debug/swiftformat ./"))

        XCTAssertEqual(command, expectedSwiftRun)
    }

    func testShouldRunReleaseBinary_WithBuildPath() throws {
        let yaml = """
        swift-run:
            command: "swiftformat ./"
            configuration: \(configuration.rawValue)
            build-path: \(buildPath)
            package-path: \(packagePath)
        """

        _ = try testFolder.createFile(at: "./.build-test/builds/release/swiftformat")
        let command: Command = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = Command(run: Run(command: "./.build-test/builds/release/swiftformat ./"))
        XCTAssertEqual(command, expectedSwiftRun)
    }
}
