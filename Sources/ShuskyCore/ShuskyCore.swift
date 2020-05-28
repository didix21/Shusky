//
// Created by Dídac Coll Pujals on 21/05/2020.
//

import Foundation
import Yams

public final class ShuskyCore {
    let printer = Printer()
    public init() {}

    public func run(hookType: HookType, shuskyPath: String? = nil, packagePath _: String? = nil) -> Int32 {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            let shuskyParser = try ShuskyHookParser(hookType: hookType, yamlContent: try shuskyFile.read())
            guard let hook = shuskyParser.hook else {
                return 1
            }

            return executeCommand(hook: hook)

        } catch let error as ShuskyParserError {
            switch error {
            case let .invalidHook(hookError):
                switch hookError {
                case .noHookFound:
                    return 0
                default:
                    printer.printc(.red, error.description())
                }
            default:
                printer.printc(.red, error.description())
            }
        } catch {
            printer.printc(.red, error)
        }

        return 1
    }

    public func install(gitPath: String, shuskyPath: String? = nil, packagePath: String? = nil) -> Int32 {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            try shuskyFile.createDefaultShuskyYaml()
            let hooksParser = try ShuskyHooksParser(try shuskyFile.read())
            for hookAvailable in hooksParser.availableHooks {
                let gitHookFileHandler = GitHookFileHandler(hook: hookAvailable, path: gitPath, packagePath: packagePath)
                try gitHookFileHandler.addHook()
            }

            return 0

        } catch let error as ShuskyParserError {
            printer.printc(.red, error.description())
        } catch {
            printer.printc(.red, "Unexpected error: \(error)")
        }

        return 1
    }

    private func executeCommand(hook: Hook) -> Int32 {
        let commandHandler = HookHandler(hook: hook, shell: Shell(), printer: printer)
        return commandHandler.run()
    }

    public func uninstall() -> Int32 {
        1
    }
}
