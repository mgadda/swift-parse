## Overview

SwiftParse is a parser combinator library. This project is in its earliest
iterations and is not stable. Maybe that'll change someday!

[![Build Status](https://travis-ci.org/mgadda/swift-parse.svg?branch=master)](https://travis-ci.org/mgadda/swift-parse)

## Examples

Let's build a parser for the brainfuck language. It's a terrible language, but
trivial to build a parser for.

```swift
enum Brainfuck {
  case incPointer, decPointer, incByte, decByte, writeByte, readByte
  case loop([Brainfuck])
}

typealias OperationParser = ([Character]) -> (Brainfuck, [Character])?
typealias LoopParser = ([Character]) -> (Brainfuck, [Character])?
let incPointer = accept(">") ^^ { _ in Brainfuck.incPointer }
let decPointer = accept("<") ^^ { _ in Brainfuck.decPointer }
let incByte = accept("+") ^^ { _ in Brainfuck.incByte }
let decByte = accept("-") ^^ { _ in Brainfuck.decByte }
let writeByte = accept(".") ^^ { _ in Brainfuck.writeByte }
let readByte = accept(",") ^^ { _ in Brainfuck.readByte }
var loop: LoopParser = placeholder
let operation: OperationParser = incPointer | decPointer | incByte | decByte | writeByte | readByte | loop
loop = accept("[") ~ operation* ~ accept("]") ^^ { Brainfuck.loop($0.0.1) }
let program = operation*
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
