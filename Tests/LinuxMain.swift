import XCTest

import ShuskyCoreTests
import ShuskyTests

var tests = [XCTestCaseEntry]()
tests += ShuskyCoreTests.__allTests()
tests += ShuskyTests.__allTests()

XCTMain(tests)
