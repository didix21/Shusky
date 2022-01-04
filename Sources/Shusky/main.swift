import ArgumentParser
import Foundation
import ShuskyCore
import Yams

enum ShuskyError: Error {
    case installFailed
    case runFailed
    case runFailedDueToAnInvalidHook
    case uninstallFailed
}

struct Shusky: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: """
        Shusky. It's a tool for helping to manage and execute git hooks in Swift projects.
            1. Install shusky with 'swift run shusky install'.
            2. Add your hooks in '.shusky.yml' file that has been created in your root.

        NOTE: To skip any git hook execution run: 'SKIP_SHUSKY=1 <git command>'.
              For example, to skip pre-push run: 'SKIP_SHUSKY=1 git push'.
        """,
        version: "1.3.3",
        subcommands: [Install.self, Run.self, Uninstall.self]
    )

    struct Install: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Install all hooks available in .shusky.yml. More info: 'swift run shusky install --help'",
            discussion: "If .shusky.yml does not exist will be created."
        )

        @Option(help: "Set Swift Package Manager path, if Package.swift is not in the root.")
        var packagePath: String?

        @Flag(help: "Use this flag for installing all git hooks.")
        var all: Bool = false

        @Flag(help: "Use this flag for letting shusky overwrite any hook file that already exists.")
        var overwrite: Bool = false

        func run() throws {
            let shuskyCore = ShuskyCore()
            if shuskyCore.install(
                gitPath: Shusky.getGitHookPath(),
                packagePath: packagePath,
                all: all,
                overwrite: overwrite
            ) != 0 {
                throw ShuskyError.installFailed
            }
        }
    }

    struct Run: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Use this command for running a hook in the .swift.yml. More info: 'swift run shusky run --help'"
        )

        @Option(help: "Set Swift Package Manager path, if Package.swift is not in the root.")
        var packagePath: String?

        @Argument(help: "Hook to run. For example: pre-commit, pre-push...")
        var hook: String

        func run() throws {
            guard let hook = HookType(rawValue: hook) else {
                throw ShuskyError.runFailedDueToAnInvalidHook
            }

            let shuskyCore = ShuskyCore()

            if shuskyCore.run(hookType: hook) != 0 {
                throw ShuskyError.runFailed
            }
        }
    }

    struct Uninstall: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Uninstall shusky"
        )

        func run() throws {
            let shuskyCore = ShuskyCore()
            if shuskyCore.uninstall(gitPath: Shusky.getGitHookPath()) != 0 {
                throw ShuskyError.uninstallFailed
            }
        }
    }

    private static func getGitHookPath() -> String {
        let shell = Shell()
        let result = shell.execute("git rev-parse --git-common-dir")
        let end = result.output.endIndex
        let git = String(result.output[..<result.output.index(before: end)])
        return "\(git)/hooks/"
    }
}

Shusky.main()
