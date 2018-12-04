// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chester",
    products: [
        .library(
            name: "Chester",
            targets: ["Chester"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "Chester",
            dependencies: []),
        .testTarget(
            name: "ChesterTests",
            dependencies: ["Chester"]),
    ]
)
