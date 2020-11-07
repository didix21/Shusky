//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Foundation
import Yams

public enum HookType: String, CaseIterable {
    case applypatchMsg = "applypatch-msg"
    case preApplyPatch = "pre-applypatch"
    case postApplyPatch = "post-applypatch"
    case preCommit = "pre-commit"
    case preMergeCommit = "pre-merge-commit"
    case prepareCommitMsg = "prepare-commit-msg"
    case commitMsg = "commit-msg"
    case postCommit = "post-commit"
    case preRebase = "pre-rebase"
    case postCheckout = "post-checkout"
    case postMerge = "post-merge"
    case prePush = "pre-push"
}

public struct Hook: Equatable {
    public var hookType: HookType
    public var verbose: Bool
    public var commands: [Command]

    public static func parse(hookType: HookType, _ data: [String: Any]) throws -> Hook {
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
                    throw Command.CommandError.invalidRun
                }
                let json = try JSONSerialization.data(withJSONObject: dict)
                commands.append(try JSONDecoder().decode(Command.self, from: json))
            } catch let error as Command.CommandError {
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

    public enum ShuskyCodingKey: String {
        case verbose
    }

    public enum HookError: Error, Equatable, CustomStringConvertible {
        case noHookFound
        case hookIsEmpty(HookType)
        case invalidTypeInHookKey(ShuskyCodingKey, String)
        case invalidCommand(HookType, Command.CommandError)

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
}

public struct Command: Equatable, Decodable {
    public var run: Run

    public init(run: Run) {
        self.run = run
    }

    public static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.run == rhs.run
    }

    public enum ShuskyCoddingKeys: String {
        case run
    }

    public enum CommandError: Error, Equatable, CustomStringConvertible {
        case invalidData(String)
        case noCommands
        case invalidRun

        public var description: String {
            switch self {
            case let .invalidData(data):
                return "invalid data: \(data)"
            case .noCommands:
                return "has any command"
            case .invalidRun:
                return "invalid run"
            }
        }
    }
}

extension Command: CustomStringConvertible {
    public var description: String {
        run.description.magenta
    }
}

public struct Run: Equatable, Decodable {
    public var command: String
    public var path: String?
    public var critical: Bool?
    public var verbose: Bool?

    public enum ShuskyCodingKey: String, CaseIterable {
        case command
        case path
        case critical
        case verbose
    }

    public enum RunError: Error, Equatable, CustomStringConvertible {
        case invalidData(String)
        case invalidTypeInRunKey(ShuskyCodingKey, String)

        public var description: String {
            switch self {
            case let .invalidData(data):
                return "invalid data: \(data)"
            case let .invalidTypeInRunKey(key, content):
                return "invalid type in \(key): \(content)"
            }
        }
    }

    public static func == (lhs: Run, rhs: Run) -> Bool {
        lhs.command == rhs.command &&
            lhs.path == rhs.path &&
            lhs.critical == rhs.critical
    }
}

extension Run: CustomStringConvertible {
    public var description: String {
        command
    }
}
