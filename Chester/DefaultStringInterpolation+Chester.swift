//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

extension DefaultStringInterpolation {
  
  mutating func appendInterpolation(repeat str: String, _ count: Int) {
    for _ in 0..<count {
      appendLiteral(str)
    }
  }
  
}
