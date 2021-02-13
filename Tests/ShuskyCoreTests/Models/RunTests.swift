//
//  RunTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation
@testable import ShuskyCore
import XCTest
import Yams

class RunTests: XCTestCase {
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
}
