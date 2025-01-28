// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "FlowID",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [.library(name: "FlowID", targets: ["FlowID"])],
    targets: [
        .target(name: "FlowID"),
        .testTarget(name: "FlowTests", dependencies: ["FlowID"]),
    ]
)
