import Foundation

/// Types that implement this protocol can specify a custom format for their
/// GraphQL arguments, and whether quotes are required
protocol GraphQLSerializable {
  var asGraphQLString: String { get }
}

extension GraphQLSerializable {

  var asGraphQLString: String {
    return "\(self)"
  }

}

extension String: GraphQLSerializable {
  
  var asGraphQLString: String {
    return "\"" + escape(string: self) + "\""
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
  
}

extension Dictionary: GraphQLSerializable {

  var asGraphQLString: String {
    let output = self.map { (__val:(Key, Value)) -> String in let (key, value) = __val
      let serializedValue: String
      if let value = value as? GraphQLSerializable {
        serializedValue = value.asGraphQLString
      } else {
        serializedValue = "\(value)"
      }
      
      return "\(key): \(serializedValue)"
    }.joined(separator: ",")
    
    return "{\(output)}"
  }

}

extension Array: GraphQLSerializable {

  var asGraphQLString: String {
    let output = self.map { element in
      if let element = element as? GraphQLSerializable {
        return element.asGraphQLString
      } else {
        return "\(element)"
      }
    }.joined(separator: ",")
    
    return "[\(output)]"
  }

}
