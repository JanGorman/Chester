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

  func testQueryWithNestedSubQueries() throws {
    let query = GraphQLQuery {
      From("posts")
      Fields("id", "title")
      SubQuery {
        From("comments")
        Fields("body")
        SubQuery {
          From("author")
          Fields("firstname")
        }
      }
    }

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

  func testQueryArgs() throws {
    let query = GraphQLQuery {
      From("posts")
      Arguments(Argument(key: "id", value: 4), Argument(key: "author", value: "Chester"))
      Fields("id", "title")
    }

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

  func testQueryArgsWithSpecialCharacters() throws {
    let query = GraphQLQuery {
      From("posts")
      Arguments(
        Argument(key: "id", value: 4),
        Argument(key: "author", value: "\tIs this an \"emoji\"? 👻 \r\n(y\\n)Special\u{8}\u{c}\u{4}\u{1b}")
      )
      Fields("id", "title")
    }

    let expectation = try TestHelper().loadExpectationForTest(#function)

    XCTAssertEqual(expectation, query)
  }

}
