//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import XCTest
@testable import Chester

class QueryBuilderTests: XCTestCase {

  fileprivate func loadExpectationForTest(_ test: String) -> String {
    let resource = testNameByRemovingParentheses(test)
    let url = Bundle(for: type(of: self)).url(forResource: resource, withExtension: "json")!
    let contents = try! String(contentsOf: url)
    return contents.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  fileprivate func testNameByRemovingParentheses(_ test: String) -> String {
    return test.substring(to: test.characters.index(test.endIndex, offsetBy: -2))
  }

  func testQueryWithFields() {
    let query = try! QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }

  func testQueryWithSubQuery() {
    let commentsQuery = try! QueryBuilder()
      .from("comments")
      .with(fields: "body")
    let postsQuery = try! QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .with(subQuery: commentsQuery)
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testQueryWithNestedSubQueries() {
    let authorQuery = try! QueryBuilder()
      .from("author")
      .with(fields: "firstname")
    let commentsQuery = try! QueryBuilder()
      .from("comments")
      .with(fields: "body")
      .with(subQuery: authorQuery)
    let postsQuery = try! QueryBuilder()
      .from("posts")
      .with(fields: "id", "title")
      .with(subQuery: commentsQuery)
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testInvalidQueryThrows() {
    XCTAssertThrowsError(try QueryBuilder().build())
    XCTAssertThrowsError(try QueryBuilder().with(fields: "id").build())
    XCTAssertThrowsError(try QueryBuilder().from("foo").build())
    XCTAssertThrowsError(try QueryBuilder().with(arguments: Argument(key: "key", value: "value")).build())
    
    let subQuery = try! QueryBuilder().from("foo").with(fields: "foo")
    
    XCTAssertThrowsError(try QueryBuilder().with(subQuery: subQuery))
  }
  
  func testQueryArgs() {
    let query = try! QueryBuilder()
      .from("posts")
      .with(arguments: Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      .with(fields: "id", "title")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFields() {
    let query = try! QueryBuilder()
      .from("posts", fields: ["id", "title"])
      .from("comments", fields: ["body"])
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFieldsAndArgs() {
    let query = try! QueryBuilder()
      .from("posts", fields: ["id", "title"], arguments: [Argument(key: "id", value: 5)])
      .from("comments", fields: ["body"], arguments: [Argument(key: "author", value: "Chester"),
                                                      Argument(key: "limit", value: 10)])
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootAndSubQueries() {
    let avatarQuery = try! QueryBuilder()
      .from("avatars")
      .with(arguments: Argument(key: "width", value: 100))
      .with(fields: "url")
    let query = try! QueryBuilder()
      .from("posts", fields: ["id"], subQueries: [avatarQuery])
      .from("comments", fields: ["body"])
      .build()

    let expectation = loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }
  
  func testQueryOn() {
    let query = try! QueryBuilder()
      .from("search")
      .with(arguments: Argument(key: "text", value: "an"))
      .on(collections: "Human", "Droid")
      .with(fields: "name")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryOnWithTypename() {
    let query = try! QueryBuilder()
      .from("search")
      .with(arguments: Argument(key: "text", value: "an"))
      .on(collections: "Human", "Droid")
      .withTypename()
      .with(fields: "name")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
}
