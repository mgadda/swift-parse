import XCTest
@testable import SwiftParse

// TODO: is this a swift bug? Why does it need to be redefined here everywhere it's useed?
infix operator ~>: MultiplicationPrecedence

final class ParserTests: XCTestCase, ParserHelpers {
  enum Token : Equatable {
    case int(Int)
  }
    
  func testAcceptIfString() {
    let digit: StandardParser<String, Character> = { source in
      matchOneIf(source) { char in char >= "0" && char <= "9" }
    }
    let digits = digit+
    assertParsed(digits, input: "10", val: ["1", "0"], remaining: "")
  }
  
  func testMatchChar() {
    assertParsed(match(element: Character("a")),
                 input: "abcd", val: "a", remaining: "bcd")
  }
  func testAcceptString() {
    assertParsed(match("ab"),
                 input: "abcd",
                 val: AnyCollection("ab"),
                 remaining: "cd")
  }
  
  func testAcceptOneOf() {
    assertParsed(match(oneOf: "ab"), input: "a", val: "a", remaining: "")
    assertParsed(match(oneOf: "ab"), input: "b", val: "b", remaining: "")
  }

  func testAcceptArray() {
    assertParsed(match(element: 1),
                 input: [1,2,3],
                 val: 1,
                 remaining: [2,3])
  }
  
  func testAcceptFn() {

    func TokenInt(t: Token) -> Bool {
      if case .int = t { return true } else { return false }
    }

    assertParsed(match(TokenInt), input: [Token.int(1)], val: Token.int(1), remaining: [])
  }
  
//  func testAcceptRange() {
//    let a2z: ClosedRange<Character> = "a"..."z"
//    let lowerAlphabet: StandardParser<String, String.Element> = match(range: a2z)
//    assertParsed(lowerAlphabet, input: "abcd", val: ["a", "b", "c", "d"], remaining: "")
//  }

  func testRejectAllOf() {
    assertParsed(reject(anyOf: "-=+"), input: "a", val: "a", remaining: "")
    assertNotParsed(reject(anyOf: "-=+"), input: "-")
    assertNotParsed(reject(anyOf: "-=+"), input: "=")
  }
  
  func testRejectArray() {
    assertNotParsed(reject(value: 1), input: [1,2,3])
    assertParsed(reject(value: 4)+,
                    input: [1,2,3,4],
                    val: [1,2,3], remaining: [4])
  }
  
  func testGuard() {
    assertParsed(lookAhead(match("a")),
                 input: "a",
                 val: AnyCollection("a"), remaining: "a")
  }
  
  func testNot() {
    let p = not(match("a"))
    switch p(AnyCollection("b")) {
    case let .success((_, remainder)):
      XCTAssertEqual(remainder, AnyCollection("b"))
    case let .failure(e):
      XCTFail(e.reason!)
    }
  }

  func testSeqArray() {
    let parser = compose(match(element: 1), match(element: 2))
    let result = try! parser(AnyCollection([1,2,3])).get()
    let val = (1,2)
    let remaining = [3]
        
    XCTAssert(result.0 == val, "was \(val)")
    XCTAssertEqual(Array(result.1), remaining)
  }

  func testSeqString() {
    let parser = map(compose(match("ab"), match("cd"))) {
      (ab, cd) in String(ab) + String(cd)
    }

    assertParsed(parser, input: "abcdef", val: "abcd", remaining: "ef")
  }

  func testMultiSeq() {
    let abc = match("a") ~ match("b") ~ match("c")

    let parser = map(abc) { (x, y, z) -> String in
      return String(y)
    }
    assertParsed(parser, input: "abc", val: "b", remaining: "")

  }

  func testSeqOperators() {
    let parser = match("a") <~ match("b") ~> match("c")
    assertParsed(parser, input: "abc", val: AnyCollection("b"), remaining: "")
  }

  func testMap() {
    let parser = map(match("a")) { String($0).capitalized }
    assertParsed(parser, input: "ab", val: "A", remaining: "b")
  }

