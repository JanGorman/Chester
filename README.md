# Chester

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/JanGorman/Chester.svg?branch=master&style=flat)](https://travis-ci.org/JanGorman/Chester)
[![Version](https://img.shields.io/cocoapods/v/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)
[![License](https://img.shields.io/cocoapods/l/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)
[![Platform](https://img.shields.io/cocoapods/p/Chester.svg?style=flat)](http://cocoapods.org/pods/Chester)

Note that Chester is work in progress and it's functionality is still very limited.

## Usage

Chester uses the builder pattern to construct GraphQL queries. In it's basic form use it like this:
```swift
import Chester

let query = Query()
	.fromCollection("posts")
	.withFields("id", "title", "content")

// For cases with dynamic input, probably best to use a do-catch:

do {
	let queryString = try query.build
} catch {
	// Can specify which errors to catch
}

// For fixed queries more readable

guard let queryString = try? query.build else { return }

```

You can add subqueries. Add as many as needed. You can nest them as well.
```swift

let commentsQuery = Query()
	.fromCollection("comments")
	.withFields("id", content)
let postsQuery = Query()
	.fromCollection("posts")
	.withFields("id", "title")
	.withSubQuery(commentsQuery)

```


Check the included unit tests for further examples.

## Requirements

* Swift 2.2
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

## Author

[Jan Gorman](https://twitter.com/JanGorman)

## License

Chester is available under the MIT license. See the LICENSE file for more info.
