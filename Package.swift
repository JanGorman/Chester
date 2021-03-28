// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Chester",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(name: "Chester", targets: ["Chester"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Chester",
            dependencies: [],
            path: "Chester",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ChesterTests",
            dependencies: ["Chester"],
            path: "ChesterTests",
            exclude: ["Info.plist"],
            resources: [
                .copy("testQueryArgs.json"),
                .copy("testQueryArgsWithDictionary.json"),
                .copy("testQueryArgsWithSpecialCharacters.json"),
                .copy("testQueryOn.json"),
                .copy("testQueryOnWithTypename.json"),
                .copy("testQueryWithFields.json"),
                .copy("testQueryWithMultipleRootAndSubQueries.json"),
                .copy("testQueryWithMultipleRootFields.json"),
                .copy("testQueryWithMultipleRootFieldsAndArgs.json"),
                .copy("testQueryWithNestedSubQueries.json"),
                .copy("testQueryWithSubQuery.json")
            ]
        ),
    ]
)
