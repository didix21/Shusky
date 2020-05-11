import Files

public protocol Nameable {
    var fileName: String { get }
    var path: String { get }
}


public protocol Readable: Nameable {
    func read() throws -> String
}

extension Readable {
    public func read() throws -> String {
        let file = try File(path: self.path + self.fileName)
        return try file.readAsString()
    }
}

public protocol Writable: Nameable {
    func create() throws
    func write(_ string: String) throws
    func append(_ string: String) throws
}

extension  Writable {
    func create() throws {
       let folder = try Folder(path: self.path)
       _ = try folder.createFileIfNeeded(withName: self.fileName)
    }

    func write(_ string: String) throws {
        let file = try File(path: self.path + self.fileName)
        try file.write(string)
    }

    func append(_ string: String) throws {
        let file = try File(path: self.path + self.fileName)
        try file.append(string)
    }
}

class ShuskyFile: Readable, Writable {
    public let fileName = ".shusky.yml"
    public let path = "./"

    public var defaultConfig: String {
        """
        pre-commit:
            - echo "Shusky is ready, please configure \(self.fileName)
        """
    }

    public func createDefaultShuskyYaml() throws {
        try create()
        try write(defaultConfig)
    }
}


