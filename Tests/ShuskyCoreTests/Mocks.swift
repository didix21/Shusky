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
}

final class ShellMock: Executable {
    private(set) var executeIsCalled = false
    private(set) var executeWithRTProgressIsCalled = false
    private let output: String
    private let statusCode: Int32

    init(commandOutput: String, statusCode: Int32) {
        output = commandOutput
        self.statusCode = statusCode
    }

    func execute(_: String) -> ShellResult {
        executeIsCalled = true
        return ShellResult(output: output, status: statusCode)
    }

    func executeWithRTProgress(_: String, rtOut: @escaping (String) -> Void) -> ShellResult {
        executeWithRTProgressIsCalled = true
        rtOut(output)
        return ShellResult(output: output, status: statusCode)
    }
}
