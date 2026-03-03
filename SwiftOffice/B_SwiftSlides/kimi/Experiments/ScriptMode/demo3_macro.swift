#!/usr/bin/env swift

// Demo 3: 使用宏（伪代码，Swift 6.2 支持宏）
// 运行: swift demo3_macro.swift

import Foundation

// 假设有一个 @AutoRun 宏
// 宏会在 struct 定义后自动插入执行代码

protocol Presentation {
    var title: String { get }
    func generate() async throws
}

extension Presentation {
    func generate() async throws {
        print("Generating PPTX: \(title)")
    }
}

// @AutoRun  // 宏会自动展开为：let _ = try await 演示().generate()
struct 演示: Presentation {
    let title = "医院管理总览"
}

// 不需要任何执行代码！
print("Done!")
