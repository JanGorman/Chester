// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Chester",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(name: "Chester", targets: ["Chester"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Chester",
            dependencies: [],
            path: "Chester"
        ),
        .testTarget(
            name: "ChesterTests",
            dependencies: ["Chester"],
            path: "ChesterTests",
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
