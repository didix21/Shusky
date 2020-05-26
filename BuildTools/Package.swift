// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", .exact("0.44.6")),
        .package(url: "https://github.com/realm/SwiftLint.git", .exact("0.39.2")),
    ],
    targets: [.target(name: "BuildTools", path: "")]
)
