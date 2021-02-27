//
// Created by Dídac Coll Pujals on 25/05/2020.
//

import Files
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
    private let output: String
    private let statusCode: Int32

    init(commandOutput: String, statusCode: Int32) {
        output = commandOutput
        self.statusCode = statusCode
    }

    func execute(_: String) -> ShellResult {
        ShellResult(output: output, status: statusCode)
    }

    func executeWithRTProgress(_: String, rtOut: @escaping (String) -> Void) -> ShellResult {
        rtOut(output)
        return ShellResult(output: output, status: statusCode)
    }
}
