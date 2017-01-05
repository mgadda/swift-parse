extension Optional {
  func filter(pred: (Wrapped) -> Bool) -> Optional<Wrapped> {
    return self.flatMap { wrapped in
      if pred(wrapped) {
        return .some(wrapped)
      } else {
        return .none
      }
    }
  }
}
