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
    let fields = components.filter { $0 is Fields }.flatMap { $0.components }
    let subQueries = components.filter { $0 is SubQuery }

    let query = try! QueryBuilder()
      .from(from.string)
      .with(fields: fields)

    if !subQueries.isEmpty {
      for subQuery in subQueries {
        let q = try! QueryBuilder()
          .from(subQuery.string)
          .with(fields: subQuery.components)
        try! query.with(subQuery: q)
      }
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
    let query = builder()
    let sanitized = query.filter { !$0.isWhitespace }
    let from = String(sanitized.split(separator: "{")[0])
    let fields = sanitized.filter{ $0 != "}" }
      .split(separator: "{")[1]
      .split(separator: ",")
      .map { String($0) }

    self.string = from
    self.components = fields
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
