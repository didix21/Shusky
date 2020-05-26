//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Foundation
@testable import ShuskyCore
import XCTest

final class ShellTests: XCTestCase {
    let printSomething = "print something"
    lazy var echo = "echo \(printSomething)"

    func testShellExecute() {
        let shell = Shell()
        let expected = ShellResult(output: "\(printSomething)\n", status: 0)
        XCTAssertEqual(shell.execute(echo), expected)
    }

    func testShellExecuteRtProgress() {
        let shell = Shell()
        let expected = ShellResult(output: "\(printSomething)\n", status: 0)
        let result = shell.executeWithRTProgress(echo) { progress in
            XCTAssertEqual(progress, "print something\n")
        }
        XCTAssertEqual(result, expected)
    }
}
