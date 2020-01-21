//
//  Operators.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

infix operator ~: MultiplicationPrecedence
func ~<T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<T, (LeftParsedValue, RightParsedValue), V> {
  return compose(left(), right())
}

infix operator ~>: MultiplicationPrecedence
func ~><T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<T, LeftParsedValue, V> {
  let c = compose(left(), right())
  return map(c) { (left, _) in left }
}

infix operator <~: MultiplicationPrecedence
public func <~ <T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
  ) -> Parser<T, RightParsedValue, V> {

  return map(compose(left(), right())) { (_, right) in right }
}

public func |<T, U, ParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, ParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<T, ParsedValue, U>
) -> Parser<T, ParsedValue, U> {
  return or(left(), right())
}

precedencegroup MapGroup {
  higherThan: AssignmentPrecedence
  lowerThan: AdditionPrecedence
}

infix operator ^^: MapGroup
public func ^^<T, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, T, OutputElement>,
  fn: @escaping (T) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((T1, T2), T3), OutputElement>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((T1, T2), T3), T4), OutputElement>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((((T1, T2), T3), T4), T5), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((((T1, T2), T3), T4), T5), T6), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((((((T1, T2), T3), T4), T5), T6), T7), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, T8, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((((((T1, T2), T3), T4), T5), T6), T7), T8), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

postfix operator *
public postfix func *<T, InputElement>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, [T], InputElement> {
  let p = parser()
  return rep(p)
}

postfix operator +
public postfix func +<T, InputElement>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, [T], InputElement> {
  return rep1(parser())
}

postfix operator *?
public postfix func *?<InputElement, T>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, T?, InputElement> {
  return opt(parser())
}

