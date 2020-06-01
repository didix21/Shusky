//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Foundation
@testable import ShuskyCore
import XCTest

final class HookHandlerTests: XCTestCase {
    let echo = "echo \"Shusky is ready, please configure .shusky.yml\""

    func testCommandHandler() {
        let consoleResult = """
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.green.rawValue)✔ \(echo) has successfully executed\n\n
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
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        \(ANSIColors.green.rawValue)✔ \(echo) has successfully executed\n\n
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
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.green.rawValue)✔ \(echo) has successfully executed\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: false,
            commands: [Command(run: Run(
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
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        \(ANSIColors.green.rawValue)✔ \(echo) has successfully executed\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(
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
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.green.rawValue)✔ \(echo) has successfully executed\n\n
        """
        let hook = Hook(
            hookType: .preCommit,
            verbose: true,
            commands: [Command(run: Run(
                command: "echo \"Shusky is ready, please configure .shusky.yml\"",
                verbose: true
            )
                )]
        )
        let printerMock = PrinterMock()
        let commandHandler = HookHandler(hook: hook, shell: Shell(), printer: printerMock)

        XCTAssertEqual(commandHandler.run(), 0)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testIfVerboseIsSetFalseAndCommandFailsDisplayResult() {
        let consoleResult = """
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.red.rawValue)❌ \(echo) has failed with error 32\n\n
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
            printer: printerMock
        )
        XCTAssertEqual(commandHandler.run(), 32)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testCommandFails() {
        let consoleResult = """
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.red.rawValue)❌ \(echo) has failed with error 32\n\n
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
            printer: printerMock
        )
        XCTAssertEqual(commandHandler.run(), 32)
        XCTAssertEqual(printerMock.output, consoleResult)
    }

    func testCommandFailsButIsDefinedAsNonCritical() {
        let consoleResult = """
        \(ANSIColors.white.rawValue)⏳ Running \(echo)
        Shusky is ready, please configure .shusky.yml
        \(ANSIColors.yellow.rawValue)⚠️ \(echo) has failed with error 32\n\n
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
            printer: printerMock
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
