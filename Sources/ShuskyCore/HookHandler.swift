//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Files
import Foundation
import Rainbow

final class HookHandler {
    let hook: Hook
    let shell: Executable
    let printer: Printable
    let stderrFile: String
    let stdoutFile: String
    init(
        hook: Hook,
        shell: Executable,
        printer: Printable,
        stderrFile: String = "/var/tmp/shusky_stderr",
        stdoutFile: String = "/var/tmp/shusky_stdout"
    ) {
        self.hook = hook
        self.shell = shell
        self.printer = printer
        self.stderrFile = stderrFile
        self.stdoutFile = stdoutFile
    }

    public func run() -> Int32 {
        guard !isSkipEnabled() else { return 0 }
        for command in hook.commands {
            printer.print(CommandState.running(command))
            let result = getResult(command: command)
            switch result {
            case let .error(_, errorCode):
                printer.print(result)
                return errorCode
            default:
                printer.print(result)
            }
        }

        return 0
    }

    private func getResult(command: Command) -> CommandState {
        let commandResolver = CommandConfigurationResolver(globalVerbose: hook.verbose, runOptions: command.run)
        let conf = commandResolver.evaluateConfiguration()
        let result: ShellResult

        if conf.verbose {
            result = runVerbose(command)
        } else {
            result = runLaconic(command)
        }

        guard result.status == 0 else {
            if !conf.verbose {
                printer.print(result.output)
                if let stdout = getStdOut() {
                    printer.print(stdout)
                }
                if let stderr = getStdErr() {
                    printer.print(stderr)
                }
            }
            if !conf.critical {
                return .isNotCritical(command, errorCode: result.status)
            }
            return .error(command, errorCode: result.status)
        }

        return .success(command)
    }

    private func getStdErr() -> String? {
        var outError: String?
        if let stderr = try? File(path: stderrFile) {
            if let errors = try? stderr.readAsString() {
                outError = errors
            }
            try? stderr.delete()
        }
        return outError
    }

    private func getStdOut() -> String? {
        var out: String?
        if let stdout = try? File(path: stdoutFile) {
            if let output = try? stdout.readAsString() {
                out = output
            }
            try? stdout.delete()
        }
        return out
    }

    private func runVerbose(_ command: Command) -> ShellResult {
        shell.executeWithRTProgress(command.run.command) { [weak self] progress in
            if progress.contains("\n") {
                self?.printer.print(progress, terminator: "")
            } else {
                self?.printer.print(progress)
            }
        }
    }

    private func runLaconic(_ command: Command) -> ShellResult {
        shell.execute(command.run.command + " >\(stdoutFile) 2>\(stderrFile)")
    }

    private func isSkipEnabled() -> Bool {
        if getEnv(.skipShusky) != nil {
            return true
        }
        return false
    }

    private func getEnv(_ param: ShuskyEnv) -> UnsafeMutablePointer<Int8>! {
        getenv(param.rawValue)
    }

    enum CommandState: CustomStringConvertible {
        case running(Command)
        case success(Command)
        case error(Command, errorCode: Int32)
        case isNotCritical(Command, errorCode: Int32)

        var description: String {
            switch self {
            case let .running(command):
                return "⏳ Running \(command)"
            case let .success(command):
                return " ✔".green + " \(command) \("has been successfully executed".green)\n"
            case let .error(command, errorCode):
                return "❌  \(command) \("has failed with error \(errorCode)".red)\n"
            case let .isNotCritical(command, errorCode):
                return "⚠️  \(command) \("has failed with error \(errorCode)".yellow)\n"
            }
        }
    }

    enum ShuskyEnv: String {
        case skipShusky = "SKIP_SHUSKY"
    }
}
