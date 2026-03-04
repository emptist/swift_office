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
        .executable(
            name: "SwiftSlidesDemo",
            targets: ["SwiftSlidesDemo"]
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
            exclude: ["Cases"]
        ),
        .executableTarget(
            name: "SwiftSlidesDemo",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Demo"
        ),
        .testTarget(
            name: "SwiftSlidesTests",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Tests"
        ),
    ]
)
