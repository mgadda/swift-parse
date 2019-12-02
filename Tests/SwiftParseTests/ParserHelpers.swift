import XCTest
@testable import SwiftParse

protocol ParserHelpers {
  func assertParsed<T: Equatable, U: Equatable>(
    _ parser: Parser<T, U>,
    input: T,
    val: U,
    remaining: T,
    message: @autoclosure () -> String,
    file: StaticString,
    line: UInt
  )
}

extension ParserHelpers {
  func assertParsed<T: Equatable, U: Equatable>(
        _ parser: Parser<T, U>,
    input: T,
    val: U,
    remaining: T,
    message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let result: (U, T)? = parser(input)
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, val, message(), file: file, line: line)
    XCTAssertEqual(result!.1, remaining, message(), file: file, line: line)
  }

  func assertNotParsed<T: Equatable, U: Equatable>(
    _ parser: (T) -> (U, T)?,
    input: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    XCTAssertNil(parser(input))
  }
}
