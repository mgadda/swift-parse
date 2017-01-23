import XCTest
@testable import SwiftParse

class CombinatorsTests : XCTestCase {
  func testHead() {
    let result = head(["0", "1", "2"])
    XCTAssertEqual(result!, .some("0"))
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
}
