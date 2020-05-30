import Files
import Foundation
@testable import ShuskyCore
import XCTest
import Yams

final class ShuskyCoreTests: XCTestCase {
    let gitPath = ".git/hooks/"
    let shuskyFileName = ".shusky.yml"
    let tmpFolder = Folder.temporary
    var testFolder: Folder!

    func swiftRun(hookType: String) -> String {
        "swift run -c release shusky run \(hookType)\n"
    }

    func swiftRunWithPath(hookType: String, packagePath: String = "Complex/Path/To/Execute/Swift/Package") -> String {
        "swift run -c release --package-path \(packagePath) shusky run \(hookType)\n"
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
        let result = shuskyCore.install(gitPath: gitPath)
        let shuskyFile = try File(path: shuskyFileName)
        let preCommitFile = try File(path: "\(gitPath)pre-commit")

        XCTAssertEqual(
            try shuskyFile.readAsString(),
            """
            pre-push:
                - echo "Shusky is ready, please configure \(shuskyFileName)"
            pre-commit:
                - echo "Shusky is ready, please configure \(shuskyFileName)"

            """
        )
        XCTAssertEqual(try preCommitFile.readAsString(), "swift run -c release shusky run pre-commit\n")
        XCTAssertEqual(result, 0)
    }

    func testInstallAddMultipleHooksIfTheyAreConfigured() throws {
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
        let result = shuskyCore.install(gitPath: gitPath)
        let applyPatchMsgFile = try File(path: "\(gitPath)applypatch-msg")
        let prePushFile = try File(path: "\(gitPath)pre-push")
        let preCommit = try File(path: "\(gitPath)pre-commit")

        XCTAssertEqual(try applyPatchMsgFile.readAsString(), swiftRun(hookType: "applypatch-msg"))
        XCTAssertEqual(try prePushFile.readAsString(), swiftRun(hookType: "pre-push"))
        XCTAssertEqual(try preCommit.readAsString(), swiftRun(hookType: "pre-commit"))
        XCTAssertEqual(result, 0)
    }

    func testInstallMustRemoveThoseHooksThatAreNoLongerPresentInShuskyYml() throws {
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

        for hook in HookType.getAll() {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRunWithPath(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath)

        let expectedHooksInstalled: [HookType] = [.applypatchMsg, .prePush, .preCommit]

        for hook in HookType.getAll() where !expectedHooksInstalled.contains(hook) {
            XCTAssertNil(try? File(path: gitPath + hook.rawValue))
        }

        for expectedHook in expectedHooksInstalled {
            XCTAssertNotNil(try? File(path: gitPath + expectedHook.rawValue))
        }

        XCTAssertEqual(result, 0)
    }

    func testRunReturn1IfShuskyFileDoesNotExist() throws {
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .preCommit, shuskyPath: "./BuildTools")

        XCTAssertEqual(exitCode, 1)
    }

    func testRunReturn1IfHookIsEmpty() throws {
        let config = """
        pre-commit:
        """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .preCommit)

        XCTAssertEqual(exitCode, 1)
    }

    func testRunReturns0IfHookIsNotDefined() throws {
        let config = """
        applypatch-msg:
           - echo print something
        pre-push:
           - echo print something
        """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .preCommit)

        XCTAssertEqual(exitCode, 0)
    }

    func testRunReturnTheCodeErrorOfCommandThatHasFailed() throws {
        let config = """
        applypatch-msg:
           - echo print something
        pre-push:
           - exit 19
        """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .prePush)

        XCTAssertEqual(exitCode, 19)
    }

    func testRunReturn0IfAllCommandsAreExecuted() throws {
        let config = """
        applypatch-msg:
           - echo print something
        pre-push:
           - echo command 1
           - echo command 2
           - echo command 3
        """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .prePush)

        XCTAssertEqual(exitCode, 0)
    }

    func testRunUninstall() throws {
        for hook in HookType.getAll() {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRun(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.uninstall(gitPath: gitPath)

        for hook in HookType.getAll() {
            XCTAssertNil(try? File(path: gitPath + hook.rawValue))
        }

        XCTAssertEqual(result, 0)
    }

    func testRunUninstallWithPackagePath() throws {
        for hook in HookType.getAll() {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRunWithPath(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.uninstall(gitPath: gitPath)

        for hook in HookType.getAll() {
            XCTAssertNil(try? File(path: gitPath + hook.rawValue))
        }

        XCTAssertEqual(result, 0)
    }

    func testRunUninstallDoesNotFailIfNotContainsShuskyRunCommand() throws {
        let file = try testFolder.createFile(at: gitPath + HookType.preCommit.rawValue)
        try file.write("write any command here")
        let shuskyCore = ShuskyCore()
        let result = shuskyCore.uninstall(gitPath: gitPath)

        XCTAssertEqual(result, 0)
    }
}
