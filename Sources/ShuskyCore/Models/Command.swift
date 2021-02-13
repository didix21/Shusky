//
//  Command.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

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
