# SwiftOffice 设计规格说明书

## 1. 项目愿景

### 1.1 核心目标
让用户用 Swift 代码替代 Microsoft PowerPoint 的图形界面，以声明式、可编程的方式创建 Office 文档（从 PPTX 开始，扩展到 DOCX、XLSX）。

### 1.2 用户价值主张
- **创作自由**：不受 PowerPoint 界面限制，用代码精确控制每个元素
- **可复用性**：定义好的幻灯片结构可以在多个文档间复用
- **版本控制**：用 Git 管理文档变更，而非二进制文件
- **AI 友好**：结构化代码比 GUI 操作更容易被 AI 理解和生成

---

## 2. 核心设计概念

### 2.1 文档结构映射

一个 Office 文档（如 PPTX）对应一个 Swift 结构体：

```
文件系统                    Swift 代码
─────────                   ─────────
医院管理总览.pptx     ←→    struct 医院管理总览: Presentation { ... }
```

### 2.2 三层嵌套结构

```
Presentation（演示文稿）- 对应一个 .pptx 文件
├── Section（章节）- 可选，用于组织幻灯片
│   └── Slide（幻灯片）- 单页内容
│       └── fellowSlides（子幻灯片）- 层级嵌套
└── 或直接放 Slide
```

**关键洞察**：PPTX 本身不支持 subsection，但可以通过连续 Section 或 fellowSlides 实现类似层级效果。

### 2.3 Protocol = PowerPoint 功能菜单

PowerPoint 的图形界面功能被映射为 Swift Protocol：

| PowerPoint 操作 | Swift Protocol | 用途 |
|-----------------|----------------|------|
| 选择"标题幻灯片"版式 | `TitleSlide` | 封面页布局 |
| 选择"标题和内容"版式 | `ContentSlide` | 正文页布局 |
| 设置蓝色主题 | `蓝色主题` | 配色方案 |
| 插入柱状图 | `柱状图页面` | 数据可视化 |
| 设置淡入动画 | `淡入动画` | 动画效果 |
| 标记为章节首页 | `ChapterFirstPage` | 特殊布局 |

**设计原则**：
- Protocol 提供默认实现，用户只需声明即可
- 可以组合多个 Protocol（如 `struct 封面: Slide, 封面样式, 蓝色主题`）
- AI 可以根据内容自动推荐合适的 Protocol

---

## 3. 用户工作流程

### 3.1 创建单个演示文稿

**步骤 1：创建 Swift 文件**

```swift
// 医院管理总览.swift
import SwiftSlides

struct 医院管理总览: Presentation {
    let title = "医院管理总览"
    let author = "张三"
    
    let sections: [Section] = [
        历史沿革章节(),
        现状分析章节(),
    ]
}

struct 历史沿革章节: Section {
    let title = "历史沿革"
    let slides: [Slide] = [
        古代医院(),
        现代医院(),
    ]
}

struct 古代医院: Slide, 内容页 {
    let title = "古代医院"
    let bulletPoints = ["公元前400年：希波克拉底", "公元100年：罗马医院"]
}
```

**步骤 2：运行生成**

```bash
swift 医院管理总览.swift
```

**输出**：`医院管理总览.pptx`

### 3.2 批量生成多个演示文稿

```bash
# 生成多个
swift 报告1.swift 报告2.swift 报告3.swift

# 或生成全部
swift *.swift
```

### 3.3 跨文件复用

**文件 1：通用章节.swift**
```swift
struct 标准封面: Section {
    let title = "封面"
    let slides: [Slide] = [
        封面页(title: "医院管理", subtitle: "年度报告")
    ]
}
```

**文件 2：医院管理总览.swift**
```swift
struct 医院管理总览: Presentation {
    let sections: [Section] = [
        标准封面(),        // 从其他文件导入
        历史沿革章节(),
    ]
}
```

---

## 4. 两种 Presentation 结构

### 4.1 按 Section 组织（适合复杂文档）

```swift
struct 医院管理总览: PresentationWithSections {
    let title = "医院管理总览"
    let sections: [Section] = [
        第一部分(),
        第二部分(),
    ]
}
```

**适用场景**：
- 大型报告，需要清晰的章节划分
- 需要章节导航
- 不同章节需要不同的页眉页脚

### 4.2 直接放 Slides（适合简单文档）

