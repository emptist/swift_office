# Protocol Composition 模式实验

## 概述

本目录包含 Protocol Composition 模式的实验性实现，探索如何使用 Swift 的协议组合功能创建 PowerPoint 演示文稿。

## 实验目标

探索一种**数据与呈现完全分离**的演示文稿创建方式：
- 用户只定义内容结构（数据）
- 样式和能力通过 Protocol Composition 添加
- 无需关心底层 PPTX 生成细节

## 项目结构

```
ProtocolComposition/
├── Core/
│   └── SwiftSlidesCore.swift    # 工具代码：协议定义 + PPTX 生成器
├── Presentations/
│   ├── 医院管理总览.swift       # 用户内容示例 1
│   └── 销售报告.swift           # 用户内容示例 2
└── Package.swift                # Swift Package 配置
```

## 核心概念

### Protocol Composition

不同于传统的继承或模板，Protocol Composition 让你通过组合多个协议来定义幻灯片的能力：

```swift
// 基础 Slide 协议
title: String

// 封面样式协议
subtitle: String?
author: String?

// 组合后获得封面页能力
struct 封面页: Slide, 封面样式 {
    var title = "主标题"
    var subtitle: String? = "副标题"
    var author: String? = "作者名"
}
```

### 三层结构

```
Presentation (演示文稿)
    └── Section (章节)
            └── Slide (幻灯片)
                    └── Style Protocols (样式能力)
```

## 使用方式

### 1. 运行现有演示文稿

```bash
swift run 医院管理总览   # 生成 医院管理总览.pptx
swift run 销售报告       # 生成 销售报告.pptx
```

输出位置：`B_SwiftSlides/Outputs/`

### 2. 创建新的演示文稿

在 `Presentations/` 目录下创建新的 `.swift` 文件：

```swift
import SwiftSlidesCore
import Foundation

// 定义演示文稿（统一使用 SwiftSlidePresentation 作为 struct 名）
struct SwiftSlidePresentation: Presentation {
    var title = "我的演示"      // 这将决定输出文件名
    var author: String? = "作者"

    var sections: [Section] = [
        第一章(),
        第二章(),
    ]
}

// 定义章节
struct 第一章: Section {
    var title = "引言"
    var slides: [Slide] = [
        封面页(),
        介绍页(),
    ]
}

// 定义幻灯片
struct 封面页: Slide, 封面样式 {
    var title = "我的演示"
    var subtitle: String? = "副标题"
    var author: String? = "作者"
}

struct 介绍页: Slide, 内容样式 {
    var title = "介绍"
    var items = [
        "第一点内容",
        "第二点内容",
    ]
}

// 生成入口（复制即可，无需修改）
@main
struct Runner {
    static func main() async {
        let presentation = SwiftSlidePresentation()
        let outputPath = "../../Outputs/\(presentation.title).pptx"
        try? await presentation.generatePPTX(outputPath: outputPath)
    }
}
```

### 3. 在 Package.swift 中注册

```swift
.executableTarget(
    name: "我的演示",
    dependencies: ["SwiftSlidesCore"],
    path: "Presentations",
    sources: ["我的演示.swift"]
),
```

## 样式协议

| 协议 | 属性 | 用途 |
|------|------|------|
| `封面样式` | `subtitle`, `author` | 封面页 |
| `章节样式` | `chapterNumber` | 章节分隔页 |
| `内容样式` | `items: [String]` | 列表内容页 |

## 设计原则

### 1. 数据与呈现分离

```swift
// 好的做法：只定义数据
struct 销售数据: Slide, 内容样式 {
    var title = "Q4 销售数据"
    var items = [
        "产品A: 100万",
        "产品B: 150万",
    ]
}

// 样式由协议决定，不在这里指定颜色、字体等
```

### 2. 组合优于继承

```swift
// 使用 Protocol Composition
struct 封面页: Slide, 封面样式 { }

// 而不是继承
// struct 封面页: CoverSlide { }  // 避免这种方式
```

### 3. 工具与内容分离

- **Core/SwiftSlidesCore.swift**: 包含所有工具代码（协议、生成器）
- **Presentations/*.swift**: 只包含用户定义的内容
- 每个演示文稿文件独立，使用统一的 `SwiftSlidePresentation` struct 名

## 实验状态

- **状态**: 实验性
- **稳定性**: API 可能会变化
- **目标**: 探索 Protocol Composition 在文档生成中的应用

## 与主框架的关系

本实验探索的模式可能会整合到 B_SwiftSlides 主框架中：
- 核心协议 (`Slide`, `Section`, `Presentation`) 需要与主框架统一
- 样式协议 (`封面样式`, `章节样式`, `内容样式`) 作为扩展
- PPTX 生成逻辑使用主框架的 `NodeJSBridge`
