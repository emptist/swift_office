// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftOffice",
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
    ],
    targets: [
        .target(
            name: "SwiftSlides",
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
