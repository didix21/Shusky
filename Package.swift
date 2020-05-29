// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shusky",
    products: [
        .executable(name: "shusky", targets: ["Shusky"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Shusky",
            dependencies: [
                "ShuskyCore",
                "Yams",
                "Files",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "ShuskyCore",
            dependencies: [
                "Yams",
                "Files",
            ]
        ),
        .testTarget(
            name: "ShuskyTests",
            dependencies: ["Shusky", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .testTarget(
            name: "ShuskyCoreTests",
            dependencies: [
                "ShuskyCore",
                "Yams",
                "Files",
            ]
        ),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