```swift
struct 快速演示: PresentationWithSlides {
    let title = "快速演示"
    let slides: [Slide] = [
        封面页(),
        内容页(),
        结束页(),
    ]
}
```

**适用场景**：
- 简单汇报
- 不需要章节划分
- 快速原型

**协议设计**：
```swift
protocol PresentationWithSections: Presentation {
    var sections: [Section] { get }
}

protocol PresentationWithSlides: Presentation {
    var slides: [Slide] { get }
}
```

---

## 5. 技术实现要点

### 5.1 执行模式：Swift 脚本

**关键决策**：使用 Swift 脚本模式，而非 Swift Package 或 @main。

**原因**：
- 不需要 `@main` 标记
- 不需要 `static func main()`
- 顶层代码直接执行
- 用户体验最简洁

**用户代码结构**：
```swift
#!/usr/bin/env swift
import SwiftSlides

// 1. 定义结构
struct 演示: Presentation { ... }

// 2. 顶层执行（用户需要写这两行）
let presentation = 演示()
try await presentation.generatePPTX()
```

### 5.2 不需要注册表

**常见误区**：需要运行时根据字符串找到对应的 struct 类型。

**正确方案**：
- Swift 脚本模式下，代码直接执行
- 不需要 `["医院管理总览": 医院管理总览.self]` 这样的注册表
- 不需要反射或动态查找

### 5.3 命令行极简设计

**原则**：所有复杂性在 Swift 代码中，命令行只负责触发。

```bash
# 最简形式
swift 文件名.swift

# 批量形式
swift 文件1.swift 文件2.swift

# 不需要
swift run --target xxx
swift run --all
newSlide xxx
```

---

## 6. 扩展性设计

### 6.1 从 PPTX 扩展到其他格式

```swift
// 当前：PPTX
struct 报告: Presentation { ... }

// 未来：DOCX
struct 报告: Document { ... }

// 未来：XLSX
struct 报表: Spreadsheet { ... }
```

**统一接口**：
```swift
protocol OfficeDocument {
    func generate() async throws
}

extension OfficeDocument {
    func generate() async throws {
        // 根据具体类型路由到不同生成器
    }
}
```

### 6.2 主题和样式系统

```swift
// 定义主题
protocol 蓝色主题 {
    var primaryColor: String { "#0066CC" }
    var fontFamily: String { "微软雅黑" }
}

// 应用主题
struct 封面: Slide, 蓝色主题 {
    // 自动获得蓝色主题的默认实现
}
```

---

## 7. 与现有代码的关系

### 7.1 复用组件

| 现有代码 | 复用方式 |
|---------|---------|
| `Presentation`, `Section`, `Slide` 协议 | 直接复用或扩展 |
| `NodeJSBridge` | 复用，用于生成实际 PPTX 文件 |
| `SlideBuilder`, `SectionBuilder` | 复用，提供 DSL |
| `封面页`, `章节页` 等具体类型 | 复用，作为默认实现 |

### 7.2 简化方向

**当前问题**：
- 协议层级较多（Element 协议族）
- Demo 代码较复杂
- 需要理解 Result Builder

**简化目标**：
- 用户只需理解 `Presentation`, `Section`, `Slide` 三个核心协议
- 提供大量预设的 Protocol 组合（如 `内容页`, `图表页`）
- 降低学习成本

---

## 8. 待决策问题

### 8.1 是否固定顶层 struct 名字？

**选项 A**：每个文件用不同名字（如 `医院管理总览`）
- 优点：语义清晰
- 缺点：需要写执行代码 `let p = 医院管理总览()`

**选项 B**：固定名字（如都叫 `演示`）
- 优点：可能简化执行代码
- 缺点：失去语义，多文件冲突

**待验证**：能否完全省去最后执行代码？

### 8.2 多文件时如何组织？

**选项 A**：松散文件，靠 import/Swift 模块系统
**选项 B**：约定目录结构（如 `Sources/Slides/*.swift`）

### 8.3 错误处理和日志

- 生成失败时如何反馈？
- 是否需要进度显示？
- 调试信息如何输出？

---

## 9. 成功标准

