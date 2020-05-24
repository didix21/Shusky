//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Foundation
import Yams

public protocol Describable {
    func description() -> String
}

public enum HookType: String {
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

    static func getAll() -> [HookType] {
        [.applypatchMsg, preApplyPatch, .postApplyPatch, .preCommit,
         .preMergeCommit, .prepareCommitMsg, .commitMsg, .postCommit,
         .preRebase, .postCheckout, .postMerge, .prePush]
    }
}

public struct Hook: Equatable {
    public var hookType: HookType
    public var verbose: Bool
    public var commands: [Command]

    public static func parse(hookType: HookType, _ data: [String: Any]) throws -> Hook {

        guard let hook = data[hookType.rawValue] as? [Any] else {
            if  data[hookType.rawValue] != nil {
                throw HookError.hookIsEmpty(hookType)
            }
            throw HookError.noHookFound
        }

        let commands = try self.parse(hookType, hook: hook)

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

        for command in hook  {
            do {
                commands.append(try Command.parse(command))
            } catch let error as Command.CommandError {
                throw HookError.invalidCommand(hookType, error)
            }
        }

        return commands
    }

    public static func ==(lhs: Hook, rhs: Hook) -> Bool {
        lhs.hookType == rhs.hookType &&
                lhs.verbose == rhs.verbose &&
                lhs.commands == rhs.commands
    }

    public enum ShuskyCodingKey: String {
        case verbose
    }

    public enum HookError: Error, Equatable, Describable {
        case noHookFound
        case hookIsEmpty(HookType)
        case invalidTypeInHookKey(ShuskyCodingKey, String)
        case invalidCommand(HookType, Command.CommandError)

        public func description() -> String {
            switch self {
            case .noHookFound:
                return "no hook found"
            case .hookIsEmpty(let hook):
                return "hook: \(hook.rawValue) is empty"
            case .invalidTypeInHookKey(let key, let content):
                return "invalid type in \(key.rawValue): \(content)"
            case .invalidCommand(let hook, let error):
                return "invalid command in \(hook.rawValue): \(error.description())"
            }
        }
    }
}

public struct Command: Equatable {
    public var run: Run

    public static func parse(_ data: Any) throws -> Command {
        if let command = data as? String {
            return Command(run: Run(command: command))
        }

        guard let dict = data as? [String: Any] else {
            throw CommandError.invalidData("\(data)")
        }

        if let run = dict[ShuskyCoddingKeys.run.rawValue] {
            do {
                return try Command(run: Run.parse(run))
            } catch let error as Run.RunError {
                throw CommandError.invalidRun(ShuskyCoddingKeys.run, error)
            }
        }

        throw CommandError.noCommands
    }

    public static func ==(lhs: Command, rhs: Command) -> Bool {
        lhs.run == rhs.run
    }

    public enum ShuskyCoddingKeys: String {
        case run
    }

    public enum CommandError: Error, Equatable, Describable {
        case invalidData(String)
        case noCommands
        case invalidRun(ShuskyCoddingKeys, Run.RunError)

        public func description() -> String {
            switch self {
            case .invalidData(let data):
                return "invalid data: \(data)"
            case .noCommands:
                return "has any command"
            case .invalidRun(let key, let error):
                return "invalid \(key): \(error.description())"
            }
        }
    }
}

public struct Run: Equatable {
    public var command: String
    public var path: String?
    public var critical: Bool?
    public var verbose: Bool?

    public static func parse(_ data: Any) throws -> Run {

        guard let runContent = data as? [String: Any] else {
            throw RunError.invalidData("\(data)")
        }

        return try self.parse(data: runContent)
    }

    public static func parse(data: [String: Any]) throws -> Run {
        var values: [(ShuskyCodingKey, Any)] = []
        for key in ShuskyCodingKey.getAllKeys() {
            guard let value = data[key.rawValue] else { continue }
            values.append((key, value))
        }

        return try ShuskyCodingType.mapTo(ShuskyCodingKey.mapTo(values))
    }

    public enum ShuskyCodingKey: String {
        case command
        case path
        case critical
        case verbose

        public static func getAllKeys() -> [ShuskyCodingKey] {
            [.command, .path, .critical, .verbose]
        }

        public static func mapTo(_ keys: [(ShuskyCodingKey, Any)]) throws -> [ShuskyCodingType] {
            var shuskyTypes: [ShuskyCodingType] = []
            for (key, value) in keys {
                switch key {
                case .command:
                    let value = try key.tryString(value)
                    shuskyTypes.append(.command(value))
                case .path:
                    let value = try key.tryString(value)
                    shuskyTypes.append(.path(value))
                case .critical:
                    let value = try key.tryBool(value)
                    shuskyTypes.append(.critical(value))
                case .verbose:
                    let value = try key.tryBool(value)
                    shuskyTypes.append(.verbose(value))
                }
            }

            return shuskyTypes
        }

        private func tryString( _ value: Any) throws -> String {
            guard let val = value as? String else {
                throw RunError.invalidTypeInRunKey(self, "\(value)")
            }
            return val
        }

        private func tryBool(_ value: Any) throws -> Bool {
            guard let val = value as? Bool else {
                throw RunError.invalidTypeInRunKey(self, "\(value)")
            }
            return val
        }

    }

    public enum ShuskyCodingType {
        case command(String)
        case path(String?)
        case critical(Bool?)
        case verbose(Bool?)

        public static func mapTo(_ keys: [ShuskyCodingType]) throws -> Run {
            var optCommand: String?
            var path: String?
            var critical: Bool?
            var verbose: Bool?

            for key in keys {
                switch key {
                case .command(let value): optCommand = value
                case .path(let value): path = value
                case .critical(let value): critical = value
                case .verbose(let value): verbose = value
                }
            }

            guard let command = optCommand else {
                throw RunError.invalidTypeInRunKey(.command, "\(String(describing: optCommand))")
            }

            return Run(command: command, path: path, critical: critical, verbose: verbose)

        }
    }

    public enum RunError: Error, Equatable, Describable {
        case invalidData(String)
        case invalidTypeInRunKey(ShuskyCodingKey, String)

        public func description() -> String {
            switch self {
            case .invalidData(let data):
                return "invalid data: \(data)"
            case .invalidTypeInRunKey(let key, let content):
                return "invalid type in \(key): \(content)"
            }
        }
    }

    public static func ==(lhs: Run, rhs: Run) -> Bool {
        lhs.command == rhs.command &&
                lhs.path == rhs.path &&
                lhs.critical == rhs.critical
    }
}




