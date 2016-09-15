//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

internal struct Query {
  
  fileprivate static let indent = 2

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

  mutating func with(arguments: [Argument]) {
    self.arguments.append(contentsOf: arguments)
  }

  mutating func with(fields: [String]) {
    self.fields.append(contentsOf: fields)
  }

  mutating func with(subQueries queries: [Query]) {
    self.subQueries.append(contentsOf: queries)
  }
  
  func validate() throws {
    if fields.isEmpty {
      throw QueryError.missingFields
    }
  }

  func build(_ indent: Int = Query.indent) throws -> String {
    var query = "\(" ".times(indent))\(collection)\(buildArguments()) {\n"
    query += try buildFields(indent + Query.indent)
    if !subQueries.isEmpty {
      query += ",\n"
      query += try buildSubQueries(indent + Query.indent) + "\n" + " ".times(indent) + "}"
    } else {
      query += "\n" + " ".times(indent) + "}"
    }
    return query
  }
  
  fileprivate func buildArguments() -> String {
    if arguments.isEmpty {
      return ""
    }
    return "(" + arguments.flatMap{ $0.build() }.joined(separator: ", ") + ")"
  }
  
  fileprivate func buildFields(_ indent: Int ) throws -> String {
    return fields.map{ " ".times(indent) + $0 }.joined(separator: ",\n")
  }

  fileprivate func buildSubQueries(_ indent: Int) throws -> String {
    return try subQueries.map{ try $0.build(indent) }.joined(separator: ",\n")
  }

}
