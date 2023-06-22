//
//  SwiftRun.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 21/2/21.
//

import Foundation

enum ConfigurationType: String {
    case release
    case debug
}

/// A struct that represents a command to run with `swift run`.
struct SwiftRun: Decodable, CommandBehaviorProtocol, Equatable {
    public let command: String
    public let verbose: Bool?
    public let critical: Bool?
    public let buildPath: String?
    public let configuration: ConfigurationType?
    public let jobs: Int?
    public let packagePath: String?

    public enum CodingKeys: String, CodingKey {
        case command
        case verbose
        case critical
        case buildPath = "build-path"
        case configuration
        case jobs
        case packagePath = "package-path"
    }

    init(
        command: String,
        verbose: Bool?,
        critical: Bool?,
        buildPath: String?,
        configuration: ConfigurationType?,
        jobs: Int?,
        packagePath: String?
    ) {
        self.command = command
        self.verbose = verbose
        self.critical = critical
        self.buildPath = buildPath
        self.configuration = configuration
        self.jobs = jobs
        self.packagePath = packagePath
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        command = try values.decode(String.self, forKey: .command)
        verbose = try? values.decode(Bool.self, forKey: .verbose)
        critical = try? values.decode(Bool.self, forKey: .critical)
        buildPath = try? values.decode(String.self, forKey: .buildPath)
        if let strConfiguration = try? values.decode(String.self, forKey: .configuration) {
            configuration = ConfigurationType(rawValue: strConfiguration)
        } else {
            configuration = nil
        }
        jobs = try? values.decode(Int.self, forKey: .jobs)
        packagePath = try? values.decode(String.self, forKey: .packagePath)
    }
}
