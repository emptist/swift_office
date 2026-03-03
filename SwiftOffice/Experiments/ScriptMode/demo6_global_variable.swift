#!/usr/bin/env swift

// Demo 6: 全局变量 + 延迟执行
// 运行: swift demo6_global_variable.swift

import Foundation

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

// 使用全局变量，在底部执行
let 演示 = 医院管理总览()

// 顶层执行
try await 演示.generate()
print("Done!")
