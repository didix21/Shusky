//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Files
import Foundation
@testable import ShuskyCore
import XCTest

final class GitHookFileHandlerTests: XCTestCase {
    private let tmpFolder = Folder.temporary
    private var testFolder: Folder!
    private let gitPath = "GitPathTests"
    private let path = ".git/hooks/"

    override func setUpWithError() throws {
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try tmpFolder.createSubfolderIfNeeded(
            withName: gitPath
        )
        // Empty the test folder to ensure a clean state
        try testFolder.empty(includingHidden: true)
        try testFolder.createSubfolder(at: path)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    override func tearDownWithError() throws {
        try testFolder.empty()
    }

    func testCreateHookFileIfNotExists() throws {
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.addHook()
        let file = try File(path: path + HookType.preCommit.rawValue)
        XCTAssertNotNil(try file.read())
    }

    func testAddHook() throws {
        let expectedContent = swiftRun(hookType: "pre-commit")
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.addHook()
        let file = try File(path: path + HookType.preCommit.rawValue)
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAddHookWithPackagePath() throws {
        let expectedContent = swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools")
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        try gitHookFileHandler.addHook()
        let file = try File(path: path + HookType.preCommit.rawValue)
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAppendHook() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let content = "Write some content"
        try file.write(content)

        let expectedContent = content + "\n\(swiftRun(hookType: "pre-commit"))"
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.addHook()

        let actualContent = try file.readAsString()

        XCTAssertEqual(actualContent, expectedContent)
    }

    func testAppendHookWithPackagePath() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let content = "Write some content"
        try file.write(content)

        let expectedContent = content + "\n\(swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools"))"
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        try gitHookFileHandler.addHook()
        let actualContent = try file.readAsString()

        XCTAssertEqual(actualContent, expectedContent)
    }

    func testDontAppendHookIfAlreadyExist() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let expectedContent = swiftRun(hookType: "pre-commit")
        try file.write(expectedContent)

        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.addHook()
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testDontAppendHookWithPackagePathIfAlreadyExist() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let expectedContent = swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools")
        try file.write(expectedContent)

        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        try gitHookFileHandler.addHook()
        let actualContent = try file.readAsString()
        XCTAssertEqual(actualContent, expectedContent)
    }

    func testOverwriteHookWhenOverwriteOptionIsProvided() throws {
        let folder = try Folder(path: path)
        let file = try folder.createFileIfNeeded(at: HookType.preCommit.rawValue)
        let content = "Write some content"
        try file.write(content)

        let expectedContent = swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools")
        let gitHookFileHandler = GitHookFileHandler(
            hook: .preCommit, path: path,
            packagePath: "BuildTools", overwrite: true
        )
        try gitHookFileHandler.addHook()
        let actualContent = try file.readAsString()

        XCTAssertEqual(actualContent, expectedContent)
    }

    func testExecutionPermissions() throws {
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path, packagePath: "BuildTools")
        try gitHookFileHandler.addHook()
        let fm = FileManager.default
        let attributes = try fm.attributesOfItem(atPath: path + HookType.preCommit.rawValue)
        XCTAssertEqual(attributes[.posixPermissions] as? Int, Optional(0o755))
    }

    func testDeleteHookFileMustBeDeleted() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let content = swiftRun(hookType: "pre-commit")
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertNil(try? file.readAsString())
    }

    func testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase1() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let expectedContent = """
        git add -A
        git commit -m "New Commit"\n
        """
        let content = expectedContent + swiftRun(hookType: "pre-commit")
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertEqual(try file.readAsString(), expectedContent)
    }

    func testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase2() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let expectedContent = """
        git add -A
        git commit -m "New Commit"\n
        """
        let content = "\(swiftRun(hookType: "pre-commit"))" + expectedContent
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertEqual(try file.readAsString(), expectedContent)
    }

    func testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase3() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let expectedContent = """
        git add -A
        git commit -m "New Commit"\n
        """
        let content = "git something\n" + swiftRun(hookType: "pre-commit") + expectedContent
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertEqual(try file.readAsString(), "git something\n" + expectedContent)
    }

    func testDeleteHookFileMustBeDeletedWithPackagePath() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let content = swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools")
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertNil(try? file.readAsString())
    }

    func testDeleteHookFileMustNotBeDeletedWhenContainsOtherDataCase4() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let expectedContent = """
        git add -A
        git commit -m "New Commit"\n
        """
        let content = "git something\n" + swiftRunWithPath(hookType: "pre-commit", packagePath: "BuildTools")
            + expectedContent
        try file.write(content)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertEqual(try file.readAsString(), "git something\n" + expectedContent)
    }

    func testDeleteHookIfThereIsNoShuskyRun() throws {
        let file = try testFolder.createFile(at: path + HookType.preCommit.rawValue)
        let expectedContent = """
        git add -A
        git commit -m "New Commit"\n
        """
        try file.write(expectedContent)
        let gitHookFileHandler = GitHookFileHandler(hook: .preCommit, path: path)
        try gitHookFileHandler.deleteHook()

        XCTAssertEqual(try file.readAsString(), expectedContent)
    }
}
