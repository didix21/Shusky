//
//  Hook.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation


/// A struct that represents a hook to be run.
struct Hook: Equatable {
    private(set) var hookType: HookType
    private(set) var verbose: Bool
    private(set) var commands: [Command]

    /// Parses the hook data and returns a `Hook` instance.
    /// - Parameters:
    ///   - hookType: The type of hook to parse.
    ///   - data: The data to parse.
    /// - Throws: A `HookError` if the hook is empty or not found, or if the verbose key has an invalid type.
    /// - Returns: A `Hook` instance.
    static func parse(hookType: HookType, _ data: [String: Any]) throws -> Hook {
        guard let hook = data[hookType.rawValue] as? [Any] else {
            if data[hookType.rawValue] != nil {
                throw HookError.hookIsEmpty(hookType)
            }
            throw HookError.noHookFound
        }

        let commands = try parse(hookType, hook: hook)

        guard let verbose = data[ShuskyCodingKey.verbose.rawValue] as? Bool else {
            guard let content = data[ShuskyCodingKey.verbose.rawValue] else {
                return Hook(hookType: hookType, verbose: true, commands: commands)
            }
            throw HookError.invalidTypeInHookKey(.verbose, "\(content)")
        }

        return Hook(hookType: hookType, verbose: verbose, commands: commands)
    }

    private static func parse(_ hookType: HookType, hook: [Any]) throws -> [Command] {
        var commands: [Command] = []

        for command in hook {
            do {
                if let command = command as? String {
                    commands.append(Command(run: Run(command: command)))
                    continue
                }

                guard let dict = command as? [String: [String: Any]] else {
                    throw CommandError.invalidRun
                }
                let json = try JSONSerialization.data(withJSONObject: dict)
                commands.append(try JSONDecoder().decode(Command.self, from: json))
            } catch let error as CommandError {
                throw HookError.invalidCommand(hookType, error)
            }
        }

        return commands
    }

    public static func == (lhs: Hook, rhs: Hook) -> Bool {
        lhs.hookType == rhs.hookType &&
            lhs.verbose == rhs.verbose &&
            lhs.commands == rhs.commands
    }
}

/// An enum that defines errors that can occur when handling a hook.
public enum HookError: Error, Equatable, CustomStringConvertible {
    case noHookFound
    case hookIsEmpty(HookType)
    case invalidTypeInHookKey(ShuskyCodingKey, String)
    case invalidCommand(HookType, CommandError)
    
    public var description: String {
        switch self {
        case .noHookFound:
            return "no hook found"
        case let .hookIsEmpty(hook):
            return "hook: \(hook.rawValue) is empty"
        case let .invalidTypeInHookKey(key, content):
            return "invalid type in \(key.rawValue): \(content)"
        case let .invalidCommand(hook, error):
            return "invalid command in \(hook.rawValue): \(error)"
        }
    }
}

/// An enum that defines the keys used to parse a hook.
public enum ShuskyCodingKey: String {
    case verbose
}

