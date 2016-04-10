//
//  Copyright © 2016 Jan Gorman. All rights reserved.
//

import XCTest
@testable import Chester

class ChesterTests: XCTestCase {
  
  enum Error: ErrorType {
    case InvalidResource
  }
    
  override func setUp() {
    super.setUp()
  }
  
  private func loadExpectationForTest(test: String) throws -> String {
    guard let url = NSBundle(forClass: self.dynamicType).URLForResource(testNameByRemovingParentheses(test),
                                                                        withExtension: "json"),
              contents = try? String(contentsOfURL: url) else {
      throw Error.InvalidResource
    }
    return contents.stringByReplacingOccurrencesOfString("  ", withString: "")
  }
  
  private func testNameByRemovingParentheses(test: String) -> String {
    return test.substringToIndex(test.endIndex.advancedBy(-2))
  }
  
  func testQueryWithFields() {
    let query = try! QueryBuilder()
      .fromCollection("posts")
      .withFields("id", "title")
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
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
    
    let expectation = try! loadExpectationForTest(#function)
    
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
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testInvalidQueryThrows() {
    XCTAssertThrowsError(try QueryBuilder().build())
    XCTAssertThrowsError(try QueryBuilder().withFields("id").build())
  }
  
  func testQueryArgs() {
    let query = try! QueryBuilder()
      .fromCollection("posts")
      .withArguments(Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      .withFields("id", "title")
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFields() {
    let query = try! QueryBuilder()
      .fromCollection("posts", fields: ["id", "title"])
      .fromCollection("comments", fields: ["body"])
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFieldsAndArgs() {
    let query = try! QueryBuilder()
      .fromCollection("posts", fields: ["id", "title"], arguments: [Argument(key: "id", value: 5)])
      .fromCollection("comments", fields: ["body"], arguments: [Argument(key: "author", value: "Chester"),
                                                                Argument(key: "limit", value: 10)])
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
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

    let expectation = try! loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }
  
}
