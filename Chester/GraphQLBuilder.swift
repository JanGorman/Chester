//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

public protocol Component {
  var string: String { get }
  var components: [String] { get }
}

@_functionBuilder
public struct GraphQLBuilder {

  public static func buildBlock(_ components: Component...) -> String {
    let from = components.first(where: { $0 is From })!
    let arguments = components.filter { $0 is Arguments }.flatMap { $0.components }
    let fields = components.filter { $0 is Fields }.flatMap { $0.components }
    let subQueries = components.filter { $0 is SubQuery }

    let query = try! QueryBuilder()
      .from(from.string)
      .with(fields: fields)

    if !arguments.isEmpty {
      try! query.with(rawArguments: arguments)
    }
    if !subQueries.isEmpty {
      try! query.with(literalSubQuery: subQueries[0].string)
    }

    return try! query.build()
  }

}

public func GraphQLQuery(@GraphQLBuilder builder: () -> String) -> String {
  return builder()
}

public struct SubQuery: Component {

  public var string: String
  public var components: [String] = []

  public init(@GraphQLBuilder builder: () -> String) {
    // YOLO
    let query = builder().split(separator: "\n").dropFirst().dropLast().joined(separator: "\n")

    self.string = query
  }

}

public struct From: Component {

  public let string: String
  public let components: [String] = []

  public init(_ string: String) {
    self.string = string
  }
}

public struct Fields: Component {

  public let string: String
  public let components: [String]

  public init(_ components: String...) {
    self.string = ""
    self.components = components
  }

}

public struct Arguments: Component {

  public let string: String
  public let components: [String]

  public init(_ arguments: Argument...) {
    self.string = ""
    self.components = arguments.map { $0.build() }
  }

}
