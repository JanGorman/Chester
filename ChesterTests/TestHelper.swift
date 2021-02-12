//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

final class TestHelper {

  func loadExpectationForTest(_ test: String) throws -> String {
    let resource = testNameByRemovingParentheses(test)
    #if SWIFT_PACKAGE
    let url = Bundle.module.url(forResource: resource, withExtension: "json")!
    #else
    let url = Bundle(for: type(of: self)).url(forResource: resource, withExtension: "json")!
    #endif
    let contents = try String(contentsOf: url)
    return contents.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func testNameByRemovingParentheses(_ test: String) -> String {
    let idx = test.index(test.endIndex, offsetBy: -2)
    return String(test[..<idx])
  }

}
