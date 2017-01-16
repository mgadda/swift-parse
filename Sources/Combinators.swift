import SwiftExt

public typealias HomogeneousParser<T> = ([T]) -> (T, [T])?
public typealias HeterogeneousParser<StreamToken, ParsedOutput> =
  ([StreamToken]) -> (ParsedOutput, [StreamToken])?

public func head<Element>(_ source: [Element]) -> Element? {
  if source.count > 0 {
    return .some(source[0])
  } else {
    return .none
  }
}

public func tail<Element>(_ source: [Element]) -> [Element] {
  return Array(source[1..<source.count])
}

public func acceptIf<T>(_ source: [T], fn: @escaping (T) -> Bool) -> (T, [T])? {
  return head(source).flatMap {
    if fn($0) {
      return .some($0, tail(source))
    } else {
      return .none
    }
  }
}

public func accept<T: Equatable>(_ value: T) -> HomogeneousParser<T> {
  return { source in acceptIf(source) { $0 == value } }
}

// Generate parser which attempts to match first `left`
// and then `right`. Return .none if both do not parse.
public func seq<T, U, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, U>
) -> ([StreamToken]) -> ((T, U), [StreamToken])? {
  return { source in
    return left()(source).flatMap { leftResult in
      return right()(leftResult.1).map { rightResult in
        ((leftResult.0, rightResult.0), rightResult.1)
      }
    }
  }
}

infix operator ~: MultiplicationPrecedence
public func ~<T, U, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, U>
  ) -> ([StreamToken]) -> ((T, U), [StreamToken])? {
  return seq(left, right)
}

infix operator ~>: MultiplicationPrecedence
public func ~><T, U, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, U>
  ) -> HeterogeneousParser<StreamToken, T> {

  return map(seq(left, right)) { $0.0 }
}

infix operator <~: MultiplicationPrecedence
public func <~<T, U, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, U>
  ) -> HeterogeneousParser<StreamToken, U> {

  return map(seq(left, right)) { $0.1 }
}

// TODO: uncomment and devise mechanism to differentiate between single- and
// multi-type or operations.

// public func or<T, U>(
//   _ left: @escaping ([Character]) -> (T, [Character])?,
//   _ right: @escaping ([Character]) -> (U, [Character])?
//   ) -> ([Character]) -> (Either<T, U>, [Character])? {
//   return { source in
//     if let result = left(source) {
//       return (.left(result.0), result.1)
//     } else if let result = right(source) {
//       return (.right(result.0), result.1)
//     } else {
//       return .none
//     }
//   }
// }

// infix operator |: AdditionPrecedence
// public func |<T, U>(
//   _ left: @escaping ([Character]) -> (T, [Character])?,
//   _ right: @escaping ([Character]) -> (U, [Character])?
//   ) -> ([Character]) -> (Either<T, U>, [Character])? {
//   return or(left, right)
// }

public func or<T, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>
  ) -> HeterogeneousParser<StreamToken, T> {
  return { source in
    if let result = left()(source) {
      return result
    } else if let result = right()(source) {
      return result
    } else {
      return .none
    }
  }
}


public func |<T, StreamToken>(
  _ left: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>,
  _ right: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>
  ) -> HeterogeneousParser<StreamToken, T> {
  return or(left, right)
}


// Generate parser which matches 0 or more of `parser` argument
// Always succeeds.
public func rep<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> ([T], [StreamToken]) {
  let ret = { (source: [StreamToken]) -> ([T], [StreamToken]) in
    let p = parser()
    func aggregate(source: [StreamToken], parsedValues: [T]) -> ([T], [StreamToken]) {
      if let parseResult = p(source) {
        return aggregate(
          source: parseResult.1,
          parsedValues: parsedValues + [parseResult.0]
        )
      }
      return (parsedValues, source)
    }

    return aggregate(source: source, parsedValues: [])
  }
  return ret
}

postfix operator *
public postfix func *<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> ([T], [StreamToken]) {
  return rep(parser)
}

// Generate parser which matches 1 or more of `parser` arugment.
public func rep1<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> ([T], [StreamToken])? {
  return { source in
    return seq(parser, rep(parser))(source).map { result in
      return ([result.0.0] + result.0.1, result.1)
    }
  }
}

postfix operator +
public postfix func +<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> ([T], [StreamToken])? {
  return rep1(parser)
}

public func opt<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> (T?, [StreamToken]) {
  return { source in
    parser()(source).map { (Optional.some($0.0), $0.1) } ?? (.none, source)
  }
}

postfix operator *? // because '?' is forbidden
public postfix func *?<T, StreamToken>(_ parser: @autoclosure @escaping () -> HeterogeneousParser<StreamToken, T>) -> ([StreamToken]) -> (T?, [StreamToken]) {
  return opt(parser)
}


public func placeholder<T, StreamToken>(_ source: [StreamToken]) -> (T, [StreamToken])? { return .none }
