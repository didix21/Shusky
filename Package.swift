// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonLibraries: [Target.Dependency] = ["Yams", "Files", "Rainbow"]
let package = Package(
    name: "Shusky",
    products: [
        .executable(name: "shusky", targets: ["Shusky"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "Shusky",
            dependencies: commonLibraries + [
                "ShuskyCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "ShuskyCore",
            dependencies: commonLibraries
        ),
        .testTarget(
            name: "ShuskyTests",
            dependencies: [
                "Shusky",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "ShuskyCoreTests",
            dependencies: ["ShuskyCore"] + commonLibraries
        ),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
