import XCTest

protocol ParserHelpers {
  func assertParsed<T: Equatable, U: Equatable>(
    _ parser: ([U]) -> (T, [U])?,
    input: [U],
    _ val: T,
    _ next: [U],
    _ message: @autoclosure () -> String,
    file: StaticString,
    line: UInt
  )
}

extension ParserHelpers {
  func assertParsed<T: Equatable, U: Equatable>(
    _ parser: ([T]) -> (U, [T])?,
    input: [T],
    _ val: U,
    _ remaining: [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let result: (U, [T])? = parser(input)
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.0, val, message(), file: file, line: line)
    XCTAssertEqual(result!.1, remaining, message(), file: file, line: line)
  }

  func assertNotParsed<T: Equatable, U: Equatable>(
    _ parser: ([T]) -> (U, [T])?,
    input: [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    XCTAssertNil(parser(input))
  }
}
