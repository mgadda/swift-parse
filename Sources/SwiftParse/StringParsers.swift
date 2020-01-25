//
//  StringParsers.swift
//  SwiftParse
//
//  Created by Matt Gadda on 1/25/20.
//

import Foundation

public func match(characterSet: CharacterSet) -> StandardParser<String, Character> {
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
