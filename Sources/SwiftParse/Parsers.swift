//
//  Parsers.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

public struct ParseError<T> : Error {
  public let at: T
  public let reason: String?
  public init(at: T, reason: String? = .none) {
    self.at = at
    self.reason = reason
  }
}

public typealias ParseResult<T, U> = Try<(U, T), ParseError<T>>

/// A generic parser (a function) from `SourceType` to `OutputType`
/// The remaining unparsed values are returned as the second element of the tuple.
public typealias Parser<T, U> = (T) -> ParseResult<T, U>

/// A parser from String to instance of type `U`
public typealias StringParser<U> = Parser<Substring, U>

/// A parser from `Array<T>` to instances of type `U`
public typealias ArrayParser<T, U> = Parser<ArraySlice<T>, U>

/// Generates a parser that matches a String `pattern` of arbitrary length.
/// This parser binds the source type as Substring which cannot be altered for the lifetime of the parse.
public func accept(_ pattern: String) -> StringParser<String> {
  return { source in
    if source.starts(with: pattern) {
      return .success((pattern, source.dropFirst(pattern.count)))
    } else {
      return .failure(ParseError(at: source))
    }
  }
}

public func accept(range: ClosedRange<Character>) -> StringParser<String> {
  return { source in
    acceptIf(source) { range.contains($0) }
  }
}
/// Generates a parser that matches exactly one instance of type `T` returning the matched value.
/// This parser binds the source type as ArraySlice<T> which cannot be altered for the lifetime of the parse.
public func accept<T: Equatable>(_ value: T) -> ArrayParser<T, T> {
  return { source in
    let result = acceptIf(source) { $0 == value }
    if case .failure = result {
      return .failure(ParseError(at: source, reason: "expected \(value)"))
    }
    return result
  }
}

/// Generates a parser that matches one of the characters contained within `oneOf`
public func accept(oneOf pattern: String) -> StringParser<String> {
  return { source in
    for ch in pattern {
      if case let .success(result) = acceptIf(source, fn: { $0 == ch }) {
        return .success(result)
      }
    }
    return .failure(ParseError(at: source, reason: "expected one of \(pattern)"))
  }
}

public func accept<T>(_ fn: @escaping (T) -> Bool) -> ArrayParser<T, T> {
  return { source in
    if let first = source.first, fn(first) {
      return .success((first, source.dropFirst()))
    } else {
      return .failure(ParseError(at: source, reason: "acceptIf failed for unknown reasons"))
    }
  }
}

public func acceptIf<T>(_ source: ArraySlice<T>, fn: @escaping (T) -> Bool) -> ParseResult<ArraySlice<T>, T> {
  if let first = source.first, fn(first) {
    return .success((first, source.dropFirst()))
  } else {
    return .failure(ParseError(at: source, reason: "acceptIf failed for unknown reasons"))
  }
}

public func acceptIf(_ source: Substring, fn: @escaping (Substring.Element) -> Bool) -> ParseResult<Substring, String> {
  if let first = source.first, fn(first) {
    return .success((String(first), source.dropFirst()))
  } else {
    return .failure(ParseError(at: source))
  }
}

/// Generates a parser that matches any value not equal to the first element in source ArraySlice.
public func reject<T: Equatable>(value: T) -> ArrayParser<T, T> {
  return { source in
    acceptIf(source) { $0 != value }
  }
}

public func reject(character: Character) -> StringParser<String> {
  return { source in
    acceptIf(source) { $0 != character }
  }
}

/// Generates a `StringParser` that succeeds if the first character in the string
/// being parsed is not any of the characters found in `allOf`.
public func reject(allOf pattern: String) -> StringParser<String> {
  return { source in
    for ch in pattern {
      if case .success = acceptIf(source, fn: { $0 == ch }) {
        return .failure(ParseError(at: source, reason: "did not expect \(ch)"))
      }
    }
    if let first = source.first {
      return .success((String(first), source.dropFirst()))
    } else {
      return .failure(ParseError(at: source, reason: "unexpectedly at end of input"))
    }
  }
}

public func seq<T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
) -> Parser<StreamToken, (T, U)> {
  return { source in
    left(source).flatMap { leftResult in
      right(leftResult.1).map { rightResult in
        ((leftResult.0, rightResult.0), rightResult.1)
      }
    }
  }
}

/// Generators a parser that suceeds if `parser` succeeds zero or more times.
/// This parser never fails.
public func rep<T, StreamToken>(_ parser: @escaping Parser<StreamToken, T>) -> Parser<StreamToken, [T]> {
  return { source in
    // TODO: determine if tail call optimization happens here
    // manually optimize if not.
    func aggregate(source: StreamToken, parsedValues: [T]) -> ([T], StreamToken) {
      if case let .success(result) = parser(source) {
        return aggregate(
          source: result.1,
          parsedValues: parsedValues + [result.0]
        )
      }
      return (parsedValues, source)
    }

    return .success(aggregate(source: source, parsedValues: []))
  }
}

/// Generators a parser that succeeds if `parser` succeeds at least once and fails if `parser` fails.
public func rep1<T, StreamToken>(_ parser: @escaping Parser<StreamToken, T>) -> Parser<StreamToken, [T]> {
  return map(seq(parser, rep(parser))) { (first, rest) in
    [first] + rest
  }
}

/// Generates a heterogeneous parser that succeeds if either `left` or `right` succeeds. `left` is
/// executed first and then right if `left` fails. This parser fails if both `left` and `right` fail.
/// The parsed output of `left` and `right` must be different types.
public func either<T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
) -> Parser<StreamToken, Either<T, U>> {
  return { source in
    if case let .success((value, remainder)) = left(source) {
      return .success((.left(value), remainder))
    } else if case let .success((value, remainder)) = right(source) {
      return .success((.right(value), remainder))
    } else {
      return .failure(ParseError(at: source))
    }
  }
}

/// Generates a heterogeneous parser that succeeds if either `left` or `right` succeeds. `left` is
/// executed first and then right if `left` fails. This parser fails if both `left` and `right` fail.
/// The parsed output of `left` and `right` must be the same  type `T`.
public func or<T, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, T>
) -> Parser<StreamToken, T> {
  return { source in
    var underlyingErrors: [String] = []
    
    let leftResult = left(source)
    switch leftResult {
    case .success: return leftResult
    case let .failure(e):
      if let reason = e.reason {
        underlyingErrors.append(reason)
      }
    }
    
    let rightResult = right(source)
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
public func opt<T, StreamToken>(
  _ parser: @escaping Parser<StreamToken, T>
) -> Parser<StreamToken, T?> {
  return { source in
    // TODO: define primitive on Try to support this case
    switch parser(source) {
    case let .success(s): return .success(s)
    case .failure: return .success((nil, source))
    }
  }
}

/// A stand-in parser that fails for all input. It should be used to construct mutually recursive parser definitions
public func placeholder<T, StreamToken>(_ source: StreamToken) -> ParseResult<StreamToken, T> {
  return .failure(ParseError(at: source, reason: "Not yet implemented"))
}

// TODO: is it possible to implement generic `not` and `until` parsers?
