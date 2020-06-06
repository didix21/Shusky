//
// Created by Dídac Coll Pujals on 16/05/2020.
//

import Foundation

class GitHookFileHandler: Writable, Readable {
    private(set) var fileName: String
    var path: String
    private var hook: HookType
    private var packagePath: String?
    private var swiftRun = "swift run -c release"
    private var swiftRunWithPath = "swift run -c release --package-path"
    private var shuskyRun = "shusky run"
    private var shuskyBinary = ".build/release/shusky"
    private lazy var gitHookRun: String = {
        """
        if [[ -f \(self.shuskyBinary) ]]; then
            \(self.shuskyBinary) run \(self.hook.rawValue)
        else
            \(self.swiftRun) \(self.shuskyRun) \(self.hook.rawValue)
        fi

        """
    }()

    private lazy var gitHookRunWIthPackagePath: (String) -> String = { (packagePath: String) -> String in
        """
        if [[ -f ./\(packagePath)/\(self.shuskyBinary) ]]; then
            ./\(packagePath)/\(self.shuskyBinary) run \(self.hook.rawValue)
        else
            \(self.swiftRunWithPath) \(packagePath) \(self.shuskyRun) \(self.hook.rawValue)
        fi

        """
    }

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
        guard let startIndex = content.endIndex(of: "\(swiftRunWithPath) "),
            let endIndex = content.index(of: " \(shuskyRun) \(hook.rawValue)\n") else {
            return nil
        }
        return String(content[startIndex ... content.index(before: endIndex)])
    }

    private func hookCommand() -> String {
        guard let packagePath = packagePath else {
            return gitHookRun
        }
        return gitHookRunWIthPackagePath(packagePath)
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
