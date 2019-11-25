//
//  Map.swift
//
//  Created by Matthew Gadda on 1/13/17.
//
//
import SwiftExt

// Generate parser which converts the parsed result into type U
public func map<T, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  fn: @escaping (T) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, U, StreamToken>(
  t2parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (T1, T2)>,
  fn: @escaping (T1, T2) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    t2parser()(source).map { mapResult(t2result: $0, fn) }
  }
}

public func map<T1, T2, T3, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((T1, T2), T3)>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, T3, T4, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((T1, T2), T3), T4)>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, T3, T4, T5, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((((T1, T2), T3), T4), T5)>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, T3, T4, T5, T6, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((((T1, T2), T3), T4), T5), T6)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((((((T1, T2), T3), T4), T5), T6), T7)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}

public func map<T1, T2, T3, T4, T5, T6, T7, T8, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((((((T1, T2), T3), T4), T5), T6), T7), T8)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).map { mapResult($0, fn) }
  }
}


public func flatMap<T, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  fn: @escaping (T) -> U?
  ) -> HeterogeneousParser<StreamToken, U> {
  return { source in
    parser()(source).flatMap { flatMapResult($0, fn) }
  }
}

precedencegroup MapGroup {
  higherThan: AssignmentPrecedence
  lowerThan: AdditionPrecedence
}
infix operator ^^: MapGroup
public func ^^<T, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  fn: @escaping (T) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (T1, T2)>,
  fn: @escaping (T1, T2) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(t2parser: parser(), fn: fn)
}

public func ^^<T1, T2, T3, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((T1, T2), T3)>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((T1, T2), T3), T4)>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((((T1, T2), T3), T4), T5)>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((((T1, T2), T3), T4), T5), T6)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, ((((((T1, T2), T3), T4), T5), T6), T7)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, T8, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, (((((((T1, T2), T3), T4), T5), T6), T7), T8)>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> HeterogeneousParser<StreamToken, U> {
  return map(parser(), fn: fn)
}

infix operator ^^-: MapGroup
public func ^^-<T, U, StreamToken>(
  _ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  fn: @escaping (T) -> U?
  ) -> HeterogeneousParser<StreamToken, U> {
  return flatMap(parser(), fn: fn)
}

public func mapResult<T, U, StreamToken>(
  _ result: (T, [StreamToken]),
  _ fn: @escaping (T) -> U) -> (U, [StreamToken]
) {
  return (fn(result.0), result.1)
}

public func mapResult<T1, T2, U, StreamToken>(
  t2result: ((T1, T2), [StreamToken]),
  _ fn: @escaping (T1, T2) -> U) -> (U, [StreamToken]
) {
  return (tupled(fn)(t2result.0), t2result.1)
}

public func mapResult<T1, T2, T3, U, StreamToken>(
  _ result: (((T1, T2), T3), [StreamToken]),
  _ fn: @escaping (T1, T2, T3) -> U) -> (U, [StreamToken]
) {
  return (nested(fn)(result.0), result.1)
}

public func mapResult<T1, T2, T3, T4, U, StreamToken>(
  _ result: ((((T1, T2), T3), T4), [StreamToken]),
  _ fn: @escaping (T1, T2, T3, T4) -> U) -> (U, [StreamToken]
) {
  return (nested(fn)(result.0), result.1)
}

public func mapResult<T1, T2, T3, T4, T5, U, StreamToken>(
  _ result: (((((T1, T2), T3), T4), T5), [StreamToken]),
  _ fn: @escaping (T1, T2, T3, T4, T5) -> U) -> (U, [StreamToken]) {
  return (nested(fn)(result.0), result.1)
}

public func mapResult<T1, T2, T3, T4, T5, T6, U, StreamToken>(
  _ result: ((((((T1, T2), T3), T4), T5), T6), [StreamToken]),
  _ fn: @escaping (T1, T2, T3, T4, T5, T6) -> U) -> (U, [StreamToken]) {
  return (nested(fn)(result.0), result.1)
}

public func mapResult<T1, T2, T3, T4, T5, T6, T7, U, StreamToken>(
  _ result: (((((((T1, T2), T3), T4), T5), T6), T7), [StreamToken]),
  _ fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U) -> (U, [StreamToken]) {
  return (nested(fn)(result.0), result.1)
}

public func mapResult<T1, T2, T3, T4, T5, T6, T7, T8, U, StreamToken>(
  _ result: ((((((((T1, T2), T3), T4), T5), T6), T7), T8), [StreamToken]),
  _ fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U) -> (U, [StreamToken]) {
  return (nested(fn)(result.0), result.1)
}

public func flatMapResult<T, U, StreamToken>(_ result: (T, [StreamToken]), _ fn: (T) -> U?) -> (U, [StreamToken])? {
  return fn(result.0).map { ($0, result.1) }
}
