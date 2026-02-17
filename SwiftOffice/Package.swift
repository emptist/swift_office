// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOffice",
    products: [
        .library(
            name: "SwiftOffice",
            targets: ["SwiftOffice"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftOffice"
        ),
        .testTarget(
            name: "SwiftOfficeTests",
            dependencies: ["SwiftOffice"]
        ),
    ]
)
