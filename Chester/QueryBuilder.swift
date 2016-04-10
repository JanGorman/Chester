//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

public enum QueryError: ErrorType {
  case MissingCollection
  case MissingFields
  case MissingArguments
  case InvalidState(String)
}

public struct Argument {

  let key: String
  let value: AnyObject
  
  func build() -> String {
    return "\(key): \(value)"
  }

}

public class QueryBuilder {

  private var collections: [String]
  private var arguments: [String: [Argument]]
  private var fields: [String: [String]]
  private var subQueries: [String: [QueryBuilder]]
  
  public init() {
    collections = []
    arguments = [:]
    fields = [:]
    subQueries = [:]
  }

  /// The collection to query
  ///
  /// - Parameter collection: The collection name.
  /// - Parameter fields: The fields to query in this collection. Use as an alternative to passing in fields separately
  ///                     or when querying multiple top level collections.
  /// - Parameter arguments: The arguments to limit this collection.
  /// - Parameter subQueries for this collection.
  public func fromCollection(collection: String, fields: [String]? = nil, arguments: [Argument]? = nil,
                             subQueries: [QueryBuilder]? = nil) -> Self {
    collections.append(collection)
    if let fields = fields {
      self.fields[collection] = fields
    }
    if let arguments = arguments {
      self.arguments[collection] = arguments
    }
    if let subQueries = subQueries {
      self.subQueries[collection] = subQueries
    }
    return self
  }
  
  /// Query arguments
  ///
  /// - Parameter arguments: The query args struct(s)
  /// - Throws: `MissingCollection` if no collection is defined before passing in arguments
  public func withArguments(arguments: Argument...) throws -> Self {
    guard collections.count == 1 else { throw QueryError.MissingCollection }
    self.arguments[collections.first!] = arguments
    return self
  }
  
  /// The fields to retrieve
  ///
  /// - Parameter fields: The field names
  /// - Throws: `MissingCollection` if no collection is defined before passing in fields
  public func withFields(fields: String...) throws -> Self {
    guard collections.count == 1 else { throw QueryError.MissingCollection }
    self.fields[collections.first!] = fields
    return self
  }
  
  /// Insert a subquery. Add as many top level or nested queries as desired.
  ///
  /// - Parameter query: The subquery
  /// - Throws: `MissingCollection` if no collection is defined before passing in a subquery
  public func withSubQuery(query: QueryBuilder) throws -> Self {
    guard collections.count == 1 else { throw QueryError.MissingCollection }
    if subQueries[collections.first!] == nil {
      subQueries[collections.first!] = []
    }
    subQueries[collections.first!]?.append(query)
    return self
  }
  
  /// Build the query.
  ///
  /// - Returns: The constructed query as String
  /// - Throws: Throws `QueryError` if the builder is in an invalid state before calling `build()` 
  public func build() throws -> String {
    return try build(topLevel: true)
  }

  private func build(topLevel topLevel: Bool) throws -> String {
    try validateQuery()
    return try QueryStringBuilder(query: self).build(topLevel: topLevel)
  }

  private func validateQuery() throws {
    if collections.isEmpty {
      throw QueryError.MissingCollection
    } else  if fields.isEmpty && collections.count == 1 {
      throw QueryError.MissingFields
    } else if fields.count != collections.count {
      throw QueryError.InvalidState("Querying more than one collection with only one set of fields.")
    } else if !arguments.isEmpty && arguments.count != collections.count {
      throw QueryError.InvalidState("Querying more than one collection with only one set of arguments.")
    }
  }

}

private class QueryStringBuilder {
  
  private let query: QueryBuilder
  
  init(query: QueryBuilder) {
    self.query = query
  }
  
  private func build(topLevel topLevel: Bool) throws -> String {
    var queryString = topLevel ? "{\n" : ""
    
    for (i, collection) in query.collections.enumerate() {
      queryString += "\(collection)\(try buildArguments(forCollection: collection)) {\n"
      queryString += try buildFields(forCollection: collection)
      if query.subQueries[collection] != nil {
        queryString += try ",\n" + buildSubQueries(forCollection: collection)
      } else {
        queryString += "\n}"
      }
      queryString += joinCollections(i)
    }
    queryString += "\n}"
    
    return queryString
  }
  
  private func joinCollections(current: Int) -> String {
    return current == query.collections.count - 1 ? "" : ",\n"
  }
  
  private func buildArguments(forCollection collection: String) throws -> String {
    guard let arguments = query.arguments[collection] else {
      return ""
    }
    guard !arguments.isEmpty else { throw QueryError.MissingArguments }
    var args = "("
    args += arguments.flatMap{ $0.build() }.joinWithSeparator(", ")
    args += ")"
    return args
  }
  
  private func buildFields(forCollection collection: String) throws -> String {
    guard let fields = query.fields[collection] else { throw QueryError.MissingFields }
    guard !fields.isEmpty else { throw QueryError.MissingFields }
    return fields.joinWithSeparator(",\n")
  }
  
  private func buildSubQueries(forCollection collection: String) throws -> String {
    if let subQueries = query.subQueries[collection] {
      return try subQueries.map{ try $0.build(topLevel: false) }.joinWithSeparator(",\n")
    }
    return ""
  }

}



