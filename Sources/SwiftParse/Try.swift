//
//  Try.swift
//  SwiftParse
//
//  Created by Matt Gadda on 12/8/19.
//

public enum Try<T, E: Error> {
  case success(T)
  case failure(E)
}

public extension Try {
   func map<W>(fn: (T) -> W) -> Try<W, E> {
    switch self {
    case let .success(t): return .success(fn(t))
    case let .failure(f): return .failure(f)
    }
  }
   func flatMap<W>(fn: (T) -> Try<W, E>) -> Try<W, E> {
    switch self {
    case let .success(t): return fn(t)
    case let .failure(f): return .failure(f)
    }
  }
   func recover(fn: (E) -> T) -> T {
    switch self {
    case let .success(t): return t
    case let .failure(f): return fn(f)
    }
  }
   func recoverWith(fn: (E) -> Try<T, E>) -> Try<T, E> {
    switch self {
    case let .success(s): return .success(s)
    case let .failure(f): return fn(f)
    }
  }
   func handle<E2>(fn: (E) -> E2) -> Try<T, E2> {
    switch self {
    case let .success(s): return .success(s)
    case let .failure(f): return .failure(fn(f))
    }
  }
   func get() throws -> T {
    switch self {
    case let .success(t): return t
    case let .failure(f): throw f
    }
  }
}

public extension Optional {
  func liftToTry<E: Error>(orFailWith error: E) -> Try<Wrapped, E> {
    return self.map { .success($0) } ?? .failure(error)
  }
}

