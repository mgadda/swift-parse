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
    _ parser: ([U]) -> (T, [U])?,
    input: [U],
    _ val: T,
    _ next: [U],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let result: (T, [U])? = parser(input)
    XCTAssertEqual(result!.0, val, message, file: file, line: line)
    XCTAssertEqual(result!.1, next, message, file: file, line: line)
  }
}
