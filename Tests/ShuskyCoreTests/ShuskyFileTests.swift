
import Foundation
import Files
import XCTest
@testable import ShuskyCore

final class ShuskyFileTests: XCTestCase {

    let fileName = ".shusky.yml"
    let tmpFolder = Folder.temporary
    var testFolder: Folder!
    var shuskyFile: ShuskyFile!

    override func setUp() {
        shuskyFile = ShuskyFile()
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try! tmpFolder.createSubfolderIfNeeded(
                withName: "ShuskyConfigFilesPath"
        )
        // Empty the test folder to ensure a clean state
        try! testFolder.empty(includingHidden: true)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    override func tearDown() {
        try! testFolder.empty(includingHidden: true)
    }

    func testShuskyFileName() throws {
        XCTAssertEqual(self.fileName, shuskyFile.fileName)
    }

    func testShuskyFilePath() throws {
        let expectedPath = "./"
        let actualPath = shuskyFile.path
        XCTAssertEqual(actualPath, expectedPath)
    }

    func testReadShuskyYml() throws {
        _ = try testFolder.createFile(named: fileName)
        XCTAssertNotNil(try? shuskyFile.read())
    }

    func testCreateFile() throws {
        try shuskyFile.create()
        let file = try File(path: "./\(self.fileName)")
        XCTAssertNotNil(try? file.read())
    }

    func testCreateDefaultShuskyYamlFile() throws {
        try shuskyFile.createDefaultShuskyYaml()
        let file = try File(path: "./\(self.fileName)")
        XCTAssertEqual(shuskyFile.defaultConfig, try! file.readAsString())
    }

    func testDontCreateDefaultShuskyYamlFileIfNotEmpty() throws  {
        let folder = try Folder(path: "./")
        let file = try folder.createFile(at: fileName)
        try file.write("Some data there")
        try shuskyFile.createDefaultShuskyYaml()

        XCTAssertEqual(try file.readAsString(), "Some data there")
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

}
