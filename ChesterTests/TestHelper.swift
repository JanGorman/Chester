//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

final class TestHelper {

  func loadExpectationForTest(_ test: String) throws -> String {
    let resource = testNameByRemovingParentheses(test)
    let url = Bundle(for: type(of: self)).url(forResource: resource, withExtension: "json")!
    let contents = try String(contentsOf: url)
    return contents.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func testNameByRemovingParentheses(_ test: String) -> String {
    let idx = test.index(test.endIndex, offsetBy: -2)
    return String(test[..<idx])
  }

}