  func testMapOperator() {
    assertParsed(match("a") ^^ { String($0).capitalized }, input: "a", val: "A", remaining: "")
    
    let abcd = match("a") ~ match("b") ~ match("c") ~ match("d")
    let parser = abcd ^^ { (x, y, z, w) in AnyCollection([x,y,z,w].joined()) }
    
    assertParsed(parser, input: "abcd", val: AnyCollection("abcd"), remaining: "")
  }

  func testRep() {
    let aParser = rep(match("a")) ^^ { AnyCollection($0.joined()) }
    assertParsed(aParser, input: "aaabbb", val: AnyCollection("aaa"), remaining: "bbb")
    
    assertParsed(aParser, input: "bbb", val: AnyCollection<Character>([]), remaining: "bbb")
  }

  func testRepOperator() {
    let parser = match("a")* ^^ { AnyCollection($0.joined())}
    assertParsed(parser, input: "aaabbb", val: AnyCollection("aaa"), remaining: "bbb")
    assertParsed(parser, input: "bbb", val: AnyCollection([]), remaining: "bbb")
  }

  func testRep1() {
    let parser = rep1(match("a")) ^^ { AnyCollection($0.joined()) }
    assertParsed(parser, input: "aaabbb", val: AnyCollection("aaa"), remaining: "bbb")
    assertNotParsed(rep1(match("a")), input: "bbb")

  }

  func testRep1Operator() {
    let parser = match("a")+ ^^ { AnyCollection($0.joined()) }
    assertParsed(parser, input: "aaabbb", val: AnyCollection("aaa"), remaining: "bbb")
    assertNotParsed(parser, input: "bbb")
  }

  func testOr() {
    assertParsed(or(match("a"), match("b")), input: "b", val: AnyCollection("b"), remaining: "")
  }
  
  func testEither() {
    let a = map(match("a")) { _ in 0 }
    let b = match("b")
    let parser = either(a, b)
    assertParsed(parser, input: "a", val: Either.left(0), remaining: "")
  }

  func testEof() {
    let parser = match("a") ~> eof

    assertParsed(parser, input: "a", val: AnyCollection("a"), remaining: "")
    assertNotParsed(parser, input: "")
    assertParsed(
      either(match("a"), eof),
      input: "a",
      val: Either.left(AnyCollection("a")),
      remaining: "")
    assertParsed(
      either(match("a"), eof),
      input: "",
      val: Either.right(Nothing()),
      remaining: "")
  }
  
  func testOrOperators() {
    let a = match("a")
    let b = match("b")
    let aOrB = a | b
    assertParsed(aOrB, input: "a", val: AnyCollection("a"), remaining: "")
  }

  func testOpt() {
    assertParsed(opt(match("a")), input: "ab", val: AnyCollection("a"), remaining: "b")
    assertParsed(opt(match("a")), input: "b", val: Optional.none, remaining: "b")
  }

  func testOptOperator() {
    let a = match("a")*?
    assertParsed(a, input: "ab", val: AnyCollection("a"), remaining: "b")
    assertParsed(a, input: "b", val: Optional.none, remaining: "b")
  }

  static var allTests = [
      ("testAcceptstring", testAcceptString),
      ("testAcceptArray", testAcceptArray),
      ("testRejectArray", testRejectArray),
      ("testSeqArray", testSeqArray),
      ("testSeqString", testSeqString),
      ("testMultiSeq", testMultiSeq),
      ("testSeqOperators", testSeqOperators),
      ("testMap", testMap),
      ("testMapOperator", testMapOperator),
      ("testRep", testRep),
      ("testRepOperator", testRepOperator),
      ("testRep1", testRep1),
      ("testRep1Operator", testRep1Operator),
      ("testOr", testOr),
      ("testOrOperator", testMapOperator),
      ("testOpt", testOpt),
      ("testOptOperator", testOptOperator)
  ]
}
