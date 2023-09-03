import Files
import Foundation

extension FileManager {
    func pathExists(at path: String, kind: LocationKind) -> Bool {
        var isFolder: ObjCBool = false

        guard fileExists(atPath: path, isDirectory: &isFolder) else {
            return false
        }

        switch kind {
        case .file:
            return !isFolder.boolValue
        case .folder:
            return isFolder.boolValue
        }
    }
}

/// The Nameable protocol is used to represent objects that have a name and a path, such as files. 
protocol Nameable {
    var fileName: String { get }
    var path: String { get set }
}

/// Protocol which allow to read a file a get the content as String.
protocol Readable: Nameable {
    func read() throws -> String
}

extension Readable {
    func read() throws -> String {
        let file = try File(path: path + fileName)
        return try file.readAsString()
    }
}

/// Writable protocol contains different methods for editing a file.
protocol Writable: Nameable {
    func create() throws
    func write(_ string: String) throws
    func append(_ string: String) throws
    func delete() throws
}

extension Writable {
    func create() throws {
        let folder = try Folder(path: path)
        _ = try folder.createFileIfNeeded(withName: fileName)
    }

    func write(_ string: String) throws {
        let file = try File(path: path + fileName)
        try file.write(string)
    }

    func append(_ string: String) throws {
        let file = try File(path: path + fileName)
        try file.append(string)
    }

    func delete() throws {
        let file = try File(path: path + fileName)
        try file.delete()
    }
}

/// Main class helper for reading `.shusky.yml` file.
class ShuskyFile: Readable, Writable {
    public let fileName = ".shusky.yml"
    public var path = "./"

    public var defaultConfig: String {
        """
        pre-push:
            - echo "Shusky is ready, please configure \(fileName)"
        pre-commit:
            - echo "Shusky is ready, please configure \(fileName)"

        """
    }

    public init(path: String? = nil) {
        if let path = path {
            self.path = path
        }
    }

    /// Creates a default `.shusky.yml` file if needed.
    public func createDefaultShuskyYamlIfNeeded() throws {
        try create()
        guard let content = try? read() else {
            try write(defaultConfig)
            return
        }
        if content.isEmpty {
            try write(defaultConfig)
        }
    }
}
