//
// Created by Dídac Coll Pujals on 11/05/2020.
//

import Foundation
import Yams

public protocol Parseable {
    static func parse(_ data: Any) throws -> Self
}

public enum ShuskyParserError: Error, Equatable {
    case shuskyConfigIsEmpty
    case isNotDict
    case noHookFound
    case noCommands
    case invalidDataInHook
    case invalidTypeInHookKey(Hook.ShuskyCodingKey)
    case noConFigInRun
    case commandNotDefinedInRun
    case invalidTypeInRunKey(Run.ShuskyCodingKey)
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
}

class ShuskyParser {
    let hookType: HookType
    let yamlContent: String
    private(set) var hook: Hook?

    public init(hookType: HookType, yamlContent: String) throws {
        self.hookType = hookType
        self.yamlContent = yamlContent
        self.hook = try self.parse()
    }

    private func parse() throws -> Hook {
        let data = try Yams.load(yaml: yamlContent)
        guard let yaml = data else { throw ShuskyParserError.shuskyConfigIsEmpty }

        return try Hook.parse(hookType: hookType, yaml)
    }

    private func parse(hook: [Any]) throws -> [Command]? {
        var commands: [Command] = []

        for command in hook  {
            commands.append(try Command.parse(command))
        }

        guard !commands.isEmpty else {
            return nil
        }

        return commands
    }

}

public struct Hook: Equatable {
    public var hookType: HookType
    public var verbose: Bool
    public var commands: [Command]

    public static func parse(hookType: HookType, _ data: Any) throws -> Hook {
        guard let data = data as? [String: Any] else {
            throw ShuskyParserError.isNotDict
        }

        guard let hook = data[hookType.rawValue] as? [Any] else {
            throw ShuskyParserError.noHookFound
        }

        guard let commands = try self.parse(hook: hook) else {
            throw ShuskyParserError.noCommands
        }

        guard let verbose = data[ShuskyCodingKey.verbose.rawValue] as? Bool else {
            throw ShuskyParserError.invalidTypeInHookKey(.verbose)
        }

        return Hook(hookType: hookType, verbose: verbose, commands: commands)
    }

    private static func parse(hook: [Any]) throws -> [Command]? {
        var commands: [Command] = []

        for command in hook  {
            commands.append(try Command.parse(command))
        }

        guard !commands.isEmpty else {
            return nil
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
}

public struct Command: Equatable, Parseable {
    public var run: Run

    public static func parse(_ data: Any) throws -> Command {
        if let command = data as? String {
            return Command(run: Run(command: command))
        }

        guard let dict = data as? [String: Any] else {
            throw ShuskyParserError.invalidDataInHook
        }

        if let run = dict[ShuskyCoddingKeys.run.rawValue] {
            return try Command(run: Run.parse(run))
        }

        throw ShuskyParserError.noCommands
    }

    public static func ==(lhs: Command, rhs: Command) -> Bool {
        lhs.run == rhs.run
    }

    public enum ShuskyCoddingKeys: String {
        case run
    }
}

public struct Run: Equatable, Parseable {
    public var command: String
    public var path: String?
    public var critical: Bool?
    public var verbose: Bool?

    public static func parse(_ data: Any) throws -> Run {

        guard let runContent = data as? [String: Any] else {
            throw ShuskyParserError.noCommands
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
            guard let value = value as? String else {
                throw ShuskyParserError.invalidTypeInRunKey(self)
            }
            return value
        }

        private func tryBool(_ value: Any) throws -> Bool {
            guard let value = value as? Bool else {
                throw ShuskyParserError.invalidTypeInRunKey(self)
            }
            return value
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
                throw ShuskyParserError.invalidTypeInRunKey(.command)
            }

            return Run(command: command, path: path, critical: critical, verbose: verbose)

        }
    }

    public static func ==(lhs: Run, rhs: Run) -> Bool {
        lhs.command == rhs.command &&
                lhs.path == rhs.path &&
                lhs.critical == rhs.critical
    }
}




