// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftOffice",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "SwiftSlides",
            targets: ["SwiftSlides"]
        ),
        .library(
            name: "Runner",
            targets: ["Runner"]
        ),
        .executable(
            name: "SwiftSlidesDemo",
            targets: ["SwiftSlidesDemo"]
        ),
        .executable(
            name: "FlatAPIDemo",
            targets: ["FlatAPIDemo"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:lukilabs/beautiful-mermaid-swift.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "SwiftSlides",
            dependencies: [
                .product(name: "BeautifulMermaid", package: "beautiful-mermaid-swift"),
            ],
            path: "B_SwiftSlides/Sources",
            exclude: ["Cases", "Runner"]
        ),
        .target(
            name: "Runner",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Sources/Runner"
        ),
        .executableTarget(
            name: "SwiftSlidesDemo",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Demo",
            exclude: ["FlatAPIDemo.swift"]
        ),
        .executableTarget(
            name: "FlatAPIDemo",
            dependencies: ["SwiftSlides", "Runner"],
            path: "B_SwiftSlides/Demo",
            sources: ["FlatAPIDemo.swift"]
        ),
        .testTarget(
            name: "SwiftSlidesTests",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Tests"
        ),
    ]
)
