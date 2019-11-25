// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SwiftParse",
  products: [
    .library(name: "SwiftParse", targets: ["SwiftParse"])
  ],
  dependencies: [
    .package(url: "../swift-ext", .branch("0.4.0"))
  ],
  targets: [
    .target(
      name: "SwiftParse",
      dependencies: ["SwiftExt"]
    ),
    .testTarget(
      name: "SwiftParseTests",
      dependencies: ["SwiftParse"]),
  ]
)
