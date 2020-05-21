//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Foundation
import Files
import Yams
import XCTest
@testable import ShuskyCore

final class ShuskyModelsTests: XCTestCase {

    let preCommit = "pre-commit:"
    let echo = "echo \"print with bash\""
    let path = "./This/path"
    var critical = true
    var verbose = true
    let yamsEncoder = YAMLEncoder()

    func getYamlContent(_ config: String)-> Any {
        guard let yaml = try? Yams.load(yaml: config) else { fatalError() }
        return yaml
    }

    func genHookConfig(_ config: [HookConfigTests]) -> String {
        HookConfigTests.mapToStr(config)
    }

    func genRunConfig(_ config: [RunConfigTests]) -> String {
        RunConfigTests.mapToStr(config)
    }

    func testInvalidCommand() throws {
        let config = """
                     - This is an invalid command
                     - Another invalid command
                     """
        assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.invalidDataInHook)
    }

    func testRunWithNoCommandDefined() throws {
        let config = genRunConfig([])
       assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.noCommands)
    }

    func testRunWithInvalidTypeCommand() throws {
        let config = genRunConfig([.command(true)])
        assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.invalidTypeInRunKey(.command))
    }

    func testRunWithInvalidTypePath() throws {
        let config = genRunConfig([.path(true)])
        assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.invalidTypeInRunKey(.path))
    }

    func testRunWithInvalidTypeCritical() throws {
        let config = genRunConfig([.critical("bad type")])
        assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.invalidTypeInRunKey(.critical))
    }

    func testRunWithInvalidTypeVerbose() throws {
        let config = genRunConfig([.verbose("bad type")])
        assert(try Command.parse(getYamlContent(config)), throws: ShuskyParserError.invalidTypeInRunKey(.verbose))
    }

    func testRunWithCommandDefined() throws {
        let config = genRunConfig([.command(echo)])
        let command = Command(run: Run(command: echo))
        let actualCommand = try Command.parse(getYamlContent(config))
        XCTAssertEqual(actualCommand, command)
    }

    func testRunWithCommandPathDefined() throws {
        let config = genRunConfig([.command(echo), .path(path)])
        let command = Command(run: Run(command: echo, path: path))
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

    func testEmptyYaml() throws {
        let config = genHookConfig([])
        assert(try ShuskyParser(hookType: .preCommit, yamlContent: config), throws: ShuskyParserError.shuskyConfigIsEmpty)
    }

    func testNoHookFound() throws {
        let config = genHookConfig([.hookType(.preCommit)])
        assert(try ShuskyParser(hookType: .preCommit, yamlContent: config), throws: ShuskyParserError.noHookFound)
    }

    func testInvalidTypeVerboseInHook() throws {
        let config = genHookConfig([.verbose("bad type"), .hookType(.preCommit), .commands([echo])])
        assert(
                try ShuskyParser(hookType: .preCommit, yamlContent: config),
                throws: ShuskyParserError.invalidTypeInHookKey(.verbose)
        )
    }

    func testParseSimpleConfig() throws {
        let config = genHookConfig([.verbose(verbose), .hookType(.preCommit), .commands([echo])])
        let expectedHook = Hook(
                hookType: .preCommit, verbose: true, commands: [Command(run: Run(command: echo))]
        )
        let shuskyParsed = try ShuskyParser(hookType: .preCommit, yamlContent: config)
        XCTAssertEqual(shuskyParsed.hook, expectedHook)
    }

    func testParseComplexConfig() throws {
        let swiftFormat = "swift run -c release swiftformat ."
        let swiftLint = "swift run -c lint swiftlint ."
        let config = """
                     verbose: \(verbose)
                     pre-commit: 
                        - \(echo)
                        - \(swiftLint)
                        - run:
                            command: \(swiftFormat)
                        - run:
                            command: \(swiftLint)
                            path: \(path)
                        - run:
                            command: \(swiftFormat)
                            path: \(path)
                            critical: \(critical)
                        - run:
                            command: \(swiftLint)
                            path: \(path)
                            critical: \(critical)
                            verbose: \(verbose)
                     """
        let commands = [
            Command(run: Run(command: echo)),
            Command(run: Run(command: swiftLint)),
            Command(run: Run(command: swiftFormat)),
            Command(run: Run(command: swiftLint, path: path)),
            Command(run: Run(command: swiftFormat, path: path, critical: critical)),
            Command(run: Run(command: swiftLint, path: path, critical: critical, verbose: verbose))
        ]
        let expectedHook = Hook(hookType: .preCommit, verbose: true, commands: commands)
        let shuskyParsed = try ShuskyParser(hookType: .preCommit, yamlContent: config)
        XCTAssertEqual(shuskyParsed.hook, expectedHook)
    }

    func testHooksParser() throws {
        let config = """
                     applypatch-msg:
                        - echo Hello world
                     post-applypatch:
                        - echo Hello world
                     pre-commit:
                        - run:
                            command: echo Hello World
                            critical: true
                     post-merge:
                        - echo Hello world
                     pre-push:
                        - echo Hello world
                     """
        let expectedHookTypes: [HookType] = [.applypatchMsg, .postApplyPatch, .preCommit, .postMerge, .prePush]

        let hooksParser = try HooksParser(config)
        XCTAssertEqual(hooksParser.availableHooks, expectedHookTypes)
    }

    func testHookTypeEnum() {
        XCTAssertEqual(HookType.applypatchMsg.rawValue, "applypatch-msg")
        XCTAssertEqual(HookType.preApplyPatch.rawValue, "pre-applypatch")
        XCTAssertEqual(HookType.postApplyPatch.rawValue, "post-applypatch")
        XCTAssertEqual(HookType.preCommit.rawValue, "pre-commit")
        XCTAssertEqual(HookType.preMergeCommit.rawValue, "pre-merge-commit")
        XCTAssertEqual(HookType.prepareCommitMsg.rawValue, "prepare-commit-msg")
        XCTAssertEqual(HookType.commitMsg.rawValue, "commit-msg")
        XCTAssertEqual(HookType.postCommit.rawValue, "post-commit")
        XCTAssertEqual(HookType.preRebase.rawValue, "pre-rebase")
        XCTAssertEqual(HookType.postCheckout.rawValue, "post-checkout")
        XCTAssertEqual(HookType.postMerge.rawValue, "post-merge")
        XCTAssertEqual(HookType.prePush.rawValue, "pre-push")
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