//
//  Command.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

/// A struct that represents a command to run.
 struct Command: Equatable {
    private(set) var run: Run

    init(run: Run) {
        self.run = run
    }

    public static func == (lhs: Command, rhs: Command) -> Bool {
        lhs.run == rhs.run
    }
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

extension Command: Decodable {
    public enum CodingKeys: String, CodingKey {
        case run
        case swiftRun = "swift-run"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let swiftRun = try? values.decode(SwiftRun.self, forKey: .swiftRun) {
            run = Run(swiftRun)
            return
        }
        run = try values.decode(Run.self, forKey: .run)
    }
}

extension Command: CustomStringConvertible {
    public var description: String {
        run.description.magenta
    }
}
