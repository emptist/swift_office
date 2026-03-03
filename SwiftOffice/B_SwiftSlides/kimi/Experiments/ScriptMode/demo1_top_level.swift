#!/usr/bin/env swift

// Demo 1: 纯脚本模式 - 顶层代码直接执行
// 运行: swift demo1_top_level.swift

import Foundation

// 定义协议
protocol Presentation {
    var title: String { get }
    func generate() async throws
}

extension Presentation {
    func generate() async throws {
        print("Generating PPTX: \(title)")
        // 实际生成逻辑
    }
}

// 用户定义的结构
struct 医院管理总览: Presentation {
    let title = "医院管理总览"
}

// 顶层执行代码
let presentation = 医院管理总览()
try await presentation.generate()
print("Done!")
