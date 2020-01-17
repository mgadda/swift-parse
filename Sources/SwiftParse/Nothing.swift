//
//  Unit.swift
//  SwiftParse
//
//  Created by Matt Gadda on 1/17/20.
//

public struct _Void<T> {}
extension _Void : Equatable where T == Void {}

extension _Void : ExpressibleByNilLiteral where T == Void {
  public init(nilLiteral: ()) {
    self = _Void<Void>()
  }
}
/// A replacement for Void that conforms to Equatable
public typealias Nothing = _Void<Void>