1. **用户可以在 5 分钟内创建第一个 PPTX**
2. **不需要理解 Swift 高级特性**（泛型、关联类型等）
3. **代码比 PowerPoint 操作更快**（对于复杂文档）
4. **AI 可以根据自然语言描述生成合理的 Swift 代码**

---

## 10. 图表渲染技术

### 10.1 Mermaid 图表

SwiftSlides 使用 **BeautifulMermaid** 包进行图表渲染，这是纯 Swift 原生实现，不依赖 JavaScript 运行时。

**支持的图表类型**：
- 流程图 (Flowchart)
- 时序图 (Sequence Diagram)
- 甘特图 (Gantt Chart)

**两种使用方式**：

```swift
// 方式1：直接写 Mermaid 代码
struct 业务流程: Slide, Mermaid流程图样式 {
    let title = "业务流程"
    let mermaidCode = """
    flowchart TB
        A[开始] --> B[处理]
        B --> C[结束]
    """
}

// 方式2：使用高级 API（推荐）
struct 业务流程: Slide, Mermaid流程图高级样式 {
    let title = "业务流程"
    let flowchartDirection: Mermaid方向 = .从上到下
    let flowchartNodes: [Mermaid节点] = [
        Mermaid节点(id: "A", 标签: "开始", 形状: .圆形),
        Mermaid节点(id: "B", 标签: "处理", 形状: .矩形),
        Mermaid节点(id: "C", 标签: "结束", 形状: .圆形),
    ]
    let flowchartConnections: [Mermaid连线] = [
        Mermaid连线(从: "A", 到: "B"),
        Mermaid连线(从: "B", 到: "C"),
    ]
}
```

### 10.2 甘特图

甘特图有两种渲染方式：

**方式1：SwiftUI 原生渲染（推荐）**

```swift
// 使用 SwiftUI 渲染，效果更好
let ganttChart = Gantt图表(
    标题: "项目进度",
    任务列表: [
        Gantt任务(名称: "需求分析", 开始日期: ..., 结束日期: ..., 进度: 1.0),
        Gantt任务(名称: "开发阶段", 开始日期: ..., 结束日期: ..., 进度: 0.6),
    ]
)
let imageData = try Gantt渲染器.渲染图片(ganttChart, 宽度: 900, 高度: 500)
```

**方式2：协议定义**

```swift
struct 项目进度: Slide, 甘特图样式 {
    let title = "项目进度"
    let ganttTitle = "医院信息化建设进度"
    let ganttTasks: [SlideGanttTask] = [
        SlideGanttTask(name: "需求分析", status: .done, start: "2024-01-01", end: "2024-01-15"),
        SlideGanttTask(name: "开发阶段", status: .active, start: "2024-02-16", end: "2024-04-30"),
    ]
}
```

> **注意**：我们已弃用 JavaScript mermaid.js，所有图表渲染均使用 Swift 原生实现。

---

## 11. 参考示例

### 11.1 最小可行示例

```swift
import SwiftSlides

struct 演示: Presentation {
    let title = "Hello World"
    let slides: [Slide] = [
        封面页(title: "Hello", subtitle: "World")
    ]
}

let p = 演示()
try await p.generatePPTX()
```

### 11.2 复杂示例

```swift
import SwiftSlides

struct 医院管理总览: PresentationWithSections, 蓝色主题 {
    let title = "医院管理总览"
    let author = "张三"
    
    let sections: [Section] = [
        封面章节(),
        历史沿革章节(),
        数据分析章节(),
        结束章节(),
    ]
}

struct 封面章节: Section {
    let title = "封面"
    let slides: [Slide] = [
        封面页(title: "医院管理总览", subtitle: "2024年度报告")
    ]
}

struct 历史沿革章节: Section {
    let title = "历史沿革"
    let slides: [Slide] = [
        章节首页(title: "历史沿革", number: 1),
        古代医院(),
        现代医院(),
    ]
}

struct 古代医院: Slide, 内容页, 淡入动画 {
    let title = "古代医院"
    let bulletPoints = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

struct 现代医院: Slide, 内容页 {
    let title = "现代医院"
    let bulletPoints = [
        "19世纪：无菌手术技术",
        "20世纪：抗生素广泛应用",
        "21世纪：数字化医疗",
    ]
}

// 执行
let p = 医院管理总览()
try await p.generatePPTX()
```

---

*文档版本：1.0*
*最后更新：2026-03-03*
