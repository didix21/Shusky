//
// Created by Dídac Coll Pujals on 21/05/2020.
//

import Foundation

public final class ShuskyCore {

    public init() {

    }

    public func install(gitPath: String, shuskyPath: String? = nil, packagePath: String? = nil) {
        let shuskyFile = ShuskyFile(path: shuskyPath)
        do {
            try shuskyFile.createDefaultShuskyYaml()
            let hooksParser = try HooksParser(try shuskyFile.read())
            for hookAvailable in hooksParser.availableHooks {
                _ = try HookHandler(hook: hookAvailable, path: gitPath, packagePath: packagePath)
            }
        } catch {
            print(error)
        }
    }

}