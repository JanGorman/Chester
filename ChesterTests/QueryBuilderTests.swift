//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import XCTest
@testable import Chester

class QueryBuilderTests: XCTestCase {

  fileprivate func loadExpectationForTest(_ test: String) throws -> String {
    let resource = testNameByRemovingParentheses(test)
    let url = Bundle(for: type(of: self)).url(forResource: resource, withExtension: "json")!
    let contents = try String(contentsOf: url)
    return contents.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  fileprivate func testNameByRemovingParentheses(_ test: String) -> String {
    let idx = test.index(test.endIndex, offsetBy: -2)
    return String(test[..<idx])
  }

  func testQueryWithFields() throws {
    let query = try QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }

  func testQueryWithSubQuery() throws {
    let commentsQuery = try QueryBuilder()
      .from("comments")
      .with(fields: "body")
    let postsQuery = try QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .with(subQuery: commentsQuery)
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testQueryWithNestedSubQueries() throws {
    let authorQuery = try QueryBuilder()
      .from("author")
      .with(fields: "firstname")
    let commentsQuery = try QueryBuilder()
      .from("comments")
      .with(fields: "body")
      .with(subQuery: authorQuery)
    let postsQuery = try QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .with(subQuery: commentsQuery)
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testInvalidQueryThrows() throws {
    XCTAssertThrowsError(try QueryBuilder().build())
    XCTAssertThrowsError(try QueryBuilder().with(fields: "id").build())
    XCTAssertThrowsError(try QueryBuilder().from("foo").build())
    XCTAssertThrowsError(try QueryBuilder().with(arguments: Argument(key: "key", value: "value")).build())
    
    let subQuery = try QueryBuilder().from("foo").with(fields: "foo")
    
    XCTAssertThrowsError(try QueryBuilder().with(subQuery: subQuery))
  }
  
  func testQueryArgs() throws {
    let query = try QueryBuilder()
      .from("posts")
      .with(arguments: Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      .with(fields: "id", "title")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryArgsWithSpecialCharacters() throws {
    let query = try QueryBuilder()
      .from("posts")
      .with(arguments: Argument(key: "id", value: 4),
            Argument(key: "author", value: "\tIs this an \"emoji\"? 👻 \r\n(y\\n)Special\u{8}\u{c}\u{4}\u{1b}"))
      .with(fields: "id", "title")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryArgsWithDictionary() throws {
    let query = try QueryBuilder()
      .from("posts")
      .with(arguments: Argument(key: "id", value: 4),
            Argument(key: "filter", value: [["author": ["Chester"]], ["author": "Iskander"], ["books": 1]]))
      .with(fields: "id", "title")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFields() throws {
    let query = try QueryBuilder()
      .from("posts", fields: ["id", "title"])
      .from("comments", fields: ["body"])
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFieldsAndArgs() throws {
    let query = try QueryBuilder()
      .from("posts", fields: ["id", "title"], arguments: [Argument(key: "id", value: 5)])
      .from("comments", fields: ["body"], arguments: [Argument(key: "author", value: "Chester"),
                                                      Argument(key: "limit", value: 10)])
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootAndSubQueries() throws {
    let avatarQuery = try QueryBuilder()
      .from("avatars")
      .with(arguments: Argument(key: "width", value: 100))
      .with(fields: "url")
    let query = try QueryBuilder()
      .from("posts", fields: ["id"], subQueries: [avatarQuery])
      .from("comments", fields: ["body"])
      .build()

    let expectation = try loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }
  
  func testQueryOn() throws {
    let query = try QueryBuilder()
      .from("search")
      .with(arguments: Argument(key: "text", value: "an"))
      .on(collections: "Human", "Droid")
      .with(fields: "name")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryOnWithTypename() throws {
    let query = try QueryBuilder()
      .from("search")
      .with(arguments: Argument(key: "text", value: "an"))
      .on(collections: "Human", "Droid")
      .withTypename()
      .with(fields: "name")
      .build()
    
    let expectation = try loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
}
