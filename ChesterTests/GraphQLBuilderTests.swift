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
    }.query

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

}
