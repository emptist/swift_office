#!/usr/bin/env swift

// Demo 5: Swift Package 模式
// 用户创建 Package，依赖 SwiftSlides
// 运行: swift run

import Foundation

// 在 Package 中，使用 @main
// 但每个 Presentation 文件不需要 @main

protocol Presentation {
    var title: String { get }
    func generate() async throws
}

extension Presentation {
    func generate() async throws {
        print("Generating PPTX: \(title)")
    }
}

// 用户定义
struct 医院管理总览: Presentation {
    let title = "医院管理总览"
}

// 单独的 main.swift 或在同一个文件底部
@main
struct App {
    static func main() async throws {
        try await 医院管理总览().generate()
    }
}
