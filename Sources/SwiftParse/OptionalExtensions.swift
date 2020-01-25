//
//  OptionalExtensions.swift
//  SwiftParse
//
//  Created by Matt Gadda on 1/25/20.
//

public extension Optional {
  func liftToResult<E: Error>(orFailWith error: E) -> Result<Wrapped, E> {
    return self.map { .success($0) } ?? .failure(error)
  }
}

