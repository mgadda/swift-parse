import PackageDescription

let package = Package(
  name: "SwiftParse",
  dependencies: [
    .Package(url: "https://github.com/mgadda/swift-ext.git", majorVersion: 0)
  ]
)
