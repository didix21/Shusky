//
//  Run.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

/// A struct that represents a command to run.
struct Run: Equatable, Decodable, RunOptions {
    /// The command to run.
    public var command: String
    /// The path where the command will be executed.
    public var path: String?
    /// If the command must fail the whole process or continue.
    public var critical: Bool?
    /// If the command must be verbose.
    public var verbose: Bool?

    public enum CodingKeys: String, CodingKey {
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

    /// Create a new instance of Run.
    /// - Parameters:
    ///   - command: The command to run.
    ///   - path: The path where the command will be executed.
    ///   - critical: If the command must fail the whole process or continue.
    ///   - verbose: If the command must be verbose.
    init(command: String, path: String? = nil, critical: Bool? = nil, verbose: Bool? = nil) {
        self.command = command
        self.path = path
        self.critical = critical
        self.verbose = verbose
    }
}

extension Run: CustomStringConvertible {
    public var description: String {
        command
    }
}

extension Run {
    /// Extends Run allowing to execute the command's binary or building it if doesn't exists with `swift run`.
    init(_ swiftRun: SwiftRun) {
        var binaryPath = Self.getBinaryPath(swiftRun)
        binaryPath += "/\(swiftRun.command.split(separator: " ")[0])"
        let fileLocation = FileManager.default
        if fileLocation.pathExists(at: binaryPath, kind: .file) {
            self = Self.buildBinaryCommand(swiftRun)
        } else {
            self = Self.buildSwiftRunCommand(swiftRun)
        }
    }

    private static func getBinaryPath(_ swiftRun: SwiftRun) -> String {
        var binaryPath = ""
        if let buildPath = swiftRun.buildPath {
            binaryPath += buildPath
        } else if let packagePath = swiftRun.packagePath {
            if packagePath.starts(with: "./") {
                binaryPath += "\(packagePath)/.build"
            } else {
                binaryPath += "./\(packagePath)/.build"
            }
        } else {
            binaryPath += "./.build"
        }
        if let configuration = swiftRun.configuration {
            binaryPath += "/\(configuration)"
        } else {
            binaryPath += "/debug"
        }
        return binaryPath
    }

    private static func buildBinaryCommand(_ swiftRun: SwiftRun) -> Run {
        var command = Self.getBinaryPath(swiftRun)
        command += "/\(swiftRun.command)"
        return Run(command: command, critical: swiftRun.critical, verbose: swiftRun.verbose)
    }

    private static func buildSwiftRunCommand(_ swiftRun: SwiftRun) -> Run {
        var command = "swift run"
        if let configuration = swiftRun.configuration {
            command += " -c \(configuration)"
        }
        if let buildPath = swiftRun.buildPath {
            command += " --build-path \(buildPath)"
        }
        if let packagePath = swiftRun.packagePath {
            command += " --package-path \(packagePath)"
        }
        if let jobs = swiftRun.jobs {
            command += " --jobs \(jobs)"
        }
        command += " \(swiftRun.command)"
        return Run(command: command)
    }
}
