//
//  SwiftRunTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 21/2/21.
//

import Foundation
@testable import ShuskyCore
import XCTest
import Yams

class SwiftRunTests: XCTestCase {
    private let buildPath = ".build-test"
    private let configuration = ConfigurationType.release
    private let packagePath = "BuildTools"

    func getSwiftRun(
        command: String,
        verbose: Bool? = nil,
        critical: Bool? = nil,
        buildPath: String? = nil,
        configuration: ConfigurationType? = nil,
        jobs: Int? = nil,
        packagePath: String? = nil
    ) -> SwiftRun {
        SwiftRun(
            command: command,
            verbose: verbose,
            critical: critical,
            buildPath: buildPath,
            configuration: configuration,
            jobs: jobs,
            packagePath: packagePath
        )
    }

    func testDefaultSwiftRun() throws {
        let yaml = """
        command: "swiftformat ./"
        """

        let swiftRun: SwiftRun = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = getSwiftRun(command: "swiftformat ./")
        XCTAssertEqual(swiftRun, expectedSwiftRun)
    }

    func testCustomSwiftRun() throws {
        let verbose = true
        let critical = false
        let jobs = 10
        let yaml = """
        command: "swiftformat ./"
        verbose: \(verbose)
        critical: \(critical)
        build-path: \(buildPath)
        configuration: \(configuration.rawValue)
        jobs: \(jobs)
        package-path: \(packagePath)
        """

        let swiftRun: SwiftRun = try YAMLDecoder().decode(from: yaml)
        let expectedSwiftRun = getSwiftRun(
            command: "swiftformat ./",
            verbose: verbose,
            critical: critical,
            buildPath: buildPath,
            configuration: .release,
            jobs: jobs,
            packagePath: packagePath
        )
        XCTAssertEqual(swiftRun, expectedSwiftRun)
    }
}
