import XCTest
@testable import SwiftParse

class UtilTests : XCTestCase {
  func testStringToArray() {
    XCTAssertEqual(stringToArray("1234"), ["1", "2", "3", "4"])
  }
}
