import XCTest
@testable import SwiftParse

protocol ParserHelpers {
  func assertParsed<InputType: Collection, ParsedValue: Equatable, OutputType: Collection>(
    _ parser: Parser<InputType.Element, ParsedValue, OutputType.Element>,
    input: InputType,
    val: ParsedValue,
    remaining: OutputType,
    message: @autoclosure () -> String,
    file: StaticString,
    line: UInt
  ) where InputType.Element: Equatable, OutputType.Element: Equatable
}

extension AnyCollection : Equatable where Element: Equatable {
  public static func ==(lhs: AnyCollection<Element>, rhs: AnyCollection<Element>) -> Bool {
    lhs.elementsEqual(rhs) { $0 == $1 }
  }
}

extension ParserHelpers {
  func assertParsed<InputType: Collection, ParsedValue: Equatable, OutputType: Collection>(
        _ parser: Parser<InputType.Element, ParsedValue, OutputType.Element>,
    input: InputType,
    val: ParsedValue,
    remaining: OutputType,
    message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) where InputType.Element: Equatable, OutputType.Element: Equatable
  {
    switch parser(AnyCollection(input)) {
    case let .success(s):
      XCTAssertEqual(s.0, val, message(), file: file, line: line)
      XCTAssertEqual(s.1, AnyCollection(remaining), message(), file: file, line: line)
    case let .failure(e): XCTFail("Failed to parse at \(e.at)", file: file, line: line)
    }    
  }
  
  func assertNotParsed<InputType: Collection, ParsedValue: Equatable, OutputType>(
    _ parser: Parser<InputType.Element, ParsedValue, OutputType>,
    input: InputType,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    switch parser(AnyCollection(input)) {
    case .success: XCTFail(message(), file: file, line: line)
    case .failure: return
    }
  }
}
