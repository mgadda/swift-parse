//
//  StringParserTests.swift
//  SwiftParse
//
//  Created by Matt Gadda on 1/25/20.
//

import XCTest
@testable import SwiftParse

final class StringParserTests: XCTestCase, ParserHelpers {
  func testMatchCharacterSet() {
    assertParsed(
      match(CharacterSet.alphanumerics)+,
      input: "a3*",
      val: ["a","3"],
      remaining: "*")
    
    assertParsed(
      match(CharacterSet(charactersIn: "a"..."c"))+,
      input: "abd",
      val: ["a","b"],
      remaining: "d"
    )
  }
  
  func testMatchString() {
    assertParsed(
      match("abc"),
      input: "abcd",
      val: "abc",
      remaining: "d")
  }
}
