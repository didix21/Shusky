import Foundation
import XCTest
import Files
import Yams
@testable import ShuskyCore

final class ShuskyCoreTests: XCTestCase {
    let gitPath = ".git/hooks/"
    let shuskyFileName = ".shusky.yml"
    let tmpFolder = Folder.temporary
    var testFolder: Folder!

    func swiftRun(hookType: String) -> String {
        "swift run -c release shusky run \(hookType)"
    }

    override func setUp() {
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try! tmpFolder.createSubfolderIfNeeded(
                withName: "ShuskyCorePath"
        )
        // Empty the test folder to ensure a clean state
        try! testFolder.empty(includingHidden: true)

        try! testFolder.createSubfolderIfNeeded(withName: ".git")
        try! testFolder.createSubfolderIfNeeded(withName: gitPath)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    override func tearDown() {
        try! testFolder.empty(includingHidden: true)
    }

    func testDefaultContentOfShuskyYMlAndPreCommitConfigured() throws {
        let shuskyCore = ShuskyCore()
        shuskyCore.install(gitPath: gitPath)
        let shuskyFile = try File(path: shuskyFileName)
        let preCommitFile = try File(path: "\(gitPath)pre-commit")

        XCTAssertEqual(
                try shuskyFile.readAsString(),
                """
                pre-commit:
                    - echo "Shusky is ready, please configure \(self.shuskyFileName)

                """
        )
        XCTAssertEqual(try preCommitFile.readAsString(), "swift run -c release shusky run pre-commit")
    }

    func testAddMultipleHooksIfTheyAreConfigured() throws {
        let config = """
                     applypatch-msg:
                        - echo print something
                     pre-push:
                        - echo print something
                     pre-commit:
                        - echo print something
                     """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        shuskyCore.install(gitPath: gitPath)
        let applyPatchMsgFile = try File(path: "\(gitPath)applypatch-msg")
        let prePushFile = try File(path: "\(gitPath)pre-push")
        let preCommit = try File(path: "\(gitPath)pre-commit")

        XCTAssertEqual(try applyPatchMsgFile.readAsString(), swiftRun(hookType: "applypatch-msg"))
        XCTAssertEqual(try prePushFile.readAsString(), swiftRun(hookType: "pre-push"))
        XCTAssertEqual(try preCommit.readAsString(), swiftRun(hookType: "pre-commit"))
    }

}