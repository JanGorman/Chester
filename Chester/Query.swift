//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

struct Query {
  
  static let indent = 2

  var from: String
  var arguments: [Argument] = []
  var fields: [String] = []
  var on: [String] = []
  var subQueries: [Query] = []
  var literalSubQueries: [String] = []
  var withTypename = false

  mutating func with(arguments: [Argument]) {
    self.arguments += arguments
  }

  mutating func with(fields: [String]) {
    self.fields += fields
  }

  mutating func with(subQueries queries: [Query]) {
    self.subQueries += queries
  }

  mutating func with(literalSubQueries queries: [String]) {
    self.literalSubQueries += queries
  }
  
  mutating func with(onCollections: [String]) {
    on += onCollections
  }
  
  func validate() throws {
    if fields.isEmpty && subQueries.isEmpty {
      throw QueryError.missingFields
    }
  }

  func build(_ indent: Int = Query.indent) throws -> String {
    var query = "\(repeat: " ", indent)\(from)\(buildArguments()) {\n"
    if !on.isEmpty {
      query += buildOn(indent + Query.indent)
    } else {
      query += buildFields(indent + Query.indent)
    }
    if !subQueries.isEmpty {
      query += ",\n"
      query += "\(try buildSubQueries(indent + Query.indent))\n\(repeat: " ", indent)}"
    } else if !literalSubQueries.isEmpty {
      query += ",\n"
      query += "\(buildLiteralSubQueryes(indent))\n\(repeat: " ", indent)}"
    } else {
      query += "\n\(repeat: " ", indent)}"
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
      var onCollection = "\(repeat: " ", indent)... on \($0) {\n"
      onCollection += "\(buildFields(indent + indent / 2))\n\(repeat: " ", indent)}"
      return onCollection
    }.joined(separator: "\n")
    if withTypename {
      onCollection = "\(repeat: " ", indent)__typename\n\(onCollection)"
    }
    return onCollection
  }
  
  private func buildFields(_ indent: Int) -> String {
    fields.map { "\(repeat: " ", indent)\($0)" }.joined(separator: ",\n")
  }

  private func buildSubQueries(_ indent: Int) throws -> String {
    try subQueries.map { try $0.build(indent) }.joined(separator: ",\n")
  }

  private func buildLiteralSubQueryes(_ indent: Int) -> String {
    literalSubQueries.map { subQuery in
      subQuery.split(separator: "\n").map { "\(repeat: " ", indent)\($0)" }.joined(separator: "\n")
    }.joined(separator: ",\n")
  }

}
