/// SwiftParse specific implementation of the algebraic Sum type representing
/// values that are _either_ one type or another.
public enum Either<T: Equatable, U: Equatable> : Equatable {
  case left(T)
  case right(U)
}
