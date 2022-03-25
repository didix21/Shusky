//
//  CommandResolver.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

struct CommandConfigurationResolver {
    let globalVerbose: Bool
    let runOptions: RunOptions

    struct CommandConfiguration {
        let verbose: Bool
        let critical: Bool
    }

    func evaluateConfiguration() -> Self.CommandConfiguration {
        CommandConfiguration(verbose: isVerbose(), critical: isCritical())
    }

    private func isVerbose() -> Bool {
        runOptions.verbose ?? globalVerbose
    }

    private func isCritical() -> Bool {
        runOptions.critical ?? true
    }
}
