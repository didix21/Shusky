//
//  SwiftExtensionTests.swift
//  ShuskyCoreTests
//
//  Created by Dídac Coll Pujals on 07/11/2020.
//

import Foundation
@testable import ShuskyCore
import XCTest

class SwiftExtensionTests: XCTestCase {
    func testIndex() {
        let index = "index"
        let expectedIndex = "my index".index(of: index)

        XCTAssertEqual(expectedIndex, "my ".endIndex)
    }

    func testEndIndex() {
        let expectedIndex = "my index of this".endIndex(of: "index")
        XCTAssertEqual(expectedIndex, "my index".endIndex)
    }
}
