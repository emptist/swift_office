#!/usr/bin/env swift

// Demo 2b: 固定名字 + 要求 init
// 运行: swift demo2b_init.swift

import Foundation

// 协议要求 init
protocol Presentation: Initable {
    var title: String { get }
    func generate() async throws
}

protocol Initable {
    init()
}

extension Presentation {
    func generate() async throws {
        print("Generating PPTX: \(title)")
    }
    
    static func run() async throws {
        let instance = Self()
        try await instance.generate()
    }
}

// 固定名字，且必须实现 init
struct 演示: Presentation {
    let title = "医院管理总览"
}

// 还是需要显式调用
try await 演示.run()
print("Done!")
