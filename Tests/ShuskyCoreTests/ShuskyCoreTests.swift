import Files
import Foundation
@testable import ShuskyCore
import XCTest
import Yams

// swiftlint:disable:next type_body_length
final class ShuskyCoreTests: XCTestCase {
    let packagePath = "Complex/Path/To/Execute/Swift/Package"
    let gitPath = ".git/hooks/"
    let shuskyFileName = ".shusky.yml"
    let tmpFolder = Folder.temporary
    var testFolder: Folder!

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
        let prePushFile = try File(path: "\(gitPath)pre-push")
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
        XCTAssertEqual(try preCommitFile.readAsString(), swiftRun(hookType: "pre-commit"))
        XCTAssertEqual(try prePushFile.readAsString(), swiftRun(hookType: "pre-push"))
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

    func testInstallWithPackagePath() throws {
        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath, packagePath: packagePath)

        XCTAssertEqual(result, 0)
        XCTAssertEqual(
            try File(path: gitPath + HookType.preCommit.rawValue).readAsString(),
            swiftRunWithPath(hookType: HookType.preCommit.rawValue)
        )
        XCTAssertEqual(
            try File(path: gitPath + HookType.prePush.rawValue).readAsString(),
            swiftRunWithPath(hookType: HookType.prePush.rawValue)
        )
    }

    func testInstallMustOverwriteHookIfAlreadyExistsAndOverwriteParamIsProvided() throws {
        let config = """
        pre-commit:
           - echo print something
        """
        let content = "Some content in a hook file\n"
        let hookFile = try testFolder.createFile(at: gitPath + HookType.preCommit.rawValue)
        try hookFile.write(content)
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath, overwrite: true)
        let preCommit = try File(path: "\(gitPath)pre-commit")

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

        for hook in HookType.allCases {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRunWithPath(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath)

        let expectedHooksInstalled: [HookType] = [.applypatchMsg, .prePush, .preCommit]

        for hook in HookType.allCases where !expectedHooksInstalled.contains(hook) {
            XCTAssertNil(try? File(path: gitPath + hook.rawValue))
        }

        for expectedHook in expectedHooksInstalled {
            XCTAssertNotNil(try? File(path: gitPath + expectedHook.rawValue))
        }

        XCTAssertEqual(result, 0)
    }

    func testInstallAllHooks() throws {
        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath, all: true)
        for hook in HookType.allCases {
            let hookFile = try File(path: gitPath + hook.rawValue)
            XCTAssertEqual(try hookFile.readAsString(), swiftRun(hookType: hook.rawValue))
        }
        XCTAssertEqual(result, 0)
        XCTAssertEqual(try File(path: shuskyFileName).readAsString(), ShuskyFile().defaultConfig)
    }

    func testInstallAllHooksPackagePath() throws {
        let shuskyCore = ShuskyCore()
        let result = shuskyCore.install(gitPath: gitPath, packagePath: packagePath, all: true)
        for hook in HookType.allCases {
            let hookFile = try File(path: gitPath + hook.rawValue)
            XCTAssertEqual(try hookFile.readAsString(), swiftRunWithPath(hookType: hook.rawValue))
        }
        XCTAssertEqual(result, 0)
        XCTAssertEqual(try File(path: shuskyFileName).readAsString(), ShuskyFile().defaultConfig)
    }

    func testDefaultInstallAndThenInstallAll() throws {
        let shuskyCore = ShuskyCore()
        _ = shuskyCore.install(gitPath: gitPath)
        let resultInstallAll = shuskyCore.install(gitPath: gitPath, all: true)
        for hook in HookType.allCases {
            let hookFile = try File(path: gitPath + hook.rawValue)
            XCTAssertEqual(try hookFile.readAsString(), swiftRun(hookType: hook.rawValue))
        }
        XCTAssertEqual(resultInstallAll, 0)
        XCTAssertEqual(try File(path: shuskyFileName).readAsString(), ShuskyFile().defaultConfig)
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

    func testRunVerboseFalse() throws {
        let config = """
        pre-commit:
           - run:
               command: echo print something; exit 1
               verbose: false
        """
        let file = try testFolder.createFile(named: shuskyFileName)
        try file.write(config)
        let shuskyCore = ShuskyCore()
        let exitCode = shuskyCore.run(hookType: .preCommit)
        XCTAssertEqual(exitCode, 1)
        XCTAssertNil(try? File(path: "/var/tmp/shusky_stderr").readAsString())
        XCTAssertNil(try? File(path: "/var/tmp/shusky_stdout").readAsString())
    }

    func testRunUninstall() throws {
        for hook in HookType.allCases {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRun(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.uninstall(gitPath: gitPath)

        for hook in HookType.allCases {
            XCTAssertNil(try? File(path: gitPath + hook.rawValue))
        }

        XCTAssertEqual(result, 0)
    }

    func testRunUninstallWithPackagePath() throws {
        for hook in HookType.allCases {
            let file = try testFolder.createFile(at: gitPath + hook.rawValue)
            try file.write(swiftRunWithPath(hookType: hook.rawValue))
        }

        let shuskyCore = ShuskyCore()
        let result = shuskyCore.uninstall(gitPath: gitPath)

        for hook in HookType.allCases {
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
