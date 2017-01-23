import SwiftExt

// TODO: replace HeterogeneousParser references below with this typealias
// once Xcode 8.2, which fixes  https://bugs.swift.org/browse/SR-3640 has 
// been released.
//
// typealias LexicalParser = HeterogeneousParser<Character, String>

public func whitespace<T>(token: T) -> HeterogeneousParser<Character, T> {
  let parser = whitespaceWithContent ^^ { _ in token }
  return { source in
    parser(source)
  }
}

public func whitespaceWithContent(_ source: [Character]) -> (String, [Character])? {
  let parser = char(" ") | char("\n") | char("\t")
  return parser(source)
}

public func letter(_ source: [Character]) -> (Character, [Character])? {
  // Without specify the type signature of this anonymous function
  // the compiler bails with expression complexity issues
  return acceptIf(source) { (ch: Character) -> Bool in
    (ch >= "a" && ch <= "z") || (ch >= "A" && ch <= "Z")
  }
}

public func word(_ value: String) -> HeterogeneousParser<Character, String> {
  let wordParser = letter+ ^^ { String($0) }

  return { source in
    wordParser(source).filter { $0.0 == value }
  }
}

public func char(_ value: Character) -> HeterogeneousParser<Character, String> {
  return accept(value) ^^ { String($0) }
}

public func digit(_ source: [Character]) -> (Character, [Character])? {
  return acceptIf(source) { ch in ch >= "0" && ch <= "9" }
}


public func integerLiteral(_ source: [Character]) -> (Int, [Character])? {
  let intParser = (char("+") | char("-"))*? ~ rep1(digit)

  return intParser(source).flatMap { result in
    var sign = 1

    switch result.0.0 {
    case .some("-"):
      sign = -1
    default: break
    }
    return Int(String(result.0.1)).map { intVal in
      (intVal * sign, result.1)
    }
  }
}

// TODO: support multi-character (String) stopChars 
public func comment<T>(startingWith: String, until stopChar: Character = "\n", token: T) -> HeterogeneousParser<Character, T> {
  let parser = commentWithContent(startingWith: startingWith, until: stopChar) ^^ { _ in token }
  return { source in parser(source) }
}

public func commentWithContent(startingWith: String, until stopChar: Character = "\n") -> HeterogeneousParser<Character, String> {
  let parser = accept(stringToArray(startingWith)) ~ until(stopChar) ^^ { (_, comment) in String(comment) }
  return { source in parser(source) }
}

public func comment<T>(startingWith: String, until endingWith: String, token: T) -> HeterogeneousParser<Character, T> {
  let parser = commentWithContent(startingWith: startingWith, until: endingWith) ^^ { _ in token }
  return { source in parser(source) }
}

public func commentWithContent(startingWith: String, until endingWith: String) -> HeterogeneousParser<Character, String> {
  let startWithParser = accept(stringToArray(startingWith))
  let endingWithParser = accept(stringToArray(endingWith))

  let parser = startWithParser ~ until(endingWithParser) ^^ { (_, comment) in String(comment) }
  return { source in parser(source) }
}

