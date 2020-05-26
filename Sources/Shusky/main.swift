import Foundation
import Yams
import ShuskyCore

let fileManager = FileManager.default
fileManager.changeCurrentDirectoryPath("/Users/didaccoll/repos/Shusky")
//let shuskyCore = ShuskyCore()
//shuskyCore.run(hookType: .preCommit)

import ArgumentParser

enum ShuskyError: Error {
    case installFailed
    case runFailed
    case runFailedDueToAnInvalidHook
    case uninstallFailed
}

struct Shusky: ParsableCommand {
    static let configuration = CommandConfiguration(
            abstract: "Shusky utilities.",
            subcommands: [Install.self, Run.self, Uninstall.self])

    struct Install: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Install all hooks available in .shusky.yml.")

        @Option(help: "Set Swift Package Manager path, if Package.swift is not in the root.")
        var packagePath: String?

        func run() throws {
            let shell = Shell()
            let result = shell.execute("git rev-parse --git-common-dir")
            let end = result.output.endIndex
            let git = String(result.output[..<result.output.index(before: end)])
            let shuskyCore = ShuskyCore()
            if shuskyCore.install(gitPath: "\(git)/hooks/", packagePath: packagePath) != 0 {
                throw ShuskyError.installFailed
            }
        }
    }

    struct Run: ParsableCommand {
        static let configuration = CommandConfiguration(
                abstract: "Use this command for running a hook in the .swift.yml"
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
            if shuskyCore.uninstall() != 0 {
                throw ShuskyError.uninstallFailed
            }
        }
    }

}

Shusky.main()
