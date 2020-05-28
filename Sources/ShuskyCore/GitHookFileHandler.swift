//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Foundation

class GitHookFileHandler: Writable, Readable {
    private(set) var fileName: String
    var path: String
    private var hook: HookType
    private var packagePath: String?
    private static var swiftRun = "swift run -c release"
    private static var swiftRunWithPath = "swift run -c release --package-path"
    private static var shuskyRun = "shusky run"

    public init(hook: HookType, path: String, packagePath: String? = nil) {
        self.hook = hook
        fileName = hook.rawValue
        self.path = path
        self.packagePath = packagePath
    }

    public func addHook() throws {
        if let content = try? read() {
            guard !content.contains(hookCommand()) else { return }
            try append("\n" + hookCommand())
            try setUserExecutablePermissions()
            return
        }
        try create()
        try write(hookCommand())
        try setUserExecutablePermissions()
    }

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
            let endIndex = content.endIndex(of: hookCommand()) else {
            return
        }

        let deletedHook = String(content[..<startIndex] + content[endIndex...])

        try write(deletedHook)
    }

    private func getPackagePath(_ content: String) -> String? {
        guard let startIndex = content.endIndex(of: "\(Self.swiftRunWithPath) "),
            let endIndex = content.index(of: " \(Self.shuskyRun) \(hook.rawValue)\n") else {
            return nil
        }
        return String(content[startIndex ... content.index(before: endIndex)])
    }

    private func hookCommand() -> String {
        guard let packagePath = packagePath else {
            return "\(Self.swiftRun) \(Self.shuskyRun) \(hook.rawValue)\n"
        }
        return hookCommand(with: packagePath)
    }

    private func hookCommand(with packagePath: String) -> String {
        "\(Self.swiftRunWithPath) \(packagePath) \(Self.shuskyRun) \(hook.rawValue)\n"
    }

    private func setUserExecutablePermissions() throws {
        let fm = FileManager.default
        let attributes: [FileAttributeKey: Any] = [
            .posixPermissions: 0o755,
        ]
        try fm.setAttributes(attributes, ofItemAtPath: path + fileName)
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }

    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }

    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
            .range(of: string, options: options) {
            indices.append(range.lowerBound)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }

    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
            .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
