## Overview

SwiftParse is a parser combinator library. This project is still iterating rapidly and is not stable.

[![Build Status](https://travis-ci.org/mgadda/swift-parse.svg?branch=master)](https://travis-ci.org/mgadda/swift-parse)

## Example

Let's build a parser for the brainfuck language. It's a terrible language but
makes for a nice example of how to use SwiftParse.

```swift
import SwiftParse

enum Instruction {
  case incPointer, decPointer, incByte, decByte, writeByte, readByte
  case loop([Instruction])
}

typealias LoopParser = StandardParser<String, Instruction>

struct BrainfuckParser {  
  static let incPointer = match(">") ^^ { _ in Instruction.incPointer }
  static let decPointer = match("<") ^^ { _ in Instruction.decPointer }
  static let incByte = match("+") ^^ { _ in Instruction.incByte }
  static let decByte = match("-") ^^ { _ in Instruction.decByte }
  static let writeByte = match(".") ^^ { _ in Instruction.writeByte }
  static let readByte = match(",") ^^ { _ in Instruction.readByte }

  static let pointerOps = incPointer | decPointer
  static let byteOps = incByte | decByte
  static let ioOps = writeByte | readByte
  static let operation = pointerOps | byteOps | ioOps | loop()
  
  // loop must defined as a static function because it references
  // operation which in turn references loop.
  static let loop: () -> LoopParser = {
    loopStart ~ operation* ~ loopEnd ^^ { Instruction.loop($0.0.1) }
  }
  
  static let loopStart = match("[")
  static let loopEnd = match("]")
  
  static let program = operation+
}
```

Now let's execute it and see what it parsed:
```swift
let result = BrainfuckParser.program(AnyCollection("+[>,]"))
let parseTree = try! result.get().value
```

This generates a parse tree of:

```swift
[
  SwiftParse.Brainfuck.incByte,
  SwiftParse.Brainfuck.loop([
    SwiftParse.Brainfuck.incPointer,
    SwiftParse.Brainfuck.readByte
  ])
]
```

And no unparsed characters left over. Neat!

For more complete examples check out https://github.com/mgadda/swift-parse-examples

