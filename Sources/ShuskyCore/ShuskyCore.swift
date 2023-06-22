//
// Created by Dídac Coll Pujals on 21/05/2020.
//

import Foundation
import Rainbow
import Yams

/// A class that provides core functionality for Shusky.
///
/// The main features are:
/// - Parsing the Shusky YAML file and get the Git hooks.
/// - Installing the Git hooks.
/// - Uninstalling the Git hooks.
public final class ShuskyCore {
    let printer = Printer()

    /// Initializes a new instance of `ShuskyCore`.
    public init() {}

    /// Runs a hook of the specified type.
    /// - Parameters:
    ///   - hookType: The type of hook to run.
    ///   - shuskyPath: The path to the Shusky YAML file.
    ///   - packagePath: The path to the package.
    /// - Returns: An exit code.
    public func run(hookType: HookType, shuskyPath: String? = nil, packagePath _: String? = nil) -> Int32 {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            let shuskyParser = try ShuskyHookParser(hookType: hookType, yamlContent: try shuskyFile.read())
            guard let hook = shuskyParser.hook else {
                return 1
            }

            return executeCommand(hook: hook)

        } catch let error as ShuskyParserError {
            let errorDescription = error.description.red
            switch error {
            case let .invalidHook(hookError):
                switch hookError {
                case .noHookFound:
                    return 0
                default:
                    printer.print(errorDescription)
                }
            default:
                printer.print(errorDescription)
            }
        } catch {
            printer.print("\(error)".red)
        }

        return 1
    }

    /// Installs hooks.
    /// - Parameters:
    ///   - gitPath: The path to the Git hooks directory.
    ///   - shuskyPath: The path to the Shusky YAML file.
    ///   - packagePath: The path to the package.
    ///   - all: A Boolean value that indicates whether to install all hooks.
    ///   - overwrite: A Boolean value that indicates whether to overwrite existing hooks.
    /// - Returns: An exit code.
    public func install(
        gitPath: String,
        shuskyPath: String? = nil,
        packagePath: String? = nil,
        all: Bool = false,
        overwrite: Bool = false
    ) -> Int32 {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            try shuskyFile.createDefaultShuskyYamlIfNeeded()

            if all {
                try installAll(gitPath: gitPath, packagePath: packagePath, overwrite: overwrite)
            } else {
                try installAvailableHooks(
                    shuskyFile: shuskyFile,
                    gitPath: gitPath,
                    packagePath: packagePath,
                    overwrite: overwrite
                )
            }

            return 0

        } catch let error as ShuskyParserError {
            printer.print(error.description.red)
        } catch {
            printer.print("Unexpected error: \(error)".red)
        }

        return 1
    }

    private func installAvailableHooks(
        shuskyFile: ShuskyFile,
        gitPath: String,
        packagePath: String?,
        overwrite: Bool
    ) throws {
        let hooksParser = try ShuskyHooksParser(try shuskyFile.read())

        for hookAvailable in hooksParser.availableHooks {
            let gitHookFileHandler = GitHookFileHandler(
                hook: hookAvailable,
                path: gitPath,
                packagePath: packagePath,
                overwrite: overwrite
            )
            try gitHookFileHandler.addHook()
        }

        for hookNotAvailable in HookType.allCases where !hooksParser.availableHooks.contains(hookNotAvailable) {
            let gitHookFileHandler = GitHookFileHandler(
                hook: hookNotAvailable,
                path: gitPath
            )
            try gitHookFileHandler.deleteHook()
        }
    }

    private func installAll(gitPath: String, packagePath: String?, overwrite: Bool) throws {
        for hook in HookType.allCases {
            let gitHookFileHandler = GitHookFileHandler(
                hook: hook,
                path: gitPath,
                packagePath: packagePath,
                overwrite: overwrite
            )
            try gitHookFileHandler.addHook()
        }
    }

    private func executeCommand(hook: Hook) -> Int32 {
        let commandHandler = HookHandler(hook: hook, shell: Shell(), printer: printer)
        return commandHandler.run()
    }

    /// Uninstalls hooks.
    /// - Parameter gitPath: The path to the Git hooks directory.
    /// - Returns: An exit code.
    public func uninstall(gitPath: String) -> Int32 {
        for hook in HookType.allCases {
            let gitHookFileHandler = GitHookFileHandler(hook: hook, path: gitPath)
            do {
                try gitHookFileHandler.deleteHook()
            } catch {
                return 1
            }
        }

        return 0
    }
}