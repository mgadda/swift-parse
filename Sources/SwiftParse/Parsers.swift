//
//  Parsers.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

/// A generic parser (a function) representing a parsing computation
/// which reads one or more values from some `SourceType` (which must be a `Collection`)
/// and produces a `ParsedValueType` and some remaining `OutputType`
public typealias Parser<InputElement, ParsedValue, OutputElement> =
  (AnyCollection<InputElement>) -> ParseResult<AnyCollection<InputElement>, ParsedValue, AnyCollection<OutputElement>>

/// When the type from which values are parsed is the same before and after parsing, and that type conforms to `Collection`
/// we call this a `StandardParser`.
public typealias StandardParser<T: Collection, U> = Parser<T.Element, U, T.Element>

/// A parser whose `ParsedValueType` is the same as `InputType.Element`
/// A `HomogeneousParser` is useful in situations where you need to match a string prefix. The
/// resulting types are usually all subsequences of the same type.
/// Example:
/// ```
/// match("a")("abc")
/// ```
/// This parser expects to parse a `Substring` into a `Substring` (the matched valued) and
/// another `Substring` (the remainder).
public typealias HomogeneousParser<T: Collection> = StandardParser<T, T>

/// When parser fails, it returns a `ParseError` describing the reason
/// and location of the failure.
public struct ParseError<Element> : Error {
  public let at: AnyCollection<Element>
  public let reason: String?
  public init(at: AnyCollection<Element>, reason: String? = .none) {
    self.at = at
    self.reason = reason
  }
}

/// A protocol that can be used to make objects such as String or Array literals
/// behave implicitly as parsers that match themselves, when used in appropriate contexts.
/// Example:
/// ```
/// let parser = "(" ~ value ~ ")"
/// ```
/// The common types have extensions included with SwiftParse so that the
/// above Just Works™.
public protocol ParserConvertible {
  associatedtype InputType: Collection = Self
  associatedtype ParsedValueType = Self
  associatedtype OutputType: Collection = Self
  func mkParser() -> Parser<InputType.Element, ParsedValueType, OutputType.Element>
}

/// All parsers return a `ParseResult` to indicate success or failure.
public typealias ParseResult<InputType: Collection, ParsedValueType, OutputType> =
  Try<(value: ParsedValueType, out: OutputType), ParseError<InputType.Element>>


/// A parser which matches the prefix `pattern`
public func match<InputType: Collection>(prefix: InputType) ->
  StandardParser<InputType, AnyCollection<InputType.Element>> where
    InputType.Element : Equatable
{
  return { source in
    if source.starts(with: prefix, by: { $0 == $1 }) {
      return .success((source.prefix(prefix.count), AnyCollection(source).dropFirst(prefix.count)))
    } else {
      return .failure(ParseError(at: source, reason: "expected \(prefix)"))
    }
  }
}

public func match<InputElement: Equatable>(element: InputElement) -> StandardParser<AnyCollection<InputElement>, InputElement> {
  return { source in
    // TODO: should match(prefix:) be rewritten to use match(element:)?
    // i.e. inverting the dependency? or would that just introduce inefficiencies
    // and perhaps both of these methods should have their own implementation
    return match(prefix: [element])(source).flatMap { (value, remainder) in
      return value
        .first
        .liftToTry(orFailWith: ParseError(at: source, reason: "expected \(element) but found nothing"))
        .map { ($0, remainder) }
    }
  }
}

func match<InputType: Collection>(range: ClosedRange<InputType.Element>) -> StandardParser<InputType, InputType.Element> {
  return { source in
    guard let first = source.first else {
      return .failure(ParseError(at: source, reason: "expected range \(range) but found nothing"))
    }

    if range.contains(first) {
      return .success((first, source.dropFirst()))
    } else {
      return .failure(ParseError(at: source, reason: "expected \(first) to be in range \(range)"))
    }
  }
}

/// Generates a parser that matches one of the characters contained within `oneOf`
public func match<InputElement: Equatable, SetLike: SetAlgebra>(oneOf pattern: SetLike) -> Parser<InputElement, InputElement, InputElement> where SetLike.Element == InputElement {
  return { source in
    // TODO: extract this into a method/Result for reuse
    guard let first = source.first else {
      return .failure(ParseError(at: source, reason: "unexpected something but found nothing"))
    }
    
    if pattern.contains(first) {
      return .success((first, source.dropFirst()))
    }
    
    return .failure(ParseError(at: source, reason: "expected one of \(pattern)"))
  }
}

