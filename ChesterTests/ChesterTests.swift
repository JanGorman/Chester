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
    return contents.stringByReplacingOccurrencesOfString(" ", withString: "")
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
  }
  
}
