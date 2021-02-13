//
//  HookTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation
@testable import ShuskyCore
import XCTest
import Yams

class HookTests: XCTestCase {
    let yamsEncoder = YAMLEncoder()

    func getYamlContent(_ config: String) -> Any {
        guard let yaml = try? Yams.load(yaml: config) else { fatalError() }
        return yaml
    }

    func genHookConfig(_ config: [HookConfigTests]) -> String {
        HookConfigTests.mapToStr(config)
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
}
