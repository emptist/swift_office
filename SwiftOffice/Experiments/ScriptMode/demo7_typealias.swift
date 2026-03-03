#!/usr/bin/env swift

// Demo 7: 使用 typealias 固定名字
// 运行: swift demo7_typealias.swift

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

// 用户定义自己的 struct
struct MyPresentation: Presentation {
    let title = "医院管理总览"
}

// 固定名字为 typealias
typealias 演示 = MyPresentation

// 使用固定名字
let presentation = 演示()
try await presentation.generate()
print("Done!")
