//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import XCTest
@testable import Chester

class QueryBuilderTests: XCTestCase {

  private func loadExpectationForTest(_ test: String) -> String {
    let resource = testNameByRemovingParentheses(test)
    let url = Bundle(for: self.dynamicType).urlForResource(resource, withExtension: "json")!
    let contents = try! String(contentsOf: url)
    return contents
  }

  private func testNameByRemovingParentheses(_ test: String) -> String {
    return test.substring(to: test.characters.index(test.endIndex, offsetBy: -2))
  }

  func testQueryWithFields() {
    let query = try! QueryBuilder()
      .fromCollection("posts")
      .withFields("id", "title")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }

  func testQueryWithSubQuery() {
    let commentsQuery = try! QueryBuilder()
      .fromCollection("comments")
      .withFields("body")
    let postsQuery = try! QueryBuilder()
      .fromCollection("posts")
      .withFields("id", "title")
      .withSubQuery(commentsQuery)
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    
    print(expectation)
    print(":::")
    print(postsQuery)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testQueryWithNestedSubQueries() {
    let authorQuery = try! QueryBuilder()
      .fromCollection("author")
      .withFields("firstname")
    let commentsQuery = try! QueryBuilder()
      .fromCollection("comments")
      .withFields("body")
      .withSubQuery(authorQuery)
    let postsQuery = try! QueryBuilder()
      .fromCollection("posts")
      .withFields("id", "title")
      .withSubQuery(commentsQuery)
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testInvalidQueryThrows() {
    XCTAssertThrowsError(try QueryBuilder().build())
    XCTAssertThrowsError(try QueryBuilder().withFields("id").build())
    XCTAssertThrowsError(try QueryBuilder().fromCollection("foo").build())
    XCTAssertThrowsError(try QueryBuilder().withArguments(Argument(key: "key", value: "value")).build())
    
    let subQuery = try! QueryBuilder().fromCollection("foo").withFields("foo")
    XCTAssertThrowsError(try QueryBuilder().withSubQuery(subQuery))
  }
  
  func testQueryArgs() {
    let query = try! QueryBuilder()
      .fromCollection("posts")
      .withArguments(Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      .withFields("id", "title")
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFields() {
    let query = try! QueryBuilder()
      .fromCollection("posts", fields: ["id", "title"])
      .fromCollection("comments", fields: ["body"])
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFieldsAndArgs() {
    let query = try! QueryBuilder()
      .fromCollection("posts", fields: ["id", "title"], arguments: [Argument(key: "id", value: 5)])
      .fromCollection("comments", fields: ["body"], arguments: [Argument(key: "author", value: "Chester"),
                                                                Argument(key: "limit", value: 10)])
      .build()
    
    let expectation = loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootAndSubQueries() {
    let avatarQuery = try! QueryBuilder()
      .fromCollection("avatars")
      .withArguments(Argument(key: "width", value: 100))
      .withFields("url")
    let query = try! QueryBuilder()
      .fromCollection("posts", fields: ["id"], subQueries: [avatarQuery])
      .fromCollection("comments", fields: ["body"])
      .build()

    let expectation = loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }
  
}
