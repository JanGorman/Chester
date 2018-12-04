//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import Foundation

public enum QueryError: Error {
  case missingCollection
  case missingFields
  case missingArguments
  case invalidState(String)
}

public struct Argument {

  let key: String
  let value: Any

  public init(key: String, value: Any) {
    self.key = key
    self.value = value
  }

  func build() -> String {
    if let value = value as? GraphQLSerializable {
      let escapedValue = value.asGraphQLString
      return "\(key): \(escapedValue)"
    } else {
      return "\(key): \(value)"
    }
  }

}

public final class QueryBuilder {

  fileprivate var queries: [Query]
  
  public init() {
    queries = []
  }

  /// The collection to query
  ///
  /// - Parameter from: Querying "from"
  /// - Parameter fields: The fields to query in this collection. Use as an alternative to passing in fields separately
  ///                     or when querying multiple top level collections.
  /// - Parameter arguments: The arguments to limit this collection.
  /// - Parameter subQueries: for this collection.
  public func from(_ from: String, fields: [String]? = nil, arguments: [Argument]? = nil,
                   subQueries: [QueryBuilder]? = nil) -> Self {
    var query = Query(from: from)
    if let fields = fields {
      query.with(fields: fields)
    }
    if let arguments = arguments {
      query.with(arguments: arguments)
    }
    if let subQueries = subQueries {
      query.with(subQueries: subQueries.flatMap{ $0.queries })
    }
    self.queries.append(query)
    return self
  }
  
  /// Query arguments
  ///
  /// - Parameter arguments: The query args struct(s)
  /// - Throws: `MissingCollection` if no collection is defined before passing in arguments
  @discardableResult
  public func with(arguments: Argument...) throws -> Self {
    guard let lastIndex = queries.indices.last else {
      throw QueryError.missingCollection
    }
    queries[lastIndex].with(arguments: arguments)
    return self
  }
  
  /// The fields to retrieve
  ///
  /// - Parameter fields: The field names
  /// - Throws: `MissingCollection` if no collection is defined before passing in fields
  @discardableResult
  public func with(fields: String...) throws -> Self {
    guard let lastIndex = queries.indices.last else {
      throw QueryError.missingCollection
    }
    self.queries[lastIndex].with(fields: fields)
    return self
  }
  
  /// Insert a subquery. Add as many top level or nested queries as desired.
  ///
  /// - Parameter query: The subquery
  /// - Throws: `MissingCollection` if no collection is defined before passing in a subquery
  @discardableResult
  public func with(subQuery query: QueryBuilder) throws -> Self {
    guard let lastIndex = queries.indices.last else {
      throw QueryError.missingCollection
    }
    queries[lastIndex].with(subQueries: query.queries)
    return self
  }
  
  /// Query a number of collections for the same field
  ///
  /// - Parameter collections: The collection names
  public func on(collections: String...) -> Self {
    queries[0].with(onCollections: collections)
    return self
  }
  
  /// Query for the meta field __typename
  public func withTypename() -> Self {
    queries[0].withTypename = true
    return self
  }
  
  /// Build the query.
  ///
  /// - Returns: The constructed query as String
  /// - Throws: Throws `QueryError` if the builder is in an invalid state before calling `build()` 
  public func build() throws -> String {
    try validateQuery()
    return try QueryStringBuilder(self).build()
  }

  private func validateQuery() throws {
    if queries.isEmpty {
      throw QueryError.missingCollection
    }
    try queries.forEach { try $0.validate() }
  }

}

private class QueryStringBuilder {
  
  fileprivate let queryBuilder: QueryBuilder
  
  init(_ queryBuilder: QueryBuilder) {
    self.queryBuilder = queryBuilder
  }
  
  fileprivate func build() throws -> String {
    var queryString = "{\n"
    for (i, query) in queryBuilder.queries.enumerated() {
      queryString += try query.build()
      queryString += joinCollections(i)
    }
    queryString += "\n}"
    return queryString
  }
  
  fileprivate func joinCollections(_ current: Int) -> String {
    return current == queryBuilder.queries.count - 1 ? "" : ",\n"
  }

}

extension String {
  
  func times(_ times: Int) -> String {
    var result = ""
    for _ in 0..<times {
      result += self
    }
    return result
  }
  
}
