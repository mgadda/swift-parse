//
//  Try.swift
//  SwiftParse
//
//  Created by Matt Gadda on 12/8/19.
//

public enum Try<T, U: Error> {
  case success(T)
  case failure(U)
  public func map<W>(fn: (T) -> W) -> Try<W, U> {
    switch self {
    case let .success(t): return .success(fn(t))
    case let .failure(f): return .failure(f)
    }
  }
  public func flatMap<W>(fn: (T) -> Try<W, U>) -> Try<W, U> {
    switch self {
    case let .success(t): return fn(t)
    case let .failure(f): return .failure(f)
    }
  }
  public func get() throws -> T {
    switch self {
    case let .success(t): return t
    case let .failure(e): throw e
    }
  }
}
