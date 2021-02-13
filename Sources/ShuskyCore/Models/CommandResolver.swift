//
//  CommandResolver.swift
//  ShuskyCore
//
//  Created by Dídac Coll Pujals on 13/2/21.
//

import Foundation

struct CommandResolver {
    let globalVerbose: Bool
    let runOptions: Run

    struct CommandConfiguration {
        let verbose: Bool
        let critical: Bool
    }

    func evaluateConfiguration() -> Self.CommandConfiguration {
        CommandConfiguration(verbose: isVerbose(), critical: isCritical())
    }

    private func isVerbose() -> Bool {
        return runOptions.verbose ?? globalVerbose
    }

    private func isCritical() -> Bool {
        return runOptions.critical ?? true
    }
}
