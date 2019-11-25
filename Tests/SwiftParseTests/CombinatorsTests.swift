import XCTest
@testable import SwiftParse

class CombinatorsTests : XCTestCase, ParserHelpers {
  func testHead() {
    let result = head(["0", "1", "2"])
    XCTAssertEqual(result!, "0")
  }
  func testEmptyHead() {
    let result = head([])
    XCTAssertNil(result)
  }

  func testTail() {
    var result = tail(["1", "2"])
    XCTAssertEqual(result, ["2"])

    result = tail(["2"])
    XCTAssertEqual(result, [])
  }

  func testEmptyTail() {
    let result: [Character] = tail([])
    XCTAssertEqual(result, [Character]())
  }

  func testNot() {
    assertParsed(not("a"), input: ["b", "c"], "b", ["c"])
    assertNotParsed(not("a"), input: ["a", "b"])
  }

  func testNotParser() {
    let notSpace = not(char(" "))
    assertParsed(notSpace, input: ["a", "b"], "a", ["b"])
    assertNotParsed(notSpace, input: [" ", "b"])
  }

  func testUntil() {
    let parser = until(Character("\n"))
    let result = parser(["a", "b" ,"\n"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ["a", "b"])
    XCTAssertEqual(result!.1, ["\n"])
  }

  func testUntilParser() {
    let parser = until(char("\n"))
    let result = parser(["a", "b" ,"\n"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ["a", "b"])
    XCTAssertEqual(result!.1, ["\n"])
  }

  func testAcceptValue() {
    assertParsed(accept("a"), input: ["a", "b"], "a", ["b"])
    assertNotParsed(accept("a"), input: ["b"])
  }

  func testAcceptMultipleSubset() {
    let parser = accept(["a", "b"])
    let result = parser(["a", "b", "c", "d"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ["a", "b"])
    XCTAssertEqual(result!.1, ["c", "d"])
  }

  func testAcceptMultipleEntirety() {
    let parser = accept(["a", "b"])
    let result = parser(["a", "b"])
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, ["a", "b"])
    XCTAssertEqual(result!.1, [])
  }

  func testAcceptMultipleNoMatch() {
    let parser = accept(["a", "c"])
    let result = parser(["a", "b", "c", "d"])
    XCTAssertNil(result)
  }
}
