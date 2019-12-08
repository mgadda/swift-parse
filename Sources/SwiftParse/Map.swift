//
//  Map.swift
//  SwiftParse
//
//  Created by Matt Gadda on 12/1/19.
//


/// Generates a parser that invokes `fn` to convert the result value parsed by `parser` from type `T` to type `U`.
/// This parser fails if `parser` fails.
public func map<T, U, StreamToken>(_ parser: @escaping Parser<StreamToken, T>, fn: @escaping (T) -> U) -> Parser<StreamToken, U> {
  return { source in
    switch parser(source) {
    case let .success((t, remainder)):
      return .success((fn(t), remainder))
    default:
      return .failure(ParseError(at: source))
    }
  }
}

public func map<T1, T2, T3, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, ((T1, T2), T3)>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let ((t1, t2), t3) = value
      return (fn(t1, t2, t3), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, (((T1, T2), T3), T4)>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let (((t1, t2), t3), t4) = value
      return (fn(t1, t2, t3, t4), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, ((((T1, T2), T3), T4), T5)>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let ((((t1, t2), t3), t4), t5) = value
      return (fn(t1, t2, t3, t4, t5), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, (((((T1, T2), T3), T4), T5), T6)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let (((((t1, t2), t3), t4), t5), t6) = value
      return (fn(t1, t2, t3, t4, t5, t6), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, ((((((T1, T2), T3), T4), T5), T6), T7)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let ((((((t1, t2), t3), t4), t5), t6), t7) = value
      return (fn(t1, t2, t3, t4, t5, t6, t7), remainder)
    }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, T8, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, (((((((T1, T2), T3), T4), T5), T6), T7), T8)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> Parser<StreamToken, U> {
  return { source in
    parser(source).map { (value, remainder) in
      let (((((((t1, t2), t3), t4), t5), t6), t7), t8) = value
      return (fn(t1, t2, t3, t4, t5, t6, t7, t8), remainder)
    }
  }
}
