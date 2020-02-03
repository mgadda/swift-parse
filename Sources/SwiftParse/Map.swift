//
//  Map.swift
//  SwiftParse
//
//  Created by Matt Gadda on 12/1/19.
//


/// Generates a parser that invokes `fn` to convert the result value parsed by `parser` from type `T` to type `U`.
/// This parser fails if `parser` fails.
public func map<T, U, InputStreamToken, OutputStreamToken>(_ parser: @autoclosure @escaping () -> Parser<InputStreamToken, T, OutputStreamToken>, fn: @escaping (T) -> U) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (t, remainder) in
      (fn(t), remainder)
    }
  }
}

public func map<U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element> {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, ((T1, T2), T3), OutputStreamToken>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let ((t1, t2), t3) = value
      return (fn(t1, t2, t3), remainder)
    }
  }
}

public func map<T1, T2, T3, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((T1, T2), T3) {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, T4, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, (((T1, T2), T3), T4), OutputStreamToken>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let (((t1, t2), t3), t4) = value
      return (fn(t1, t2, t3, t4), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((T1, T2), T3), T4) {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, T4, T5, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, ((((T1, T2), T3), T4), T5), OutputStreamToken>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let ((((t1, t2), t3), t4), t5) = value
      return (fn(t1, t2, t3, t4, t5), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((((T1, T2), T3), T4), T5) {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, T4, T5, T6, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, (((((T1, T2), T3), T4), T5), T6), OutputStreamToken>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let (((((t1, t2), t3), t4), t5), t6) = value
      return (fn(t1, t2, t3, t4, t5, t6), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((((T1, T2), T3), T4), T5), T6) {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, T4, T5, T6, T7, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, ((((((T1, T2), T3), T4), T5), T6), T7), OutputStreamToken>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let ((((((t1, t2), t3), t4), t5), t6), t7) = value
      return (fn(t1, t2, t3, t4, t5, t6, t7), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((((((T1, T2), T3), T4), T5), T6), T7) {
  map(parser.mkParser(), fn: fn)
}

public func map<T1, T2, T3, T4, T5, T6, T7, T8, U, InputStreamToken, OutputStreamToken>(
  _ parser: @autoclosure @escaping () -> Parser<InputStreamToken, (((((((T1, T2), T3), T4), T5), T6), T7), T8), OutputStreamToken>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> Parser<InputStreamToken, U, OutputStreamToken> {
  return { source in
    parser()(source).map { (value, remainder) in
      let (((((((t1, t2), t3), t4), t5), t6), t7), t8) = value
      return (fn(t1, t2, t3, t4, t5, t6, t7, t8), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, T8, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {
  map(parser.mkParser(), fn: fn)
}
