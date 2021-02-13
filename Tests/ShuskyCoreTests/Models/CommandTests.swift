//
//  CommandTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation
@testable import ShuskyCore
import XCTest
import Yams

class CommandTests: XCTestCase {
    private let echo = "echo \"print with bash\""
    private let path = "./This/path"
    private var critical = true
    private var verbose = true

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
}
