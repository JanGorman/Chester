//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

public protocol Component {
  var string: String { get }
  var components: [String] { get }
  var arguments: [Argument]? { get }
}

@_functionBuilder
public struct GraphQLBuilder {

  public static func buildBlock(_ components: Component...) -> String {
    let from = components.filter { $0 is From }
    let arguments = components.filter { $0 is Arguments }.flatMap { $0.components }
    let subQueries = components.filter { $0 is SubQuery }
    let onCollections = components.filter { $0 is On }

    let queryBuilder = QueryBuilder()
    if from.count == 1 {
      let fields = components.filter { $0 is Fields }.flatMap { $0.components }
      try! queryBuilder.from(from[0].string).with(fields: fields)
    } else {
      for f in from {
        _ = queryBuilder.from(f.string, fields: f.components, arguments: f.arguments)
      }
    }

    if !arguments.isEmpty {
      try! queryBuilder.with(rawArguments: arguments)
    }
    if !subQueries.isEmpty {
      try! queryBuilder.with(literalSubQuery: subQueries[0].string)
    }
    if !onCollections.isEmpty {
      queryBuilder.on(collections: onCollections.flatMap { $0.components })
      if !onCollections[0].string.isEmpty {
        _ = queryBuilder.withTypename()
      }
    }

    return try! queryBuilder.build()
  }

}

public func GraphQLQuery(@GraphQLBuilder builder: () -> String) -> String {
  return builder()
}

public struct SubQuery: Component {

  public var string: String
  public var components: [String] = []
  public var arguments: [Argument]? = nil

  public init(@GraphQLBuilder builder: () -> String) {
    // YOLO
    let query = builder().split(separator: "\n").dropFirst().dropLast().joined(separator: "\n")

    self.string = query
  }

}

public struct From: Component {

  public let string: String
  public let components: [String]
  public let arguments: [Argument]?

  public init(_ string: String) {
    self.init(string: string, components: [], arguments: nil)
  }

  private init(string: String, components: [String], arguments: [Argument]?) {
    self.string = string
    self.components = components
    self.arguments = arguments
  }

  public func fields(_ fields: String...) -> Component {
    From(string: string, components: fields, arguments: nil)
  }

  public func arguments(_ arguments: Argument...) -> Component {
    From(string: string, components: components, arguments: arguments)
  }

}

public struct Fields: Component {

  public let string: String = ""
  public let components: [String]
  public var arguments: [Argument]? = nil

  public init(_ components: String...) {
    self.components = components
  }

}

public struct Arguments: Component {

  public let string: String = ""
  public let components: [String]
  public var arguments: [Argument]? = nil

  public init(_ arguments: Argument...) {
    self.components = arguments.map { $0.build() }
  }

}

public struct On: Component {

  public let string: String
  public let components: [String]
  public var arguments: [Argument]? = nil

  public init(_ on: String...) {
    self.init(string: "", components: on)
  }

  private init(string: String, components: [String]) {
    self.string = string
    self.components = components
  }

  public func withTypeName() -> Component {
    On(string: "x", components: components)
  }

}
