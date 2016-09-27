import XCTest
@testable import SwiftParse

class CombinatorsTests : XCTestCase {
  func testHead() {
    let result = head(["0", "1", "2"])
    XCTAssertEqual(result!, .some("0"))
  }
}
