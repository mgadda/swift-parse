enum Either<T, U> {
  case left(T)
  case right(U)

  static func ==<A: Equatable, B: Equatable>(lhs: Either<A, B>, rhs: Either<A, B>) -> Bool {
    switch (lhs, rhs) {
    case let (.left(leftVal), .left(rightVal)):
      return leftVal == rightVal
    case let (.right(leftVal), .right(rightVal)):
      return leftVal == rightVal
    default:
      return false
    }
  }
}
