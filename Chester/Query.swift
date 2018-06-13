//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

struct Query {
  
  static let indent = 2

  var from: String
  var arguments: [Argument]
  var fields: [String]
  var on: [String]
  var subQueries: [Query]
  var withTypename = false

  init(from: String) {
    self.from = from
    arguments = []
    fields = []
    subQueries = []
    on = []
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
  
  mutating func with(onCollections: [String]) {
    on.append(contentsOf: onCollections)
  }
  
  func validate() throws {
    if fields.isEmpty && subQueries.isEmpty {
      throw QueryError.missingFields
    }
  }

  func build(_ indent: Int = Query.indent) throws -> String {
    var query = "\(" ".times(indent))\(from)\(buildArguments()) {\n"
    if !on.isEmpty {
      query += buildOn(indent + Query.indent)
    } else {
      query += buildFields(indent + Query.indent)
    }
    if !subQueries.isEmpty {
      query += ",\n"
      query += try buildSubQueries(indent + Query.indent) + "\n" + " ".times(indent) + "}"
    } else {
      query += "\n" + " ".times(indent) + "}"
    }
    return query
  }
  
  private func buildArguments() -> String {
    if arguments.isEmpty {
      return ""
    }
    return "(" + arguments.compactMap{ $0.build() }.joined(separator: ", ") + ")"
  }
  
  private func buildOn(_ indent: Int) -> String {
    var onCollection = on.map {
      var onCollection = " ".times(indent) + "... on \($0) {\n"
      onCollection += buildFields(indent + indent / 2) + "\n" + " ".times(indent) + "}"
      return onCollection
    }.joined(separator: "\n")
    if withTypename {
      onCollection = " ".times(indent) + "__typename\n" + onCollection
    }
    return onCollection
  }
  
  private func buildFields(_ indent: Int) -> String {
    return fields.map { " ".times(indent) + $0 }.joined(separator: ",\n")
  }

  private func buildSubQueries(_ indent: Int) throws -> String {
    return try subQueries.map { try $0.build(indent) }.joined(separator: ",\n")
  }

}
