# SwiftOffice 项目架构理解

## 核心目标

让用户用 Swift 代码替代 PowerPoint 图形界面，以编程方式创建 PPTX 演示文稿。

## 关键设计哲学

### 1. 用户创作流程

```
打开编辑器写 Swift 代码 → 运行命令 → 生成 PPTX
```

**不是编程，是创作** - 就像作家用 Markdown 而不是 Word。

### 2. 三层结构

```
Presentation (起点，一个 .pptx 对应一个 Presentation struct)
└── sections: [Section] 或直接 slides: [Slide]
    └── Slide
        └── fellowSlides: [Slide] (嵌套层级)
```

### 3. Protocol = PowerPoint 功能

| PowerPoint GUI | Swift Protocol |
|----------------|----------------|
| 选择"标题幻灯片"版式 | `TitleSlide` protocol |
| 设置主题颜色 | `蓝色主题` / `绿色主题` protocol |
| 插入图表 | `ChartSlide` protocol |
| 设置动画 | `淡入动画` protocol |

**AI 辅助** - 用户不需要记住所有 protocol，AI 根据内容自动推荐。

### 4. 跨文件组合

```swift
// 文件1：第一部分.swift
struct 第一部分: Section {
    let slides: [Slide] = [第一章(), 第二章()]
}

// 文件2：新报告.swift
struct 新报告: Presentation {
    let sections: [Section] = [
        第一部分(),           // 从文件1导入
        其他报告.第二部分(),   // 从其他 Presentation 复用
    ]
}
```

## 技术实现关键

### 执行模式

**Swift 脚本模式** - 不需要 @main，不需要注册表：

```swift
// 医院管理总览.swift
import SwiftSlides

struct 医院管理总览: Presentation {
    let title = "医院管理总览"
    let sections: [Section] = [...]
}

// 顶层执行
let presentation = 医院管理总览()
try await presentation.generatePPTX()
```

运行：
```bash
swift 医院管理总览.swift
```

### 两种 Presentation 结构

```swift
// 方式1：按 Section 组织
struct 医院管理总览: PresentationWithSections {
    let sections: [Section] = [第一部分(), 第二部分()]
}

// 方式2：直接放 Slides
struct 快速演示: PresentationWithSlides {
    let slides: [Slide] = [封面页(), 内容页(), 结束页()]
}
```

需要不同的 Protocol 约束。

### 批量生成

```bash
swift 报告1.swift 报告2.swift 报告3.swift
# 或
swift *.swift
```

## 核心洞察

1. **极简命令行** - 所有复杂性在 Swift 结构定义中
2. **不需要注册** - 利用 Swift 脚本模式的顶层代码执行
3. **Protocol-Oriented** - 用协议替代 PowerPoint 的菜单按钮
4. **可复用可组合** - 像程序代码一样 import 和调用

## 待解决问题

1. 固定顶层 struct 名字（如都叫"演示"）能否省去最后执行代码？
2. 多文件时如何自动发现所有 Presentation？
3. 如何集成 NodeJSBridge 生成实际 PPTX？

## 与现有代码的关系

- 复用现有的 `Presentation`, `Section`, `Slide` 协议
- 复用 `NodeJSBridge` 生成 PPTX
- 复用 Result Builders 提供 DSL
- 简化用户接口，隐藏复杂性
