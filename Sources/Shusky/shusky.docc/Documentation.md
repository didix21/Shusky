# ``shusky``

Shusky is a port of [Husky](https://github.com/typicode/husky) to Swift which allow to execute
git hooks with Swift.

@Metadata { 
    @DisplayName("Shusky")
    @CallToAction(url: "https://github.com/didix21/shusky",
                  purpose: link)
}

## Overview

@Row {
    @Column {
        ![MacOS](https://github.com/didix21/shusky/actions/workflows/MacOS.yml/badge.svg?branch=main)
    }

    @Column {
        ![Ubuntu](https://github.com/didix21/shusky/actions/workflows/Ubuntu.yml/badge.svg?branch=main)
    }
    
    @Column {
        ![Swift-5.5](https://img.shields.io/badge/Swift-5.5-orange.svg)
    }
    
    @Column {
        ![SPM](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)
    }
    
    @Column {
        ![codecov](https://codecov.io/gh/didix21/Shusky/branch/main/graph/badge.svg)
    }
}

This versatile tool simplifies the use of Git hooks in Swift, offering multiple features. It empowers users to selectively prevent actions like git commit and git push, offering fine-grained control. Commands can be configured as non-critical, allowing other git operations to continue uninterrupted even if one fails, while optional non-verbosity simplifies output. The tool also enables the skipping of Git hooks using SKIP_SHUSKY, affording flexibility when necessary. Furthermore, it conveniently handles the swift run command, particularly valuable for Swift development. Overall, it's a powerful utility for customizing and optimizing Git interactions while ensuring flexibility and efficiency in various scenarios.


@Video(source: "shusky-cli", poster: "sentry-cli-image.png")


### Where to start?

@TabNavigator {
    @Tab("Install") {
        Add the following code to your `Package.swift` file.

        ```swift
        .package(url: "https://github.com/didix21/Shusky", from: "1.0.0")
        ```

        Then:

        - If you have your `Package.swift` file in the root, run:

            ``` bash
            swift run -c release shusky install
            ```
          
        - If you have your `Package.swift` file to another path, run:

            ``` bash
            swift build --package-path YourPath -c release --product shusky
            ./YourPath/.build/release/shusky install --package-path YourPath
            ```

        This will add a new file `.shusky.yml` in your root with the following configuration:

        ```yaml
        pre-push:
            - echo "Shusky is ready, please configure .shusky.yml"
        pre-commit:
            - echo "Shusky is ready, please configure .shusky.yml"

        ```

        **NOTE:** Shusky installation is safe, it will not remove any previous content in your git hooks file.
        it only will add the command for running shusky. More info in [Advanced installation](https://github.com/didix21/Shusky/wiki/Advanced-installation).
    }
    @Tab("Uninstall") {
        Run:

        ```shell script
        swift run -c release shusky uninstall
        ```
    }
}

### How to use it?

- Only need to add your commands in `.shusky.yml` configuration file. For example:

    ```yaml
    pre-push:
        - set -o pipefail && swift test 2>&1 | xcpretty --color
    pre-commit:
        - swift run -c release swiftformat .
        - swift run -c release swiftlint lint .
        - git add -A
    ```

- **If you add a new hook you must run again** `shusky install`. For example:

    ```yaml
    pre-push:
        - set -o pipefail && swift test 2>&1 | xcpretty --color
    pre-commit:
        - swift run -c release swiftformat .
        - swift run -c release swiftlint lint .
        - git add -A
    pre-merge-commit:
        - swift test
    ```

- Maybe you want to run SPM binaries, but you always have to remember to run  `swift run` for compiling the binary. Don't worry, using `swift-run` option, shusky will handle it for you.

    ```yaml
    pre-commit:
        - swift-run:
            command: swiftformat .
    ```

- You can add especial behaviour to commands using the key `run`. For example you can set non-verbose to commands. Then only wil display output result only if the command fails. For example:

    ```yaml
    pre-commit:
        - swift run -c release swiftformat .
        - swift run -c release swiftlint lint .
        - run:
            command: set -o pipefail && swift test 2>&1 | xcpretty --color
            verbose: false
        - git add -A
    ```

-  Maybe while you're developing you don't want to cancel the `git commit` if one of the commands fail. So you can set propierty `critical` to `false`.
In this example, if `swiftlint` fails will keep going with the commit:

    ```yaml
    pre-commit:
        - swift run -c release swiftformat .
        - run:
            command: swift run -c release swiftlint lint .
            critical: false
        - git add -A
    ```

**NOTE:** More info in [Advanced configurations](https://github.com/didix21/Shusky/wiki/Advanded-configurations)




