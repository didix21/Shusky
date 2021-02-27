import Files
import Foundation
import ShuskyCore
import XCTest

final class ShuskyTests: XCTestCase {
    private let packagePath = "Complex/Path/To/Execute/Swift/Package"
    private let binary = "shusky"
    private let gitPath = ".git/hooks/"
    private let tmpFolder = Folder.temporary
    private var testFolder: Folder!

    private func swiftRun(hookType: String) -> String {
        """
        if [[ -f .build/release/shusky ]]; then
            .build/release/shusky run \(hookType)
        else
            swift run -c release shusky run \(hookType)
        fi

        """
    }

    private func swiftRunWithPath(
        hookType: String,
        packagePath: String = "Complex/Path/To/Execute/Swift/Package"
    ) -> String {
        """
        if [[ -f ./\(packagePath)/.build/release/shusky ]]; then
            ./\(packagePath)/.build/release/shusky run \(hookType)
        else
            swift run -c release --package-path \(packagePath) shusky run \(hookType)
        fi

        """
    }

    func runShusky(subcommand: String? = nil) -> ShellResult {
        let fooBinary = productsDirectory.appendingPathComponent(binary)
        let shell = Shell()

        guard let command = subcommand else {
            return shell.execute(extractPath(binary: fooBinary.absoluteString))
        }

        return shell.execute(extractPath(binary: fooBinary.absoluteString + " \(command)"))
    }

    func extractPath(binary: String) -> String {
        String(binary["file://".endIndex...])
    }

    override func setUpWithError() throws {
        // Setup a temp test folder that can be used as a sandbox
        testFolder = try tmpFolder.createSubfolderIfNeeded(
            withName: "ShuskyEnd2End"
        )
        // Empty the test folder to ensure a clean state
        try testFolder.empty(includingHidden: true)

        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
    }

    func testInstallIsNotAGitRepository() throws {
        XCTAssertTrue(runShusky(subcommand: "install").status > 0)
    }

    func testInstall() throws {
        let shell = Shell()
        _ = shell.execute("git init")

        XCTAssertEqual(runShusky(subcommand: "install").status, 0)
        XCTAssertEqual(
            try File(path: gitPath + HookType.preCommit.rawValue).readAsString(),
            swiftRun(hookType: HookType.preCommit.rawValue)
        )
        XCTAssertEqual(
            try File(path: gitPath + HookType.prePush.rawValue).readAsString(),
            swiftRun(hookType: HookType.prePush.rawValue)
        )
    }

    func testInstallPackagePath() throws {
        let shell = Shell()
        _ = shell.execute("git init")

        XCTAssertEqual(runShusky(subcommand: "install --package-path \(packagePath)").status, 0)
        XCTAssertEqual(
            try File(path: gitPath + HookType.preCommit.rawValue).readAsString(),
            swiftRunWithPath(hookType: HookType.preCommit.rawValue)
        )
        XCTAssertEqual(
            try File(path: gitPath + HookType.prePush.rawValue).readAsString(),
            swiftRunWithPath(hookType: HookType.prePush.rawValue)
        )
    }

    func testInstallAll() throws {
        let shell = Shell()
        _ = shell.execute("git init")

        XCTAssertEqual(runShusky(subcommand: "install --all").status, 0)
        for hook in HookType.allCases {
            let rawValue = hook.rawValue
            XCTAssertEqual(try File(path: gitPath + rawValue).readAsString(), swiftRun(hookType: rawValue))
        }
    }

    func testRunFailsBecauseShuskyDoesNotExist() throws {
        let shell = Shell()
        _ = shell.execute("git init")

        XCTAssertEqual(runShusky(subcommand: "run pre-commit").status, 1)
    }

    func testInstallAndRun() throws {
        let shell = Shell()
        _ = shell.execute("git init")

        let resultInstall = runShusky(subcommand: "install")
        let preCommitResult = runShusky(subcommand: "run pre-commit")
        let prePushResult = runShusky(subcommand: "run pre-push")

        XCTAssertEqual(resultInstall.status, 0)
        XCTAssertEqual(preCommitResult.status, 0)
        XCTAssertEqual(prePushResult.status, 0)
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
