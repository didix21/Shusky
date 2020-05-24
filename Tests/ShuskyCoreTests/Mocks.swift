//
// Created by Dídac Coll Pujals on 25/05/2020.
//

import Foundation
@testable import ShuskyCore

final class PrinterMock: Printable {
    var output: String = ""

    func print(_ str: Any) {
        output += "\(str)\n"
    }

    func print(_ str: Any, terminator: String) {
        output += "\(str)" + terminator
    }

    func printState(_ commandState: HookHandler.CommandState, _ command: Command) {
        let runCommand = command.run.command
        switch commandState {
        case .running:
            printc(.white, commandState.describe(runCommand))
        case .success:
            printc(.green, commandState.describe(runCommand))
        case .error:
            printc(.red, commandState.describe(runCommand))
        case .isNotCritical:
            printc(.yellow, commandState.describe(runCommand))
        }
    }

    func printc(_ color: ANSIColors, _ str: Any) {
        output += color.rawValue + "\(str)\n"
    }

    func printc(_ color: ANSIColors, _ str: Any, terminator: String) {
        output += color.rawValue + "\(str)" + terminator
    }
}

final class ShellMock: Executable {
    private(set) var executeIsCalled = false
    private(set) var executeWithRTProgressIsCalled = false
    private let output: String
    private let statusCode: Int32

    init(commandOutput: String, statusCode: Int32) {
        self.output = commandOutput
        self.statusCode = statusCode
    }
    func execute(_ command: String) -> ShellResult {
        executeIsCalled = true
        return ShellResult(output: output, status: statusCode)
    }

    func executeWithRTProgress(_ command: String, rtOut: @escaping (String) -> ()) -> ShellResult {
        executeWithRTProgressIsCalled = true
        rtOut(output)
        return ShellResult(output: output, status: statusCode)
    }


}