//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Foundation

/**
 A class that handles the addition and deletion of Git hooks to a file.
 
 `GitHookFileHandler` conforms to the `Writable` and `Readable` protocols, which provide methods for writing and reading files, respectively.
 */
class GitHookFileHandler: Writable, Readable {
    private(set) var fileName: String
    var path: String
    private var hook: HookType
    private var packagePath: String?
    private let overwrite: Bool
    private var swiftRun = "swift run -c release"
    private var swiftRunWithPath = "swift run -c release --package-path"
    private var shuskyRun = "shusky run"
    private var shuskyBinary = ".build/release/shusky"
    private lazy var gitHookRun: String = {
        """
        #!/bin/sh

        if [[ -f \(self.shuskyBinary) ]]; then
            \(self.shuskyBinary) run \(self.hook.rawValue)
        else
            \(self.swiftRun) \(self.shuskyRun) \(self.hook.rawValue)
        fi

        """
    }()

    private lazy var gitHookRunWithPackagePath: (String) -> String = { (packagePath: String) -> String in
        """
        #!/bin/sh

        if [[ -f ./\(packagePath)/\(self.shuskyBinary) ]]; then
            ./\(packagePath)/\(self.shuskyBinary) run \(self.hook.rawValue)
        else
            \(self.swiftRunWithPath) \(packagePath) \(self.shuskyRun) \(self.hook.rawValue)
        fi

        """
    }

    /**
     Initializes a new GitHookFileHandler instance.
     
     - Parameters:
        - hook: The type of hook to handle.
        - path: The path to the file to handle.
        - packagePath: The path to the package to use.
        - overwrite: Whether to overwrite the file if it already exists.
     */
    public init(hook: HookType, path: String, packagePath: String? = nil, overwrite: Bool = false) {
        self.hook = hook
        fileName = hook.rawValue
        self.path = path
        self.packagePath = packagePath
        self.overwrite = overwrite
    }

    /**
     Adds the hook to the file.
     
     - Throws: An error if the hook cannot be added.
     */
    public func addHook() throws {
        if !overwrite, let content = try? read() {
            guard !content.contains(hookCommand()) else { return }
            try append("\n" + hookCommand())
            try setUserExecutablePermissions()
            return
        }
        try create()
        try write(hookCommand())
        try setUserExecutablePermissions()
    }

    /**
     Deletes the hook from the file.
     
     - Throws: An error if the hook cannot be deleted.
     */
    public func deleteHook() throws {
        guard let content = try? read() else {
            return
        }
        packagePath = getPackagePath(content)
        if content.count == hookCommand().count {
            try delete()
            return
        }
        guard let startIndex = content.index(of: hookCommand()),
              let endIndex = content.endIndex(of: hookCommand())
        else {
            return
        }

        let deletedHook = String(content[..<startIndex] + content[endIndex...])

        try write(deletedHook)
    }

    private func getPackagePath(_ content: String) -> String? {
        guard let startIndex = content.endIndex(of: "\(swiftRunWithPath) "),
              let endIndex = content.index(of: " \(shuskyRun) \(hook.rawValue)\n")
        else {
            return nil
        }
        return String(content[startIndex ... content.index(before: endIndex)])
    }

    private func hookCommand() -> String {
        guard let packagePath = packagePath else {
            return gitHookRun
        }
        return gitHookRunWithPackagePath(packagePath)
    }

    private func setUserExecutablePermissions() throws {
        let fm = FileManager.default
        let attributes: [FileAttributeKey: Any] = [
            .posixPermissions: 0o755,
        ]
        try fm.setAttributes(attributes, ofItemAtPath: path + fileName)
    }
}