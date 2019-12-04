//
//  Parsers.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

/// A generic parser (a function) from `SourceType` to `OutputType`
/// The remaining unparsed values are returned as the second element of the tuple.
public typealias Parser<T, U> = (T) -> (U, T)?

/// A parser from String to instance of type `U`
public typealias StringParser<U> = Parser<Substring, U>

/// A parser from `Array<T>` to instances of type `U`
public typealias ArrayParser<T, U> = Parser<ArraySlice<T>, U>

/// Generates a parser that matches a String `pattern` of arbitrary length.
/// This parser binds the source type as Substring which cannot be altered for the lifetime of the parse.
public func accept(_ pattern: String) -> StringParser<String> {
  return { source in
    if source.starts(with: pattern) {
      return (pattern, source.dropFirst(pattern.count))
    } else {
      return nil
    }
  }
}

/// Generates a parser that matches exactly one instance of type `T` returning the matched value.
/// This parser binds the source type as ArraySlice<T> which cannot be altered for the lifetime of the parse.
public func accept<T: Equatable>(_ value: T) -> ArrayParser<T, T> {
  return { source in
    acceptIf(source) { $0 == value }
  }
}

public func acceptIf<T>(_ source: ArraySlice<T>, fn: @escaping (T) -> Bool) -> (T, ArraySlice<T>)? {
  if let first = source.first, fn(first) {
    return (first, source.dropFirst())
  } else {
    return nil
  }
}

public func acceptIf(_ source: Substring, fn: @escaping (Substring.Element) -> Bool) -> (String, Substring)? {
  if let first = source.first, fn(first) {
    return (String(first), source.dropFirst())
  } else {
    return nil
  }
}

/// Generates a parser that matches any value not equal to the first element in source ArraySlice.
public func reject<T: Equatable>(_ value: T) -> ArrayParser<T, T> {
  return { source in
    acceptIf(source) { $0 != value }
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
    // TODO: determine if recursive implementation is inefficient
    func aggregate(source: StreamToken, parsedValues: [T]) -> ([T], StreamToken) {
      if let result = parser(source) {        
        return aggregate(
          source: result.1,
          parsedValues: parsedValues + [result.0]
        )
      }
      return (parsedValues, source)
    }

    return aggregate(source: source, parsedValues: [])
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
    if let (value, remainder) = left(source) {
      return (.left(value), remainder)
    } else if let (value, remainder) = right(source) {
      return (.right(value), remainder)
    } else {
      return nil
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
    if let (value, remainder) = left(source) {
      return (value, remainder)
    } else if let (value, remainder) = right(source) {
      return (value, remainder)
    } else {
      return nil
    }
  }
}

/// Generates a parser that always succeeds regardless of whether the underlying parser succeeds.
/// If `parser` succeeds, its value is returned as the parsed result. If `parser` fails, None is returned
/// as the parsed result.
public func opt<T, StreamToken>(
  _ parser: @escaping Parser<StreamToken, T>
) -> Parser<StreamToken, T?> {
  return { parser($0) ?? (nil, $0) }
}

/// A stand-in parser that fails for all input. It should be used to construct mutually recursive parser definitions
public func placeholder<T, StreamToken>(_ source: StreamToken) -> (T, StreamToken)? {
  return nil
}

// TODO: is it possible to implement generic `not` and `until` parsers?
