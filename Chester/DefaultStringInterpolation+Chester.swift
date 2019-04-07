//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

struct GraphQLEscapedString: LosslessStringConvertible {

  var value: String

  init?(_ description: String) {
    self.value = description
  }

  var description: String {
    return value
  }

}

struct GraphQLEscapedDictionary {

  let value: [String: Any]

  init(_ value: [String: Any]) {
    self.value = value
  }

}

struct GraphQLEscapedArray {

  let value: [Any]

  init(_ value: [Any]) {
    self.value = value
  }

}

extension DefaultStringInterpolation {

  mutating func appendInterpolation(repeat str: String, _ count: Int) {
    for _ in 0..<count {
      appendLiteral(str)
    }
  }

  mutating func appendInterpolation(_ value: GraphQLEscapedString) {
    appendLiteral(#""\#(escape(string: value.description))""#)
  }

  /// Escape strings according to https://facebook.github.io/graphql/#sec-String-Value
  private func escape(string input: String) -> String{
    var output = ""
    for scalar in input.unicodeScalars {
      switch scalar {
      case "\"":
        output.append("\\\"")
      case "\\":
        output.append("\\\\")
      case "\u{8}":
        output.append("\\b")
      case "\u{c}":
        output.append("\\f")
      case "\n":
        output.append("\\n")
      case "\r":
        output.append("\\r")
      case "\t":
        output.append("\\t")
      case UnicodeScalar(0x0)...UnicodeScalar(0xf), UnicodeScalar(0x10)...UnicodeScalar(0x1f):
        output.append(String(format: "\\u%04x", scalar.value))
      default:
        output.append(Character(scalar))
      }
    }

    return output
  }

  mutating func appendInterpolation(_ value: GraphQLEscapedDictionary) {
    let output = value.value.map { key, value in
      let serializedValue: String
      if let value = value as? String, let escapable = GraphQLEscapedString(value) {
        serializedValue = "\(escapable)"
      } else if let value = value as? [String: Any] {
        serializedValue = "\(GraphQLEscapedDictionary(value))"
      } else if let value = value as? [Any] {
        serializedValue = "\(GraphQLEscapedArray(value))"
      } else {
        serializedValue = "\(value)"
      }

      return "\(key): \(serializedValue)"
    }.joined(separator: ",")

    appendLiteral("{\(output)}")
  }

  mutating func appendInterpolation(_ value: GraphQLEscapedArray) {
    let output = value.value.map { element in
      if let element = element as? String, let escapable = GraphQLEscapedString(element) {
        return "\(escapable)"
      } else if let element = element as? [String: Any] {
        return "\(GraphQLEscapedDictionary(element))"
      } else if let element = element as? [Any] {
        return "\(GraphQLEscapedArray(element))"
      }
      return "\(element)"
    }.joined(separator: ",")

    appendLiteral("[\(output)]")
  }
  
}