public func match<T>(_ fn: @escaping (T) -> Bool) -> Parser<T, T, T> {
  return { source in
    guard let first = source.first else {
      return .failure(ParseError(at: source, reason: "expected something but found nothing"))
    }

    if fn(first) {
      return .success((first, source.dropFirst()))
    } else {
      // TODO: make this error message useful
      return .failure(ParseError(at: AnyCollection(source), reason: "match failed because \(String(describing: fn)) returned false"))
    }
  }
}

// TODO: should `matchIf` really require source to be present
// at the time in which the parser is generated?
// And if not, then matchIf could be rewritten using `match(fn:)` above.
public func matchOneIf<InputElement>(_ source: AnyCollection<InputElement>, fn: @escaping (InputElement) -> Bool) -> ParseResult<AnyCollection<InputElement>, InputElement, AnyCollection<InputElement>> {
  
  guard let first = source.first else {
    return .failure(ParseError(at: source))
  }
  
  if fn(first) {
    return .success((first, source.dropFirst()))
  } else {
    // matchOneIf is a building block so caller
    // is expected to provide a meaningful failure reason
    return .failure(ParseError(at: source))
  }
}

public func reject<InputElement>(element: InputElement) -> Parser<InputElement, InputElement, InputElement> where InputElement : Equatable {
  return { source in
    matchOneIf(source) { $0 != element }.handle {
      if let _ = $0.reason {
        return $0
      } else {
        return ParseError(at: $0.at, reason: "expected next token to not equal \(element)")
      }
    }
  }
}

/// Generates a `Parser` that succeeds if the first element in the `Collection`
/// being parsed is not any of the characters found in `anyOf`.
public func reject<T: Collection>(anyOf pattern: T) -> StandardParser<T, T.Element>
  where T.Element : Equatable {
  return { source in
    for ch in pattern {
      if case .success = matchOneIf(source, fn: { $0 == ch }) {
        return .failure(ParseError(at: AnyCollection(source), reason: "did not expect \(ch)"))
      }
    }
    if let first = source.first {
      return .success((first, source.dropFirst()))
    } else {
      return .failure(ParseError(at: AnyCollection(source), reason: "unexpectedly at end of input"))
    }
  }
}

/// Generates a parser that succeeds when `parser` succeeds but
/// consumes no tokens from the input. This method could have
/// been called `guard` if that weren't a keyword.
public func lookAhead<T, InputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>
) -> Parser<InputElement, T, InputElement> {
  return { source in
    parser()(source).map { (value, _) in
      (value, source)
    }
  }
}

/// Generates a parser that succeeds with a void value and consumes
/// no tokens from the input when `parser` fails; fails when
/// `parser` succeeds and consumes no tokens from the input.
public func not<ParsedValue, InputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ParsedValue, InputElement>
) -> Parser<InputElement, Void, InputElement> {
  return { source in
    switch parser()(source) {
    case let .success((value, _)):
      return .failure(ParseError(at: source, reason: "Expected failure but found \(value)"))
    case .failure:
      return .success(((), source))
    }
  }
}

/// A parser that succeeds when `left` and `right` both succeed in order.
/// The output of the first is passed to the input of the second.
func compose<T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<T, (LeftParsedValue, RightParsedValue), V>
{
  return { source in
    left()(source).flatMap { leftResult in
      right()(leftResult.1).map { rightResult in
        ((leftResult.0, rightResult.0), rightResult.1)
      }.handle {
        ParseError(at: source, reason: $0.reason)
      }
    }
  }
}

func compose<ParserTU: ParserConvertible, ParserUV: ParserConvertible>(
  _ left: ParserTU,
  _ right: ParserUV
) -> Parser<
  ParserTU.InputType.Element,
  (ParserTU.ParsedValueType, ParserUV.ParsedValueType),
  ParserUV.OutputType.Element> where
  ParserTU.OutputType == ParserUV.InputType
{
  return compose(left.mkParser(), right.mkParser())
}

func compose<T, U, LeftParsedValue, ParserUV: ParserConvertible>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: ParserUV
) -> Parser<T, (LeftParsedValue, ParserUV.ParsedValueType), ParserUV.OutputType.Element> where
  U == ParserUV.InputType.Element
{
  return compose(left(), right.mkParser())
}

