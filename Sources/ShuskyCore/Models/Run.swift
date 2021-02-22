//
//  Run.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

public struct Run: Equatable, Decodable {
    public var command: String
    public var path: String?
    public var critical: Bool?
    public var verbose: Bool?

    public enum ShuskyCodingKey: String {
        case command
        case path
        case critical
        case verbose
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
