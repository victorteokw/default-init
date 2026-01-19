// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "DefaultInit",
    platforms: [.macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26), .macCatalyst(.v26)],
    products: [
        .library(
            name: "DefaultInit",
            targets: ["DefaultInit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "DefaultInitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "DefaultInit", dependencies: ["DefaultInitMacros"]),
        .testTarget(name: "DefaultInitTests", dependencies: ["DefaultInit"]),
    ]
)