func compose<ParserTU: ParserConvertible, U, V, RightParsedValue>(
  _ left: ParserTU,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<ParserTU.InputType.Element, (ParserTU.ParsedValueType, RightParsedValue), V> where
  ParserTU.OutputType.Element == U
{
  return compose(left.mkParser(), right())
}

/// Generates a parser that suceeds if `parser` succeeds zero or more times.
/// This parser never fails.
public func rep<InputElement, ParsedValue>(_ parser: @autoclosure @escaping () -> Parser<InputElement, ParsedValue, InputElement>) -> Parser<InputElement, [ParsedValue], InputElement> {
  return { source in
    // TODO: determine if tail call optimization happens here
    // manually optimize if not.
    func aggregate(remaining: AnyCollection<InputElement>, parsedValues: [ParsedValue]) -> ([ParsedValue], AnyCollection<InputElement>) {
      if case let .success(result) = parser()(remaining) {
        return aggregate(
          remaining: result.1,
          parsedValues: parsedValues + [result.0]
        )
      }
      return (parsedValues, remaining)
    }

    return .success(aggregate(remaining: source, parsedValues: []))
  }
}

/// Generators a parser that succeeds if `parser` succeeds at least once and fails if `parser` fails.
public func rep1<InputElement, ParsedValue>(_ parser: @autoclosure @escaping () -> Parser<InputElement, ParsedValue, InputElement>) -> Parser<InputElement, [ParsedValue], InputElement> {
  let repParser = rep(parser())
  return map(compose(parser(), repParser)) { (first, rest) in
    [first] + rest
  }
}

/// Generates a heterogeneous parser that succeeds if either `left` or `right` succeeds. `left` is
/// executed first and then right if `left` fails. This parser fails if both `left` and `right` fail.
/// The parsed output of `left` and `right` must be different types.
public func either<T, U, InputElement, OutputElement>(
  _ left: @autoclosure @escaping () -> Parser<InputElement, T, OutputElement>,
  _ right: @autoclosure @escaping () -> Parser<InputElement, U, OutputElement>
) -> Parser<InputElement, Either<T, U>, OutputElement> {
  return { source in
    if case let .success((value, remainder)) = left()(source) {
      return .success((.left(value), remainder))
    } else if case let .success((value, remainder)) = right()(source) {
      return .success((.right(value), remainder))
    } else {
      return .failure(ParseError(at: source))
    }
  }
}

/// Generates a homogenous parser that succeeds if either `left` or `right` succeeds. `left` is
/// executed first and then right if `left` fails. This parser fails if both `left` and `right` fail.
/// The parsed output of `left` and `right` must be the same  type `T`.
public func or<T, U, ParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, ParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<T, ParsedValue, U>
) -> Parser<T, ParsedValue, U> {
  return { source in
    var underlyingErrors: [String] = []

    let leftResult = left()(source)
    switch leftResult {
    case .success: return leftResult
    case let .failure(e):
      if let reason = e.reason {
        underlyingErrors.append(reason)
      }
    }

    let rightResult = right()(source)
    switch rightResult {
    case .success: return rightResult
    case let .failure(e):
      if let reason = e.reason {
        underlyingErrors.append(reason)
      }
    }

    return .failure(ParseError(
      at: source,
      reason: underlyingErrors.joined(separator: " or "))
    )
  }
}

/// Generates a parser that always succeeds regardless of whether the underlying parser succeeds.
/// If `parser` succeeds, its value is returned as the parsed result. If `parser` fails, None is returned
/// as the parsed result.
public func opt<InputElement, ParsedValue>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ParsedValue, InputElement>
) -> Parser<InputElement, ParsedValue?, InputElement> {
  return { source in
    switch parser()(source) {
    case let .success(s): return .success(s)
    case .failure: return .success((nil, source))
    }
  }
}

/// A stand-in parser that fails for all input. It should be used to construct mutually recursive parser definitions
public func placeholder<T, InputElement>(_ source: AnyCollection<InputElement>) -> ParseResult<AnyCollection<InputElement>, T, AnyCollection<InputElement>> {
  return .failure(ParseError(at: source, reason: "Not yet implemented"))
}

/// A parser that matches only if `source` is empty.
public func eof<InputType: Collection>(_ source: InputType) -> ParseResult<InputType, Nothing, InputType> {
  if source.isEmpty {
    return .success((nil, source))
  } else {
    return .failure(ParseError(at: AnyCollection(source), reason: "Expected eof but found something"))
  }
}
