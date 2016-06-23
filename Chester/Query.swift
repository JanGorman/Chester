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

  mutating func withArguments(_ arguments: [Argument]) {
    self.arguments.append(contentsOf: arguments)
  }

  mutating func withFields(_ fields: [String]) {
    self.fields.append(contentsOf: fields)
  }

  mutating func withSubQueries(_ queries: [Query]) {
    self.subQueries.append(contentsOf: queries)
  }
  
  func validate() throws {
    if fields.isEmpty {
      throw QueryError.missingFields
    }
  }

  func build(_ indent: Int = Query.Indent) throws -> String {
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
    return "(" + arguments.flatMap{ $0.build() }.joined(separator: ", ") + ")"
  }
  
  private func buildFields(_ indent: Int ) throws -> String {
    return fields.map{ " ".times(indent) + $0 }.joined(separator: ",\n")
  }

  private func buildSubQueries(_ indent: Int) throws -> String {
    return try subQueries.map{ try $0.build(indent) }.joined(separator: ",\n")
  }

}
