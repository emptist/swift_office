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
        .executable(
            name: "C01医管教程",
            targets: ["C01医管教程"]
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
            path: "B_SwiftSlides/Sources"
        ),
        .executableTarget(
            name: "SwiftSlidesDemo",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Demo"
        ),
        .executableTarget(
            name: "C01医管教程",
            dependencies: ["SwiftSlides"],
            path: "Cases/医管教程",
            exclude: ["C01_医疗质量与安全管理字典化.swift"]
        ),
        .testTarget(
            name: "SwiftSlidesTests",
            dependencies: ["SwiftSlides"],
            path: "B_SwiftSlides/Tests"
        ),
    ]
)
