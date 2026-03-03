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
            name: "PreviousDesign",
            targets: ["PreviousDesign"]
        ),
        .executable(
            name: "SwiftSlidesDemo",
            targets: ["SwiftSlidesDemo"]
        ),
        .executable(
            name: "swiftoffice",
            targets: ["SwiftOfficeCLI"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:lukilabs/beautiful-mermaid-swift.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftSlides",
            dependencies: [
                .product(name: "BeautifulMermaid", package: "beautiful-mermaid-swift"),
            ],
            path: "Sources/SwiftSlides"
        ),
        .target(
            name: "PreviousDesign",
            path: "Sources/PreviousDesign"
        ),
        .executableTarget(
            name: "SwiftSlidesDemo",
            dependencies: ["SwiftSlides"],
            path: "Sources/SwiftSlidesDemo"
        ),
        .executableTarget(
            name: "SwiftOfficeCLI",
            dependencies: [
                "SwiftSlides",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/SwiftOfficeCLI"
        ),
        .testTarget(
            name: "SwiftSlidesTests",
            dependencies: ["SwiftSlides"],
            path: "Tests/SwiftSlidesTests"
        ),
        .testTarget(
            name: "PreviousDesignTests",
            dependencies: ["PreviousDesign"],
            path: "Tests/SwiftOfficeTests"
        ),
    ]
)
