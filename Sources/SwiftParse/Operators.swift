//
//  Operators.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

// MARK: ~ (compose)

infix operator ~: MultiplicationPrecedence
public func ~<T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<T, (LeftParsedValue, RightParsedValue), V> {
  return compose(left(), right())
}

public func ~<ParserTU: ParserConvertible, ParserUV: ParserConvertible>(
  _ left: ParserTU,
  _ right: ParserUV
) -> Parser<
  ParserTU.InputType.Element,
  (ParserTU.ParsedValueType, ParserUV.ParsedValueType),
  ParserUV.OutputType.Element> where
  ParserTU.OutputType == ParserUV.InputType
{
  return compose(left, right)
}

func ~<T, U, LeftParsedValue, ParserUV: ParserConvertible>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: ParserUV
) -> Parser<T, (LeftParsedValue, ParserUV.ParsedValueType), ParserUV.OutputType.Element> where
  U == ParserUV.InputType.Element
{
  return compose(left(), right)
}

func ~<ParserTU: ParserConvertible, U, V, RightParsedValue>(
  _ left: ParserTU,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<ParserTU.InputType.Element, (ParserTU.ParsedValueType, RightParsedValue), V> where
  ParserTU.OutputType.Element == U
{
  return compose(left, right())
}

// MARK: ~> (compose, ignore right)

infix operator ~>: MultiplicationPrecedence
public func ~><T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
) -> Parser<T, LeftParsedValue, V> {
  return map(compose(left(), right())) { (left, _) in left }  
}

public func ~><ParserTU: ParserConvertible, ParserUV: ParserConvertible>(
  _ left: ParserTU,
  _ right: ParserUV
) -> Parser<ParserTU.InputType.Element, ParserTU.ParsedValueType, ParserUV.OutputType.Element>
  where ParserTU.OutputType == ParserUV.InputType {
    left.mkParser() ~> right.mkParser()
}

public func ~><ParserLike: ParserConvertible, V, RightParsedValue>(
  _ left: ParserLike,
  _ right: @autoclosure @escaping () -> Parser<ParserLike.OutputType.Element, RightParsedValue, V>
) -> Parser<ParserLike.InputType.Element, ParserLike.ParsedValueType, V> {
    left.mkParser() ~> right()
}

public func ~><T, LeftParsedValue, ParserLike: ParserConvertible>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, ParserLike.InputType.Element>,
  _ right: ParserLike
) -> Parser<T, LeftParsedValue, ParserLike.OutputType.Element> {
  left() ~> right.mkParser()
}

// MARK: <~ (compose, ignore left)

infix operator <~: MultiplicationPrecedence
public func <~ <T, U, V, LeftParsedValue, RightParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<U, RightParsedValue, V>
  ) -> Parser<T, RightParsedValue, V> {

  return map(compose(left(), right())) { (_, right) in right }
}

public func <~<ParserTU: ParserConvertible, ParserUV: ParserConvertible>(
  _ left: ParserTU,
  _ right: ParserUV
) -> Parser<ParserTU.InputType.Element, ParserUV.ParsedValueType, ParserUV.OutputType.Element>
  where ParserTU.OutputType == ParserUV.InputType {
    left.mkParser() <~ right.mkParser()
}

public func <~<ParserLike: ParserConvertible, V, RightParsedValue>(
  _ left: ParserLike,
  _ right: @autoclosure @escaping () -> Parser<ParserLike.OutputType.Element, RightParsedValue, V>
) -> Parser<ParserLike.InputType.Element, RightParsedValue, V> {
    left.mkParser() <~ right()
}

public func <~<T, LeftParsedValue, ParserLike: ParserConvertible>(
  _ left: @autoclosure @escaping () -> Parser<T, LeftParsedValue, ParserLike.InputType.Element>,
  _ right: ParserLike
) -> Parser<T, ParserLike.ParsedValueType, ParserLike.OutputType.Element> {
  left() <~ right.mkParser()
}


// MARK: | (or)

public func |<T, U, ParsedValue>(
  _ left: @autoclosure @escaping () -> Parser<T, ParsedValue, U>,
  _ right: @autoclosure @escaping () -> Parser<T, ParsedValue, U>
) -> Parser<T, ParsedValue, U> {
  return or(left(), right())
}

public func |<ParserLike: ParserConvertible>(
  _ left: ParserLike,
  _ right: ParserLike
) -> ParserFrom<ParserLike> {
  or(left, right)
}

