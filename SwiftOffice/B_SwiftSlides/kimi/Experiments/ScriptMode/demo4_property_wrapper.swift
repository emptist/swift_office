#!/usr/bin/env swift

// Demo 4: 使用属性包装器
// 运行: swift demo4_property_wrapper.swift

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

// 属性包装器在初始化时执行
@propertyWrapper
struct AutoGenerate<T: Presentation> {
    let wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        // 同步执行，但 generate 是 async...
        print("AutoGenerate initialized for: \(wrappedValue.title)")
    }
}

// 使用属性包装器
@AutoGenerate
var 演示 = 医院管理总览()

struct 医院管理总览: Presentation {
    let title = "医院管理总览"
}

// 还是需要调用
try await 演示.generate()
print("Done!")
