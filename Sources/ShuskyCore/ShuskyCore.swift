//
// Created by Dídac Coll Pujals on 21/05/2020.
//

import Foundation
import Yams

public final class ShuskyCore {

    public init() { }

    public func run(hookType: HookType, shuskyPath: String? = nil, packagePath: String? = nil) {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            let shuskyParser = try ShuskyHookParser(hookType: hookType, yamlContent: try shuskyFile.read())
            guard let hook = shuskyParser.hook else {
                return
            }

            executeCommand(hook: hook)

        } catch let error as ShuskyParserError {
            switch error {
            case .invalidHook(let hookError):
                switch hookError {
                case .noHookFound:
                    return
                default:
                    printc(.red, error.description())
                }
            default:
                printc(.red, error.description())
            }
        } catch {
            printc(.red, error)
        }
    }

    public func install(gitPath: String, shuskyPath: String? = nil, packagePath: String? = nil) {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            try shuskyFile.createDefaultShuskyYaml()
            let hooksParser = try ShuskyHooksParser(try shuskyFile.read())
            for hookAvailable in hooksParser.availableHooks {
                _ = try HookHandler(hook: hookAvailable, path: gitPath, packagePath: packagePath)
            }
        } catch let error as ShuskyParserError {
            printc(.red, error.description())
        } catch {
            printc(.red, "Unexpected error: \(error)")
        }
    }

    private func executeCommand(hook: Hook) {
        for command in hook.commands {
            printc(.green, shell(command.run.command))
        }

    }

    private func printc(_ color: ANSIColors, _ str: Any) {
        print(color.rawValue + "\(str)")
    }

    private func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }

}

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