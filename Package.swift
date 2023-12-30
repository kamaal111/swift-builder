// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-builder",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SwiftBuilder",
            targets: ["SwiftBuilder"]
        ),
        .executable(
            name: "swift-builderClient",
            targets: ["swift-builderClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "509.0.0")),
    ],
    targets: [
        .macro(
            name: "SwiftBuilderMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "SwiftBuilder", dependencies: ["SwiftBuilderMacros"]),
        .executableTarget(name: "swift-builderClient", dependencies: ["SwiftBuilder"]),
        .testTarget(
            name: "SwiftBuilderTests",
            dependencies: [
                "SwiftBuilderMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        )
    ]
)
