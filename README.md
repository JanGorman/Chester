# Chester

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/JanGorman/Chester.svg?branch=master&style=flat)](https://travis-ci.org/JanGorman/Chester)
[![codecov.io](https://codecov.io/github/JanGorman/Chester/coverage.svg?branch=master)](https://codecov.io/github/JanGorman/Chester?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)
[![License](https://img.shields.io/cocoapods/l/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)
[![Platform](https://img.shields.io/cocoapods/p/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)

Note that Chester is work in progress and it's functionality is still very limited.

## Usage

Chester uses the builder pattern to construct GraphQL queries. In its basic form use it like this:
```swift
import Chester

let query = QueryBuilder()
	.from("posts")
	.with(arguments: Argument(key: "id", value: "20"), Argument(key: "author", value: "Chester"))
	.with(fields: "id", "title", "content")

// For cases with dynamic input, probably best to use a do-catch:

do {
  let queryString = try query.build
} catch {
  // Can specify which errors to catch
}

// Or if you're sure of your query

guard let queryString = try? query.build else { return }

```

You can add subqueries. Add as many as needed. You can nest them as well.
```swift
let commentsQuery = QueryBuilder()
	.from("comments")
	.with(fields: "id", content)
let postsQuery = QueryBuilder()
	.from("posts")
	.with(fields: "id", "title")
	.with(subQuery: commentsQuery)

```

You can search on multiple collections at once
```swift
let search = QueryBuilder()
  .from("search")
  .with(arguments: Argument(key: "text", value: "an"))
  .on("Human", "Droid")
  .with(fields: "name")
  .build()
```

Check the included unit tests for further examples.

## Requirements

* Swift 4
* iOS 8

## Installation

Chester is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Chester"
```

Or [Carthage](https://github.com/Carthage/Carthage). Add Chester to your Cartfile:

```
github "JanGorman/Chester"
```

Or [Swift Package Manager (SPM)](https://swift.org/package-manager/). Add Chester to your Package.swift:

```
dependencies: [
.package(url: "https://github.com/JanGorman/Chester.git", .upToNextMinor(from: "0.8.1"))
]
```

## Author

[Jan Gorman](https://twitter.com/JanGorman)

## License

Chester is available under the MIT license. See the LICENSE file for more info.
