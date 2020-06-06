//
// Created by Dídac Coll Pujals on 06/06/2020.
//

import Foundation

public func swiftRun(hookType: String) -> String {
    """
    if [[ -f .build/release/shusky ]]; then
        .build/release/shusky run \(hookType)
    else
        swift run -c release shusky run \(hookType)
    fi

    """
}

public func swiftRunWithPath(
    hookType: String,
    packagePath: String = "Complex/Path/To/Execute/Swift/Package"
) -> String {
    """
    if [[ -f ./\(packagePath)/.build/release/shusky ]]; then
        ./\(packagePath)/.build/release/shusky run \(hookType)
    else
        swift run -c release --package-path \(packagePath) shusky run \(hookType)
    fi

    """
}
