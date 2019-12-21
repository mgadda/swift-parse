## Overview

SwiftParse is a parser combinator library. This project is still iterating rapidly and is not stable. 

[![Build Status](https://travis-ci.org/mgadda/swift-parse.svg?branch=master)](https://travis-ci.org/mgadda/swift-parse)

## Examples

Let's build a parser for the brainfuck language. It's a terrible language, but
makes for a nice example of how to use SwiftParse.

```swift
import SwiftParser

enum Instruction {
  case incPointer, decPointer, incByte, decByte, writeByte, readByte
  case loop([Instruction])
}

typealias OperationParser = HeterogeneousParser<Character, Instruction>
typealias LoopParser = HeterogeneousParser<Character, Instruction>

let incPointer = char(">") ^^ { _ in Instruction.incPointer }
let decPointer = char("<") ^^ { _ in Instruction.decPointer }
let incByte = char("+") ^^ { _ in Instruction.incByte }
let decByte = char("-") ^^ { _ in Instruction.decByte }
let writeByte = char(".") ^^ { _ in Instruction.writeByte }
let readByte = char(",") ^^ { _ in Instruction.readByte }

var loop: LoopParser = placeholder
let operation: OperationParser = incPointer | decPointer | incByte | decByte | writeByte | readByte | loop

loop = accept("[") ~ operation* ~ accept("]") ^^ { (_, operations, _) in Instruction.loop(operations) }

let program = operation+
```

Now let's execute it and see what it parsed:
```swift
let (parseTree, unparsed) = program(stringToArray("+[>,]"))
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
