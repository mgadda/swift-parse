import XCTest
@testable import SwiftParse

class LexicalTests : XCTestCase, ParserHelpers {
  func testWhitespace() {
    let result = whitespace([" "])

    XCTAssertEqual(result!.0, Token.whitespace)
    XCTAssert(result!.1.isEmpty)
  }

  func testDigit() {
    assertParsed(digit, input: ["0"], "0", [Character]())
    assertParsed(digit, input: ["1"], "1", [Character]())
    assertParsed(digit, input: ["2"], "2", [Character]())
    assertParsed(digit, input: ["3"], "3", [Character]())
    assertParsed(digit, input: ["4"], "4", [Character]())
    assertParsed(digit, input: ["5"], "5", [Character]())
    assertParsed(digit, input: ["6"], "6", [Character]())
    assertParsed(digit, input: ["7"], "7", [Character]())
    assertParsed(digit, input: ["8"], "8", [Character]())
    assertParsed(digit, input: ["9"], "9", [Character]())
    assertParsed(digit, input: ["9", "0"], "9", ["0"])
  }

  func testIntegerLiteral() {
    assertParsed(integerLiteral, input: ["1", "2", "3", "4"], Token.integerLiteral(1234), [Character]())
    assertParsed(integerLiteral, input: ["-", "2", "3", "4"], Token.integerLiteral(-234), [Character]())
    assertParsed(integerLiteral, input: ["+", "1", "0"], Token.integerLiteral(10), [Character]())
    assertParsed(integerLiteral, input: ["2", "0", " "], Token.integerLiteral(20), [" "])
  }

  func testLetter() {
    assertParsed(letter, input: ["a"], "a", [Character]())
    assertParsed(letter, input: ["j"], "j", [Character]())
    assertParsed(letter, input: ["z"], "z", [Character]())
    assertParsed(letter, input: ["A"], "A", [Character]())
    assertParsed(letter, input: ["Z"], "Z", [Character]())
  }
}


/*
// Matches a digit followed by whitespace
let digitWhitespace = seq(digit, whitespace)
digitWhitespace(stringToArray("9 6"))
digitWhitespace(stringToArray(" 9")) // nil

// Matches 0 or more spaces
rep(whitespace)(stringToArray("   "))
rep(whitespace)(stringToArray("123"))

// Matches 1 or more spaces
rep1(whitespace)(stringToArray("1")) // nil

let twoWhitespaces = whitespace ~ whitespace
twoWhitespaces(stringToArray("  "))

let zeroOrMoreWhitespaces = whitespace*
zeroOrMoreWhitespaces(stringToArray(""))

let oneOrMoreWhitespaces = whitespace+
oneOrMoreWhitespaces(stringToArray("  0"))

let parenParser = accept("(") <~ whitespace* ~ integerLiteral* ~ whitespace ~> accept(")")
parenParser(stringToArray("( 34 )"))?.0.0.1

integerLiteral(stringToArray("-12345"))

let foo = digit ^^ { (t: Character) -> Int in Int(String(t))! }
let fooResult = foo(stringToArray("3"))
print(fooResult)
*/
