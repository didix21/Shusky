//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Files
import Foundation
import Rainbow
@testable import ShuskyCore
import XCTest

final class HookHandlerTests: XCTestCase {
    private let echo = "echo \"Shusky is ready, please configure .shusky.yml\"".magenta
    private let check = " ✔".green
    private lazy var running: String = { "⏳ Running \(echo)" }()
    private lazy var successFullyExecuted: String = {
        "\(check) \(echo) \("has been successfully executed".green)\n\n"
    }()

    func testCommandHandler() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \(successFullyExecuted)
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(command: echo))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 0),
            printer: printerMock
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testCommandHandlerGlobalVerboseFalse() {
        let consoleResult = """
        \(running)
        \(successFullyExecuted)
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: false,
            commands: [Command(run: Run(command: "echo \"Shusky is ready, please configure .shusky.yml\""))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 0),
            printer: printerMock
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testLocalVerboseTrueAndGlobalVerboseFalse() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \(successFullyExecuted)
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: false,
            commands: [Command(
                run: Run(
                    command: "echo \"Shusky is ready, please configure .shusky.yml\"",
                    verbose: true
                )
            )]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 0),
            printer: printerMock
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testLocalVerboseFalseAndGlobalVerboseTrue() {
        let consoleResult = """
        \(running)
        \(successFullyExecuted)
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(
                run: Run(
                    command: "echo \"Shusky is ready, please configure .shusky.yml\"",
                    verbose: false
                )
            )]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 0),
            printer: printerMock
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testLocalVerboseTrueAndGlobalVerboseTrue() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \(successFullyExecuted)
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(
                command: "echo \"Shusky is ready, please configure .shusky.yml\"",
                verbose: true
            ))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(hook: hook, shell: Shell(), printer: printerMock)

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testIfVerboseIsSetFalseAndCommandFailsDisplayResult() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \("❌  \(echo) \("has failed with error 32".red)")\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: false,
            commands: [Command(run: Run(command: echo))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 32),
            printer: printerMock,
            stderrFile: "",
            stdoutFile: ""
        )
        XCTAssertEqual(commandHandler.run(), 32)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testCommandFails() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \("❌  \(echo) \("has failed with error 32".red)")\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(command: echo))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 32),
            printer: printerMock,
            stderrFile: "",
            stdoutFile: ""
        )
        XCTAssertEqual(commandHandler.run(), 32)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testCommandFailsButIsDefinedAsNonCritical() {
        let consoleResult = """
        \(running)
        Shusky is ready, please configure .shusky.yml
        \("⚠️  \(echo) \("has failed with error 32".yellow)")\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(
                command: "echo \"Shusky is ready, please configure .shusky.yml\"",
                critical: false
            ))]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 32),
            printer: printerMock,
            stderrFile: "",
            stdoutFile: ""
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testIfSkipIsEnabled() {
        setenv("SKIP_SHUSKY", "1", 1)
        let hook = Hook(hookType: .preCommit, verbose: true, commands: [Command(run: Run(
            command: "echo \"Shusky is ready, please configure .shusky.yml\"",
            critical: false
        ))])
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(
            hook: hook,
            shell: ShellMock(commandOutput: "Shusky is ready, please configure .shusky.yml", statusCode: 0),
            printer: printerMock
        )

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, "")
        unsetenv("SKIP_SHUSKY")
    }
}
