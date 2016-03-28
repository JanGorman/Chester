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
    let query = try! Query()
      .fromCollection("posts")
      .withFields("id", "title")
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithSubQuery() {
    let commentsQuery = Query()
      .fromCollection("comments")
      .withField("body")
    let postsQuery = try! Query()
      .fromCollection("posts")
      .withFields("id", "title")
      .withSubQuery(commentsQuery)
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testQueryWithNestedSubQueries() {
    let authorQuery = Query()
      .fromCollection("author")
      .withField("firstname")
    let commentsQuery = Query()
      .fromCollection("comments")
      .withField("body")
      .withSubQuery(authorQuery)
    let postsQuery = try! Query()
      .fromCollection("posts")
      .withFields("id", "title")
      .withSubQuery(commentsQuery)
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, postsQuery)
  }
  
  func testInvalidQueryThrows() {
    XCTAssertThrowsError(try Query().build())
    XCTAssertThrowsError(try Query().withFields("id").build())
  }
  
  func testQueryArgs() {
    let query = try! Query()
      .withArguments(Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      .fromCollection("posts")
      .withFields("id", "title")
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
  func testQueryWithMultipleRootFields() {
    let query = try! Query()
      .fromCollection("posts", fields: ["id", "title"])
      .fromCollection("comments", fields: ["body"])
      .build()
    
    let expectation = try! loadExpectationForTest(#function)
    
    XCTAssertEqual(expectation, query)
  }
  
}
