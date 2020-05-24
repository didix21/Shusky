//
// Created by Dídac Coll Pujals on 24/05/2020.
//

import Foundation

enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"

    func name() -> String {
        switch self {
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .magenta: return "Magenta"
        case .cyan: return "Cyan"
        case .white: return "White"
        }
    }

    static func all() -> [ANSIColors] {
        [.black, .red, .green, .yellow, .blue, .magenta, .cyan, .white]
    }
}

protocol Printable {
    func print(_ str: Any)
    func print(_ str: Any, terminator: String)
    func printState(_ commandState: HookHandler.CommandState, _ command: Command)
    func printc(_ color: ANSIColors, _ str: Any)
    func printc(_ color: ANSIColors, _ str: Any, terminator: String)
}

class Printer: Printable {
    func print(_ str: Any) {
        Swift.print(str)
    }

    func print(_ str: Any, terminator: String) {
        Swift.print(str, terminator: terminator)
    }

    func printState(_ commandState: HookHandler.CommandState, _ command: Command) {
        let runCommand = command.run.command
        switch commandState {
        case .running:
            printc(.white, commandState.describe(runCommand))
        case .success:
            printc(.green, commandState.describe(runCommand))
        case .error:
            printc(.red, commandState.describe(runCommand))
        case .isNotCritical:
            printc(.yellow, commandState.describe(runCommand))
        }
    }

    func printc(_ color: ANSIColors, _ str: Any) {
        Swift.print(color.rawValue + "\(str)")
    }

    func printc(_ color: ANSIColors, _ str: Any, terminator: String) {
        Swift.print(color.rawValue + "\(str)", terminator: terminator)
    }
}

final class HookHandler {
    let hook: Hook
    let shell: Executable
    let printer: Printable
    init(hook: Hook, shell: Executable, printer: Printable) {
        self.hook = hook
        self.shell = shell
        self.printer = printer
    }

    public func run() -> Int32 {
        for command in hook.commands {
            printer.printState(.running, command)
            let result = getResult(command: command)
            switch result {
            case .error(let errorCode):
                printer.printState(result, command)
                return errorCode
            default:
                printer.printState(result, command)
            }
        }

        return 0
    }

    private func isVerbose(command: Command) -> Bool {
        guard let runVerbose = command.run.verbose else {
            return hook.verbose
        }

        return runVerbose
    }

    private func isCritical(command: Command) -> Bool {
        guard let critical = command.run.critical else {
            return true
        }

        return critical
    }

    private func getResult(command: Command) -> CommandState {
        var result: ShellResult

        if isVerbose(command: command) {
            result = runVerbose(command)
        } else {
            result = runLaconic(command)
        }

        guard result.status == 0 else {
            if !isCritical(command: command) {
                return .isNotCritical(errorCode: result.status)
            }
            return .error(errorCode: result.status)
        }

        return .success
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
        shell.execute(command.run.command)
    }

    enum CommandState {
        case running
        case success
        case error(errorCode: Int32)
        case isNotCritical(errorCode: Int32)

        func describe(_ command: String) -> String {
            switch self {
            case .running:
                return "⏳ Running \(command)"
            case .success:
                return "✔ \(command) has successfully executed\n"
            case .error(let errorCode):
                return "❌ \(command) has failed with error \(errorCode)\n"
            case .isNotCritical(let errorCode):
                return "⚠️ \(command) has failed with error \(errorCode)\n"

            }
        }
        
    }

}