// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shusky",
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
    ],
    targets: [
        .target(
            name: "Shusky",
            dependencies: [
                "ShuskyCore",
                "Yams",
                "Files",
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
	    name: "ShuskyCore",
            dependencies: [
                "Yams",
                "Files",
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "ShuskyTests",
            dependencies: ["Shusky"]
        ),
        .testTarget(
            name: "ShuskyCoreTests",
            dependencies: [
                "ShuskyCore",
                "Yams",
                "Files",
                .product(name: "Logging", package: "swift-log")
            ]
        )
    ]
)
