#!/usr/bin/env swift

// Demo 2: 固定名字 + 协议扩展自动执行
// 运行: swift demo2_generic_name.swift

import Foundation

// 定义协议，包含默认执行
protocol Presentation {
    var title: String { get }
    func generate() async throws
}

extension Presentation {
    func generate() async throws {
        print("Generating PPTX: \(title)")
    }
    
    // 提供静态方法，但还是需要调用
    static func run() async throws {
        let instance = Self()
        try await instance.generate()
    }
}

// 固定名字
struct 演示: Presentation {
    let title = "医院管理总览"
}

// 还是需要显式调用
try await 演示.run()
print("Done!")
