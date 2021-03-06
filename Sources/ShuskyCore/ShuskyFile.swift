import Files
import Foundation

public extension FileManager {
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

public protocol Nameable {
    var fileName: String { get }
    var path: String { get set }
}

public protocol Readable: Nameable {
    func read() throws -> String
}

public extension Readable {
    func read() throws -> String {
        let file = try File(path: path + fileName)
        return try file.readAsString()
    }
}

public protocol Writable: Nameable {
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
