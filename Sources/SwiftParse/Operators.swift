//
//  Operators.swift
//  SwiftParse
//
//  Created by Matt Gadda on 11/30/19.
//

infix operator ~: MultiplicationPrecedence
public func ~<T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
  ) -> Parser<StreamToken, (T, U)> {
  return seq(left, right)
}

infix operator ~>: MultiplicationPrecedence
public func ~><T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
  ) -> Parser<StreamToken, T> {

  return map(seq(left, right)) { (left, _) in left }
}

infix operator <~: MultiplicationPrecedence
public func <~<T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
  ) -> Parser<StreamToken, U> {

  return map(seq(left, right)) { (_, right) in right }
}

public func |<T, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, T>
  ) -> Parser<StreamToken, T> {
  return or(left, right)
}

public func |<T, U, StreamToken>(
  _ left: @escaping Parser<StreamToken, T>,
  _ right: @escaping Parser<StreamToken, U>
  ) -> Parser<StreamToken, Either<T, U>> {
  return or(left, right)
}

precedencegroup MapGroup {
  higherThan: AssignmentPrecedence
  lowerThan: AdditionPrecedence
}

infix operator ^^: MapGroup
public func ^^<T, U, StreamToken>(
  _ parser: @escaping Parser<StreamToken, T>,
  fn: @escaping (T) -> U
  ) -> Parser<StreamToken, U> {
  return map(parser, fn: fn)
}

postfix operator *
public postfix func *<T, StreamToken>(_ parser: @escaping Parser<StreamToken, T>) -> Parser<StreamToken, [T]> {
  return rep(parser)
}

postfix operator +
public postfix func +<T, StreamToken>(_ parser: @escaping Parser<StreamToken, T>) -> Parser<StreamToken, [T]> {
  return rep1(parser)
}

postfix operator *?
public postfix func *?<T, StreamToken>(_ parser: @escaping Parser<StreamToken, T>) -> Parser<StreamToken, T?> {
  return opt(parser)
}

