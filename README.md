# Shusky

<p align="center">
    <img src="https://travis-ci.org/didix21/Shusky.svg?branch=master" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://codecov.io/gh/didix21/Shusky">
        <img src="https://codecov.io/gh/didix21/Shusky/branch/master/graph/badge.svg" />
    </a>
</p>


## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Install](#install)
- [How to use](#how-to-use)
- [Uninstall](#uninstall)

## Overview

Shusky is a port of [Husky](https://github.com/typicode/husky) to Swift which allow to execute
git hooks with Swift. Can prevent `git commit` and `git push`.
<a href="https://asciinema.org/a/395288" target="_blank">
    <p align="center">
        <img src="https://asciinema.org/a/395288.svg" />
    </p>
</a>

## Features

- Prevent, inter alia, `git commit`, `git push`...
- Configure commands as non-critical. It allow to keep going with `git` command execution.
- Configure commands as non-verbose. (Maybe does not work for all comands).
- Skip git hooks with `SKIP_SHUSKY`. For example:`SKIP_SHUSKY=1 git commit -m `.
- Handle `swift run` command for you.

## Install

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

## How to use

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

## Uninstall

Run:

```shell script
swift run -c release shusky uninstall
```
