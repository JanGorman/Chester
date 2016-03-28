//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

public enum QueryError: ErrorType {
  case MissingCollection
  case MissingFields
}

public struct Argument {

  let key: String
  let value: AnyObject
  
  func build() -> String {
    return "\(key): \(value)"
  }

}

public class Query {

  private var collection: String!
  private var arguments: [Argument]
  private var fields: [String]
  private var subQueries: [Query]
  
  public init() {
    arguments = []
    fields = []
    subQueries = []
  }
  
  /// The collection to query
  ///
  /// - Parameter collection: The collection name
  public func fromCollection(collection: String) -> Self {
    self.collection = collection
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
    guard let collection = collection else { throw QueryError.MissingCollection }
    guard !fields.isEmpty else { throw QueryError.MissingFields }
    
    var query = topLevel ? "{\n" : ""
    query += "\(collection)\(buildArguments()) {\n"
    query += buildFields()
    if !subQueries.isEmpty {
      query += try ",\n" + buildSubQueries()
    } else {
      query += "\n}"
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
  
  private func buildFields() -> String {
    return fields.joinWithSeparator(",\n")
  }
  
  private func buildSubQueries() throws -> String {
    return try subQueries.map{ try $0.build(topLevel: false) }.joinWithSeparator(",\n")
  }

}
