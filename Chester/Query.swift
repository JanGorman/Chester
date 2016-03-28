//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

public enum QueryError: ErrorType {
  case MissingCollection
  case MissingFields
  case InvalidState(String)
}

public struct Argument {

  let key: String
  let value: AnyObject
  
  func build() -> String {
    return "\(key): \(value)"
  }

}

public class Query {

  private var collections: [String]
  private var arguments: [Argument]
  private var fields: [String]
  private var collectionFields: [String: [String]]
  private var subQueries: [Query]
  
  public init() {
    collections = []
    arguments = []
    fields = []
    collectionFields = [:]
    subQueries = []
  }

  /// The collection to query
  ///
  /// - Parameter collection: The collection name
  /// - Parameter fields: The fields to query in this collection. Use as an alternative to passing in fields separately
  ///                     or when querying multiple top level collections.
  public func fromCollection(collection: String, fields: [String]? = nil) -> Self {
    collections.append(collection)
    if let fields = fields {
      collectionFields[collection] = fields
    }
    return self
  }
  
  /// Query arguments
  ///
  /// - Parameter arguments: The query args struct(s)
  public func withArguments(arguments: Argument...) -> Self {
    self.arguments.appendContentsOf(arguments)
    return self
  }
  
  /// The field to retrieve
  ///
  /// - Parameter field: The field name
  public func withField(field: String) -> Self {
    return withFields(field)
  }
  
  /// The fields to retrieve
  ///
  /// - Parameter fields: The field names
  public func withFields(fields: String...) -> Self {
    self.fields.appendContentsOf(fields)
    return self
  }
  
  /// Insert a subquery. Add as many top level or nested queries as desired.
  ///
  /// - Parameter query: The subquery
  public func withSubQuery(query: Query) -> Self {
    subQueries.append(query)
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
    guard !collections.isEmpty else { throw QueryError.MissingCollection }
    if fields.isEmpty && collections.count == 1 {
      throw QueryError.MissingFields
    } else if !fields.isEmpty && collections.count > 1 {
      throw QueryError.InvalidState("Querying more than one collection with only one set of fields.")
    }
    
    var query = topLevel ? "{\n" : ""
    
    for (i, collection) in collections.enumerate() {
      query += "\(collection)\(buildArguments()) {\n"
      query += buildFields(forCollection: collection)
      if !subQueries.isEmpty {
        query += try ",\n" + buildSubQueries()
      } else {
        query += "\n}"
      }
      query += i == collections.count - 1 ? "" : ",\n"
    }
    query += "\n}"

    return query
  }
  
  private func buildArguments() -> String {
    guard !arguments.isEmpty else { return "" }
    var args = "("
    args += arguments.map{ $0.build() }.joinWithSeparator(", ")
    args += ")"
    return args
  }
  
  private func buildFields(forCollection collection: String) -> String {
    let fields = collectionFields[collection] ?? self.fields
    return fields.joinWithSeparator(",\n")
  }
  
  private func buildSubQueries() throws -> String {
    return try subQueries.map{ try $0.build(topLevel: false) }.joinWithSeparator(",\n")
  }

}
