public enum Token : Equatable {
  case whitespace
  case integerLiteral(Int)
  
  public static func ==(lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
      case (.whitespace, .whitespace): return true
      case let (.integerLiteral(leftVal), .integerLiteral(rightVal)):
        return leftVal == rightVal
      default:
        return false
    }
  }
}

public func whitespace(_ source: [Character]) -> (Token, [Character])? {
  let parser = map(accept(" ")) { _ in Token.whitespace }
  return parser(source)
}

public func letter(_ source: [Character]) -> (Character, [Character])? {
  // Without specify the type signature of this anonymous function
  // the compiler bails with expression complexity issues
  return acceptIf(source) { (ch: Character) -> Bool in
    (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z")
  }
}

public func word(_ value: String) -> ([Character]) -> (String, [Character])? {
  let wordParser = letter+ ^^ { String($0) }

  return { source in
    wordParser(source).filter { $0.0 == value }
  }
}

public func digit(_ source: [Character]) -> (Character, [Character])? {
  return acceptIf(source) { ch in ch >= "0" && ch <= "9" }
}


public func integerLiteral(_ source: [Character]) -> (Token, [Character])? {
  let intParser = (accept("+") | accept("-"))*? ~ rep1(digit)
  
  return intParser(source).flatMap { result in
    var sign = 1
    
    switch result.0.0 {
    case .some("-"):
      sign = -1
    default: break
    }  
    return Int(String(result.0.1)).map { intVal in
      (.integerLiteral(intVal * sign), result.1)
    }
  }
}