public func |<ParserLike: ParserConvertible>(
  _ left: @autoclosure @escaping () -> ParserFrom<ParserLike>,
  _ right: ParserLike
) -> ParserFrom<ParserLike> {
  or(left(), right)
}

public func |<ParserLike: ParserConvertible>(
  _ left: ParserLike,
  _ right: @autoclosure @escaping () -> ParserFrom<ParserLike>
) -> ParserFrom<ParserLike> {
  or(left, right())
}

// MARK: ^^ (map)

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

public func ^^<U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element> {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((T1, T2), T3), OutputElement>,
  fn: @escaping (T1, T2, T3) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((T1, T2), T3) {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, T4, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((T1, T2), T3), T4), OutputElement>,
  fn: @escaping (T1, T2, T3, T4) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((T1, T2), T3), T4) {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((((T1, T2), T3), T4), T5), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((((T1, T2), T3), T4), T5) {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((((T1, T2), T3), T4), T5), T6), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((((T1, T2), T3), T4), T5), T6) {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, ((((((T1, T2), T3), T4), T5), T6), T7), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == ((((((T1, T2), T3), T4), T5), T6), T7) {
  map(parser, fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, T8, U, InputElement, OutputElement>(
  _ parser: @autoclosure @escaping () -> Parser<InputElement, (((((((T1, T2), T3), T4), T5), T6), T7), T8), OutputElement>,
  fn: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) -> U
  ) -> Parser<InputElement, U, OutputElement> {
  return map(parser(), fn: fn)
}

public func ^^<T1, T2, T3, T4, T5, T6, T7, T8, U, ParserLike: ParserConvertible>(
  _ parser: ParserLike,
  fn: @escaping (ParserLike.ParsedValueType) -> U
) -> Parser<ParserLike.InputType.Element, U, ParserLike.OutputType.Element>
  where ParserLike.ParsedValueType == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {
  map(parser, fn: fn)
}

// MARK: * (rep)

postfix operator *
public postfix func *<T, InputElement>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, [T], InputElement> {
  rep(parser())
}

public postfix func *<ParserLike: ParserConvertible>(
  _ parser: ParserLike
) -> StandardParser<ParserLike.InputType, [ParserLike.ParsedValueType]>
  where ParserLike.InputType == ParserLike.OutputType
{
  rep(parser.mkParser())
}

// MARK: + (rep1)

postfix operator +
public postfix func +<T, InputElement>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, [T], InputElement> {
  return rep1(parser())
}

public postfix func +<ParserLike: ParserConvertible>(
  _ parser: ParserLike
) -> StandardParser<ParserLike.InputType, [ParserLike.ParsedValueType]>
  where ParserLike.InputType == ParserLike.OutputType {
    rep1(parser)
}

// MARK: *? (opt)

postfix operator *?
public postfix func *?<InputElement, T>(_ parser: @autoclosure @escaping () -> Parser<InputElement, T, InputElement>) -> Parser<InputElement, T?, InputElement> {
  return opt(parser())
}

public postfix func *?<ParserLike: ParserConvertible>(
  _ parser: ParserLike
) -> StandardParser<ParserLike.InputType, ParserLike.ParsedValueType?>
  where ParserLike.InputType == ParserLike.OutputType {
  return opt(parser)
}

// MARK: & (and)

infix operator &: MultiplicationPrecedence
public func &<T, U, V, LeftValue, RightValue>(
_ left: @autoclosure @escaping () -> Parser<T, LeftValue, U>,
_ right: @autoclosure @escaping () -> Parser<T, RightValue, V>) -> Parser<T, LeftValue, U> {
  and(left(), right())
}

public func &<V, RightValue, ParserTU: ParserConvertible>(
  _ left: ParserTU,
  _ right: @autoclosure @escaping () -> Parser<ParserTU.InputType.Element, RightValue, V>
  ) -> ParserFrom<ParserTU> {
  and(left, right())
}

public func &<U, LeftValue, ParserTV: ParserConvertible>(
  _ left: @autoclosure @escaping () -> Parser<ParserTV.InputType.Element, LeftValue, U>,
  _ right: ParserTV
) -> Parser<ParserTV.InputType.Element, LeftValue, U> {
  and(left(), right)
}

public func &<ParserTU: ParserConvertible, ParserTV: ParserConvertible>(
  _ left: ParserTU,
  _ right: ParserTV) -> ParserFrom<ParserTU>
  where ParserTU.InputType == ParserTV.InputType
{
  and(left, right)
}
