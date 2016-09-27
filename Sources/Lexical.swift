enum Token : Equatable {
  case whitespace
  case integerLiteral(Int)
  case stringLiteral(String)
  case symbol(Character)

  static func ==(lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
      case (.whitespace, .whitespace): return true
      case let (.integerLiteral(leftVal), .integerLiteral(rightVal)):
        return leftVal == rightVal
      case let (.stringLiteral(leftVal), .stringLiteral(rightVal)):
        return leftVal == rightVal
      case let (.symbol(leftVal), .symbol(rightVal)):
        return leftVal == rightVal
      default:
        return false
    }
  }
}

func whitespace(_ source: [Character]) -> (Token, [Character])? {
  let parser = map(accept(" ")) { _ in Token.whitespace }
  return parser(source)
}

func letter(_ source: [Character]) -> (Character, [Character])? {
  // Without specify the type signature of this anonymous function
  // the compiler bails with expression complexity issues
  return acceptIf(source) { (ch: Character) -> Bool in
    (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z")
  }
}
func digit(_ source: [Character]) -> (Character, [Character])? {
  return acceptIf(source) { ch in ch >= "0" && ch <= "9" }
}

func integerLiteral(_ source: [Character]) -> (Token, [Character])? {
  let intParser = (accept("+") | accept("-"))*? ~ rep1(digit)
  return intParser(source).flatMap { result in
    var sign = 1

    if let signResult = result.0.0 {
      switch signResult {
      case .right:
        sign = -1
      default: break
      }
    }

    return Int(String(result.0.1)).map { intVal in
      (.integerLiteral(intVal * sign), result.1)
    }
  }
}

