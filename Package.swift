// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SwiftParse",
  products: [
    .library(name: "SwiftParse", targets: ["SwiftParse"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftParse",
      dependencies: []
    ),
    .testTarget(
      name: "SwiftParseTests",
      dependencies: ["SwiftParse"]
    ),
  ]
)
