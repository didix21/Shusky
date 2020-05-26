//
// Created by Dídac Coll Pujals on 23/05/2020.
//

import Foundation
@testable import ShuskyCore
import XCTest
import Yams

final class ShuskyParserTests: XCTestCase {
    let preCommit = "pre-commit:"
    let echo = "echo \"print with bash\""
    let path = "./This/path"
    var critical = true
    var verbose = true

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

    func testEmptyYaml() throws {
        let config = genHookConfig([])
        assert(
            try ShuskyHookParser(hookType: .preCommit, yamlContent: config),
            throws: ShuskyParserError.shuskyConfigIsEmpty
        )
    }

    func testNoHookFound() throws {
        let config = genHookConfig([.hookType(.prePush)])
        assert(
            try ShuskyHookParser(hookType: .preCommit, yamlContent: config),
            throws: ShuskyParserError.invalidHook(.noHookFound)
        )
    }

    func testHookContentIsEmpty() throws {
        let config = genHookConfig([.hookType(.preCommit)])
        assert(
            try ShuskyHookParser(hookType: .preCommit, yamlContent: config),
            throws: ShuskyParserError.invalidHook(.hookIsEmpty(.preCommit))
        )
    }

    func testInvalidTypeVerboseInHook() throws {
        let config = genHookConfig([.verbose("bad type"), .hookType(.preCommit), .commands([echo])])
        assert(
            try ShuskyHookParser(hookType: .preCommit, yamlContent: config),
            throws: ShuskyParserError.invalidHook(.invalidTypeInHookKey(.verbose, "bad type"))
        )
    }

    func testParseSimpleConfig() throws {
        let config = genHookConfig([.verbose(verbose), .hookType(.preCommit), .commands([echo])])
        let expectedHook = Hook(
            hookType: .preCommit, verbose: true, commands: [Command(run: Run(command: echo))]
        )
        let shuskyParsed = try ShuskyHookParser(hookType: .preCommit, yamlContent: config)
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
            Command(run: Run(command: swiftLint, path: path, critical: critical, verbose: verbose)),
        ]
        let expectedHook = Hook(hookType: .preCommit, verbose: true, commands: commands)
        let shuskyParsed = try ShuskyHookParser(hookType: .preCommit, yamlContent: config)
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

        let hooksParser = try ShuskyHooksParser(config)
        XCTAssertEqual(hooksParser.availableHooks, expectedHookTypes)
    }

    func testHookParserShuskyConfigIsEmpty() throws {
        let config = ""
        assert(try ShuskyHooksParser(config), throws: ShuskyParserError.shuskyConfigIsEmpty)
    }

    func testHookParserNoHooksFound() throws {
        let config = """
        pop:
           - do something
        pepe:
           - do something else
        """
        assert(try ShuskyHooksParser(config), throws: ShuskyParserError.noHooksFound)
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
}
