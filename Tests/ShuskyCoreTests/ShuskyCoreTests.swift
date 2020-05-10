
import Foundation
import XCTest
@testable import ShuskyCore

final class ShuskyCoreTests: XCTestCase {
    func testShuskyFileHandler() throws {
        XCTAssertEqual(1, 1)
    }
    
    func testShuskyFileName() throws {
        let expectedFileName = "shusky.yml"
        let actualFileName = ShuskyConfigFileHandler.fileName
        XCTAssertEqual(expectedFileName, actualFileName)
    }
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testShuskyFileHandler", testShuskyFileHandler),
    ]
}
