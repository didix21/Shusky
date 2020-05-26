//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Files
import Foundation
@testable import ShuskyCore
import XCTest

final class GitHookFileHandlerTests: XCTestCase {
    let tmpFolder = Folder.temporary
    var testFolder: Folder!
    var shuskyFile: ShuskyFile!
    let gitPath = "GitPathTests"
    let path = ".git/hooks/"

    override func setUp() {
        shuskyFile = ShuskyFile()
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try! tmpFolder.createSubfolderIfNeeded(
            withName: gitPath
        )
        // Empty the test folder to ensure a clean state
        try! testFolder.empty(includingHidden: true)
        try! testFolder.createSubfolder(at: path)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    override func tearDown() {
        try! testFolder.empty()
    }

    func testCreateHookFileIfNotExists() throws {
        _ = try GitHookFileHandler(hook: .preCommit, path: path)
        let file = try File(path: path + HookType.preCommit.rawValue)
        XCTAssertNotNil(try file.read())
    }

    func testAddHook() throws {
        let expectedContent = "swift run -c release shusky run pre-commit"
        _ = try GitHookFileHandler(hook: .preCommit, path: path)
        let file = try File(path: path + HookType.preCommit.rawValue)
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAddHookWithPackagePath() throws {
        let expectedContent = "swift run -c release --package-path BuildTools shusky run pre-commit"
        _ = try GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        let file = try File(path: path + HookType.preCommit.rawValue)
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAppendHook() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let content = "Write some content"
        try file.write(content)

        let expectedContent = content + "\nswift run -c release shusky run pre-commit\n"
        _ = try GitHookFileHandler(hook: .preCommit, path: path)

        let actualContent = try file.readAsString()

        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAppendHookWithPackagePath() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let content = "Write some content"
        try file.write(content)

        let expectedContent = content + "\nswift run -c release --package-path BuildTools shusky run pre-commit\n"
        _ = try GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        let actualContent = try file.readAsString()

        XCTAssertEqual(actualContent, expectedContent)
    }

    func testDontAppendHookIfAlreadyExist() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let expectedContent = "swift run -c release shusky run pre-commit"
        try file.write(expectedContent)

        _ = try GitHookFileHandler(hook: .preCommit, path: path)
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testDontAppendHookWithPackagePathIfAlreadyExist() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let expectedContent = "swift run -c release --package-path BuildTools shusky run pre-commit"
        try file.write(expectedContent)

        _ = try GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testExecutionPermissions() throws {
        _ = try GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        let fm = FileManager.default
        let attributes = try fm.attributesOfItem(atPath: path + HookType.preCommit.rawValue)
        XCTAssertEqual(attributes[.posixPermissions] as? Int, Optional(0o755))
    }

    // Returns path to the built products directory.
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
