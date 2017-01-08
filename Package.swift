import PackageDescription

let package = Package(
  name: "SwiftParse",
  dependencies: [
    .Package(url: "https://github.com/mgadda/swift-ext", majorVersion: 0)
  ]
)
