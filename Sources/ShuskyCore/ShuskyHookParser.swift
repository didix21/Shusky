//
// Created by Dídac Coll Pujals on 23/05/2020.
//

import Foundation
import Yams

protocol Yamable {
    func load(_ yaml: String) throws -> [String: Any]
}

extension Yamable {
    func load(_ yaml: String) throws -> [String: Any] {
        let content = try Yams.load(yaml: yaml)
        guard let yaml = content else { throw ShuskyParserError.shuskyConfigIsEmpty }
        guard let data = yaml as? [String: Any] else { throw ShuskyParserError.isNotDict }
        return data
    }
}

public enum ShuskyParserError: Error, Equatable, CustomStringConvertible {
    case shuskyConfigIsEmpty
    case isNotDict
    case noHooksFound
    case invalidHook(Hook.HookError)

    public var description: String {
        let shusky = ".shusky.yml file"
        switch self {
        case .shuskyConfigIsEmpty:
            return "☣️  \(shusky) is empty!"
        case .isNotDict:
            return "☣️  \(shusky) hasn't the expected format!"
        case .noHooksFound:
            return "☣️  There isn't any hook in \(shusky)!"
        case let .invalidHook(error):
            return "☣️  In \(shusky) there is an invalid \(error)!"
        }
    }
}

class ShuskyHookParser: Yamable {
    let hookType: HookType
    let yamlContent: String
    private(set) var hook: Hook?

    public init(hookType: HookType, yamlContent: String) throws {
        self.hookType = hookType
        self.yamlContent = yamlContent
        hook = try parse()
    }

    private func parse() throws -> Hook {
        let data = try load(yamlContent)
        do {
            return try Hook.parse(hookType: hookType, data)
        } catch let error as Hook.HookError {
            throw ShuskyParserError.invalidHook(error)
        }
    }
}

class ShuskyHooksParser: Yamable {
    private(set) var availableHooks: [HookType] = []
    private var yaml: String

    init(_ yaml: String) throws {
        self.yaml = yaml
        try parse()
    }

    private func parse() throws {
        let data = try load(yaml)

        for hookType in HookType.allCases {
            guard (data[hookType.rawValue] as? [Any]) != nil else { continue }
            availableHooks.append(hookType)
        }

        if availableHooks.isEmpty {
            throw ShuskyParserError.noHooksFound
        }
    }
}
