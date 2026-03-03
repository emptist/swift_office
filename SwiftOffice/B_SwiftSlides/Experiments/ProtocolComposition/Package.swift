// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ProtocolComposition",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SwiftSlidesCore", targets: ["SwiftSlidesCore"]),
        .executable(name: "医院管理总览", targets: ["医院管理总览"]),
        .executable(name: "销售报告", targets: ["销售报告"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftSlidesCore",
            path: "Core"
        ),
        .executableTarget(
            name: "医院管理总览",
            dependencies: ["SwiftSlidesCore"],
            path: "Presentations",
            sources: ["医院管理总览.swift"]
        ),
        .executableTarget(
            name: "销售报告",
            dependencies: ["SwiftSlidesCore"],
            path: "Presentations",
            sources: ["销售报告.swift"]
        ),
    ]
)
