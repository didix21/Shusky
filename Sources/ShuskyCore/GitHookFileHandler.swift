//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Foundation

class GitHookFileHandler: Writable, Readable {

    private(set) var fileName: String
    var path: String
    private var hook: HookType
    private var packagePath: String?


    public init(hook: HookType, path: String, packagePath: String? = nil) throws {
        self.hook = hook
        self.fileName = hook.rawValue
        self.path = path
        self.packagePath = packagePath
        try addHook()
    }

    private func addHook() throws {
        if let content = try? read() {
            guard !content.contains(hookCommand()) else { return }
            try append("\n" + hookCommand() + "\n")
            return
        }
        try create()
        try write(hookCommand())
        try setUserExecutablePermissions()
    }

    private func hookCommand() -> String {
        guard let packagePath = packagePath else {
            return "swift run -c release shusky run \(hook.rawValue)"
        }
        return hookCommand(with: packagePath)
    }

    private func hookCommand(with packagePath: String) -> String {
        "swift run -c release --package-path \(packagePath) shusky run \(hook.rawValue)"
    }

    private func setUserExecutablePermissions() throws {
        let fm = FileManager.default
        var attributes = [FileAttributeKey: Any]()
        attributes[.posixPermissions] = 777
        try fm.setAttributes(attributes, ofItemAtPath: path + fileName)
    }

}