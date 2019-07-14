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

    let query = try! QueryBuilder()
      .from(from.string)
      .with(fields: fields)

    return try! query.build()
  }

}

public struct GraphQLQuery {

  public let query: String

  public init(@GraphQLBuilder _ builder: () -> String) {
    self.query = builder()
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
    self.string = components.joined(separator: ", ")
    self.components = components
  }

}
