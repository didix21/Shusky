//
// Created by Dídac Coll Pujals on 15/05/2020.
//

import Foundation
@testable import ShuskyCore

enum HookConfigTests {
    case hookType(HookType)
    case verbose(Any)
    case commands([Any])

    static func mapToStr(_ keys: [HookConfigTests]) -> String {
        var yaml = ""
        for key in keys {
            switch key {
            case .verbose(let verbose): yaml += newYmlKey(.verbose, verbose)
            case .hookType(let hookType): yaml += "\(hookType.rawValue): \n"
            case .commands(let commands):
                for command in commands {
                    guard let commandConfig = command as? CommandConfigTests else {
                        yaml += "-    \(command)\n"
                        continue
                    }
                    yaml += commandConfig.mapToStr()
                }
            }
        }
        return yaml
    }

    private static func newYmlKey(_ key: Hook.ShuskyCodingKey, _ value: Any) -> String {
        "\(key.rawValue): \(value)\n"
    }
}

enum CommandConfigTests {
    case run([RunConfigTests])

    func mapToStr() -> String {
        switch self {
        case .run(let runConfig): return RunConfigTests.mapToStr(runConfig)
        }
    }
}

enum RunConfigTests {
    case command(Any)
    case path(Any)
    case critical(Any)
    case verbose(Any)

    static func mapToStr(_ keys: [RunConfigTests]) -> String {
        let run = """
                      run:\n
                  """
        var yaml = run
        for key in keys {
            switch key {
            case .command(let command):
                yaml += newYmlKey(.command, command)
            case .path(let path):
                yaml += newYmlKey(.path, path)
            case .critical(let critical):
                yaml += newYmlKey(.critical, critical)
            case .verbose(let verbose):
                yaml += newYmlKey(.verbose, verbose)
            }
        }

        return yaml
    }

    private static func newYmlKey(_ key: Run.ShuskyCodingKey, _ value: Any) -> String {
        "        \(key.rawValue): \(value)\n"
    }
}