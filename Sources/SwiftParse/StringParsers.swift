//
//  StringParsers.swift
//  SwiftParse
//
//  Created by Matt Gadda on 1/25/20.
//

import Foundation

public func match(_ characterSet: CharacterSet) -> StandardParser<String, Character> {
  return { source in
    guard let first = source.first else {
      return .failure(ParseError(at: source, reason: "unexpected something but found nothing"))
    }
    
    if first.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
      return .success((first, out: source.dropFirst()))
    } else {
      return .failure(ParseError(at: source, reason: "Expected to be in set \(characterSet)"))
    }
  }
}

public func match(_ string: String) -> StandardParser<String, String> {
  return { source in
    let parser = match(prefix: string) ^^ { String($0) }
    return parser(source)
  }
}

extension String : ParserConvertible {
  public func mkParser() -> StandardParser<String, String> {
    return { source in
      let parser = match(prefix: self) ^^ { String($0) }
      return parser(source)
    }
  }
}

extension Character : ParserConvertible {
  public typealias InputType = String
  public typealias ParsedValueType = Character
  public typealias OutputType = String
  public func mkParser() -> StandardParser<String, Character> {
    match(element: self)
  }
}

extension CharacterSet : ParserConvertible {
  public typealias InputType = String
  public typealias ParsedValueType = Character
  public typealias OutputType = String
  public func mkParser() -> StandardParser<String, Character> {
    match(self)
  }
}
