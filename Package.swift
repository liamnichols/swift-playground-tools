// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PlaygroundTools",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "playground-tools", targets: ["PlaygroundTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .executableTarget(name: "PlaygroundTools", dependencies: [
            "PlaygroundToolsKit",
            .productItem(name: "ArgumentParser", package: "swift-argument-parser", condition: nil),
            "PathKit"
        ]),
        .target(name: "PlaygroundToolsKit", dependencies: [
            .productItem(name: "XcodeGenKit", package: "XcodeGen", condition: nil),
            .productItem(name: "ProjectSpec", package: "XcodeGen", condition: nil),
            "PathKit"
        ]),
        .testTarget(name: "PlaygroundToolsTests", dependencies: ["PlaygroundTools"]),
    ]
)
