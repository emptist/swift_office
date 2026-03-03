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
| 选择"标题幻灯片"版式 | `封面样式` protocol |
| 章节分隔页 | `章节样式` protocol |
| 内容列表页 | `内容样式` protocol |
| 设置主题颜色 | `主题` 枚举 |

**AI 辅助** - 用户不需要记住所有 protocol，AI 根据内容自动推荐。

### 4. 跨文件组合

```swift
// 文件1：第一部分.swift
struct 第一部分: Section {
    var slides: [any Slide] = [第一章(), 第二章()]
}

// 文件2：新报告.swift
struct 新报告: Presentation {
    var sections: [any Section] = [
        第一部分(),           // 从文件1导入
        其他报告.第二部分(),   // 从其他 Presentation 复用
    ]
}
```

## 技术实现

### 两种执行模式

#### 模式 A：Swift Package（推荐）

**工具与内容分离**，用户只写内容：

```swift
// Sources/UserPresentation/main.swift
import SwiftSlides

// 用户只写这部分 ↓↓↓
struct 医院管理总览: Presentation {
    var title = "医院管理总览"
    var sections: [any Section] = [
        封面章节(),
        历史沿革章节(),
    ]
}

struct 封面章节: Section {
    var title = "封面"
    var slides: [any Slide] = [
        封面页(),
    ]
}

struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
}
// 用户只写这部分 ↑↑↑

// 自动生成，用户不修改 ↓↓↓
@main
struct AutoRunner {
    static func main() async {
        let presentation = 医院管理总览()
        try? await presentation.generatePPTX(outputPath: "outputs/\(presentation.title).pptx")
    }
}
```

运行：
```bash
swift run UserPresentation
```

输出：`outputs/医院管理总览.pptx`

#### 模式 B：Swift 脚本模式

**单文件自包含**，适合快速原型：

```swift
#!/usr/bin/env swift
import Foundation

// 工具代码（可复用）
// ... 协议定义 ...
// ... PPTX 生成器 ...

// 用户内容
struct 医院管理总览: Presentation {
    // ...
}

// 执行
let presentation = 医院管理总览()
try await presentation.generatePPTX(outputPath: "outputs/医院管理总览.pptx")
```

运行：
```bash
swift 医院管理总览.swift
```

### Protocol 组合系统

```swift
// 基础协议
protocol Slide: Identifiable, Sendable {
    var title: String { get set }
}

// 样式协议（能力）
protocol 封面样式: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

protocol 章节样式: Slide {
    var chapterNumber: Int? { get }
}

protocol 内容样式: Slide {
    var items: [String] { get }
}

// 组合使用
struct 封面页: Slide, 封面样式 {
    var title = "标题"
    var subtitle: String? = "副标题"
    var author: String? = "作者"
}

struct 内容页: Slide, 内容样式 {
    var title = "标题"
    var items = ["第一点", "第二点"]
}
```

### 默认实现减少样板代码

```swift
public extension Slide {
    var id: UUID { UUID() }        // 自动生成
    var notes: String? { nil }      // 默认为空
    var hidden: Bool { false }      // 默认显示
}

public extension Presentation {
    var id: UUID { UUID() }
    var author: String? { nil }
    var theme: 主题? { nil }
}

public extension Section {
    var id: UUID { UUID() }
}
```

## 核心洞察

1. **数据与呈现分离** - 用户定义数据，Protocol 定义呈现方式
2. **Protocol 组合** - 像搭积木一样组合幻灯片能力
3. **工具与内容分离** - Swift Package 模式让用户只关心内容
4. **渐进式复杂度** - 简单场景简单用，复杂场景有扩展点
5. **AI 友好** - 结构清晰，AI 容易理解和生成

## 与现有代码的关系

| 组件 | 用途 | 状态 |
|------|------|------|
| `Presentation` protocol | 顶层容器 | ✅ 使用并扩展 |
| `Section` protocol | 章节组织 | ✅ 添加默认实现 |
| `Slide` protocol | 单页定义 | ✅ 简化并扩展 |
| `SlideStyleProtocols` | 样式协议 | ✅ 新增 |
| `NodeJSBridge` | PPTX 生成 | ✅ 复用 |
| Result Builders | DSL 语法 | ✅ 保留备用 |
| 预定义 Slide 类型 | 快速使用 | ✅ 保留备用 |

## 项目结构

```
SwiftOffice/
├── Package.swift
├── README.md
├── USER_GUIDE.md              # 用户指南
├── Sources/
│   ├── SwiftSlides/           # 工具库
│   │   ├── Protocols/
│   │   │   ├── Slide.swift
│   │   │   ├── Section.swift
│   │   │   ├── Presentation.swift
│   │   │   └── SlideStyleProtocols.swift  # 新增
│   │   └── ...
│   └── UserPresentation/      # 用户内容
│       └── main.swift         # 示例 + 执行入口
├── Demo/
│   └── 医院管理总览.swift     # 脚本模式示例
└── outputs/                   # 生成的 PPTX
```

## 未来扩展

1. **更多样式协议** - 图表样式、图片样式、表格样式
2. **主题系统** - 通过 Protocol 扩展支持自定义主题
3. **动画支持** - `动画样式` protocol
4. **多输出格式** - 同样的内容生成 PDF、Keynote
5. **实时预览** - 开发时自动刷新预览
