//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

internal struct Query {
  
  private static let Indent = 2

  var collection: String
  var arguments: [Argument]
  var fields: [String]
  var subQueries: [Query]

  init(collection: String) {
    self.collection = collection
    arguments = []
    fields = []
    subQueries = []
  }

  mutating func withArguments(arguments: [Argument]) {
    self.arguments.appendContentsOf(arguments)
  }

  mutating func withFields(fields: [String]) {
    self.fields.appendContentsOf(fields)
  }

  mutating func withSubQueries(queries: [Query]) {
    self.subQueries.appendContentsOf(queries)
  }
  
  func validate() throws {
    if fields.isEmpty {
      throw QueryError.MissingFields
    }
  }

  func build(indent: Int = Query.Indent) throws -> String {
    var query = "\(" ".times(indent))\(collection)\(buildArguments()) {\n"
    query += try buildFields(indent + Query.Indent)
    if !subQueries.isEmpty {
      query += ",\n"
      query += try buildSubQueries(indent + Query.Indent) + "\n" + " ".times(indent) + "}"
    } else {
      query += "\n" + " ".times(indent) + "}"
    }
    return query
  }
  
  private func buildArguments() -> String {
    if arguments.isEmpty {
      return ""
    }
    return "(" + arguments.flatMap{ $0.build() }.joinWithSeparator(", ") + ")"
  }
  
  private func buildFields(indent: Int ) throws -> String {
    return fields.map{ " ".times(indent) + $0 }.joinWithSeparator(",\n")
  }

  private func buildSubQueries(indent: Int) throws -> String {
    return try subQueries.map{ try $0.build(indent) }.joinWithSeparator(",\n")
  }

}
