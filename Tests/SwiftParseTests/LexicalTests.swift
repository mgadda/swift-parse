import XCTest
@testable import SwiftParse

class LexicalTests : XCTestCase, ParserHelpers {
  enum ParseToken { case dummy }

  func testWhitespace() {
    let result = whitespaceWithContent([" "])
    
    XCTAssertEqual(result!.0, " ")
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
    assertParsed(integerLiteral, input: ["1", "2", "3", "4"], 1234, [Character]())
    assertParsed(integerLiteral, input: ["-", "2", "3", "4"], -234, [Character]())
    assertParsed(integerLiteral, input: ["+", "1", "0"], 10, [Character]())
    assertParsed(integerLiteral, input: ["2", "0", " "], 20, [" "])
  }

  func testLetter() {
    assertParsed(letter, input: ["a"], "a", [Character]())
    assertParsed(letter, input: ["j"], "j", [Character]())
    assertParsed(letter, input: ["z"], "z", [Character]())
    assertParsed(letter, input: ["A"], "A", [Character]())
    assertParsed(letter, input: ["Z"], "Z", [Character]())
  }

  func testWord() {
    assertParsed(word("swift"), input: ["s", "w", "i", "f", "t"], "swift", [Character]())
  }

  func testCommentWithContent() {
    let parser = commentWithContent(startingWith: "#", until: Character("\n"))
    let result = parser(["#", "a", "b", "\n"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, "ab")
  }

  func testCommentWithToken() {
    let parser = comment(startingWith: "#", token: ParseToken.dummy)
    let result = parser(["#", "a", "\n"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ParseToken.dummy)
  }

  func testCommentStringTerminatorWithContent() {
    let parser = commentWithContent(startingWith: "/*", until: "*/")
    let result = parser(stringToArray("/*a\nbc*/"))
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, "a\nbc")
  }

  func testCommentStringTerminatorWithToken() {
    let parser = comment(startingWith: "/*", until: "*/", token: ParseToken.dummy)
    let result = parser(stringToArray("/*a\nbc*/"))
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ParseToken.dummy)
  }
}
