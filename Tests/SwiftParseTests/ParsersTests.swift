import XCTest
@testable import SwiftParse

// TODO: is this a swift bug? Why does it need to be redefined here everywhere it's useed?
infix operator ~>: MultiplicationPrecedence

final class ParserTests: XCTestCase, ParserHelpers {
  enum Token : Equatable {
    case int(Int)
  }
  
  func testAcceptIfString() {
    let digit: StringParser<String> = { source in
      acceptIf(source) { char in char >= "0" && char <= "9" }
    }
    let digits = digit+
    assertParsed(digits, input: "10", val: ["1", "0"], remaining: "")
  }
  
  func testAcceptString() {
    assertParsed(accept("ab"),
                 input: "abcd",
                 val: "ab",
                 remaining: "cd")
  }
  
  func testAcceptOneOf() {
    assertParsed(accept(oneOf: "ab")+, input: "abc", val: ["a", "b"], remaining: "c")
  }

  func testAcceptArray() {
    assertParsed(accept(1),
                 input: [1,2,3],
                 val: 1,
                 remaining: [2,3])
  }
  
  func testAcceptFn() {
    func TokenInt(t: Token) -> Bool {
      if case .int = t { return true } else { return false }
    }
    
    assertParsed(accept(TokenInt), input: [Token.int(1)], val: Token.int(1), remaining: [])
  }
  
  func testAcceptRange() {
    let lowerAlphabet = accept(range: "a"..."z")+
    assertParsed(lowerAlphabet, input: "abcd", val: ["a", "b", "c", "d"], remaining: "")
  }

  func testRejectCharacter() {
    assertNotParsed(reject(character: "a"), input: "abc")
    assertParsed(reject(character: "a")+,
                    input: "bcda",
                    val: ["b", "c", "d"], remaining: "a")
  }
  
  func testRejectAllOf() {
    assertParsed(reject(allOf: "-=+"), input: "a", val: "a", remaining: "")
    assertNotParsed(reject(allOf: "-=+"), input: "-")
    assertNotParsed(reject(allOf: "-=+"), input: "=")
  }
  
  func testRejectArray() {
    assertNotParsed(reject(value: 1), input: [1,2,3])
    assertParsed(reject(value: 4)+,
                    input: [1,2,3,4],
                    val: [1,2,3], remaining: [4])
  }

  func testSeqArray() {
    let parser = seq(accept(1), accept(2))
    let result = parser([1,2,3])
    let val = (1,2)
    let remaining = [3]

    XCTAssert(result!.0 == val, "was \(val)")
    XCTAssertEqual(Array(result!.1), remaining)
  }

  func testSeqString() {
    let parser = seq(accept("a"), accept("b"))
    let result = parser("abcd")
    let val = ("a", "b")
    let remaining = "cd"

    // TODO: should value be "ab" for strings? and ["a", "b"] for arrays?
    XCTAssert(result!.0 == val, "expected: \(val) got: \(result!.0)")
    XCTAssertEqual(String(result!.1), remaining)
  }

  func testMultiSeq() {
    let abc = accept("a") ~ accept("b") ~ accept("c")

    let parser = map(abc) { (x, y, z) -> String in
      return y
    }
    assertParsed(parser, input: "abc", val: "b", remaining: "")

  }

  func testSeqOperators() {
    let parser = accept("a") <~ accept("b") ~> accept("c")
    assertParsed(parser, input: "abc", val: "b", remaining: "")
  }

  func testMap() {
    let parser = map(accept("a")) { $0.capitalized }
    assertParsed(parser, input: "ab", val: "A", remaining: "b")
  }

  func testMapOperator() {
    assertParsed(accept("a") ^^ { $0.capitalized }, input: "a", val: "A", remaining: "")
    
    let abcd = accept("a") ~ accept("b") ~ accept("c") ~ accept("d")
    let parser = abcd ^^ { (x, y, z, w) in [x,y,z,w].joined() }
    
    assertParsed(parser, input: "abcd", val: "abcd", remaining: "")
  }

  func testRep() {
    // TODO: should val be "aaa" instead of an array? and would this eliminate the need for many
    // definitions of map?
    assertParsed(rep(accept("a")), input: "aaabbb", val: ["a", "a", "a"], remaining: "bbb")
    assertParsed(rep(accept("a")), input: "bbb", val: [], remaining: "bbb")
  }

  func testRepOperator() {
    let a = accept("a")
    assertParsed(a*, input: "aaabbb", val: ["a", "a", "a"], remaining: "bbb")
    assertParsed(a*, input: "bbb", val: [], remaining: "bbb")
  }

  func testRep1() {
    assertParsed(rep1(accept("a")), input: "aaabbb", val: ["a", "a", "a"], remaining: "bbb")
    assertNotParsed(rep1(accept("a")), input: "bbb")

  }

  func testRep1Operator() {
    let a = accept("a")
    assertParsed(a+, input: "aaabbb", val: ["a", "a", "a"], remaining: "bbb")
    assertNotParsed(a+, input: "bbb")
  }

  func testOr() {
    assertParsed(or(accept("a"), accept("b")), input: "b", val: "b", remaining: "")
  }
  
  func testEither() {
    let a = map(accept("a")) { _ in 0 }
    let b = accept("b")
    let parser = either(a, b)
    assertParsed(parser, input: "a", val: Either.left(0), remaining: "")
  }

  func testOrOperators() {
    let a = accept("a")
    let b = accept("b")
    let aOrB = a | b
    assertParsed(aOrB, input: "a", val: "a", remaining: "")
  }

  func testOpt() {
    assertParsed(opt(accept("a")), input: "ab", val: "a", remaining: "b")
    assertParsed(opt(accept("a")), input: "b", val: Optional.none, remaining: "b")
  }

  func testOptOperator() {
    let a = accept("a")
    assertParsed(a*?, input: "ab", val: "a", remaining: "b")
    assertParsed(a*?, input: "b", val: Optional.none, remaining: "b")
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
