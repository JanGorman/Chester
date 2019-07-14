//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import XCTest
import Chester

class GraphQLBuilderTests: XCTestCase {

  func testQueryWithFields() throws {
    let query = GraphQLQuery {
      From("posts")
      Fields("id", "title")
    }

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

  func testQueryWithSubQuery() throws {
    let query = GraphQLQuery {
      From("posts")
      Fields("id", "title")
      SubQuery {
        From("comments")
        Fields("body")
      }
    }

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

}
