# SwiftSlides

A Swift library for Office document generation using Protocol-Oriented Programming (POP) with Swift 6.2.

SwiftSlides is a powerful, natural language-like Swift framework for generating PowerPoint presentations. It uses Protocol-Oriented Programming (POP) principles and supports Chinese identifiers for intuitive content creation.

## Features

- **Flat Properties API** - Write slides with simple `let` properties, no dictionary wrapping
- **Mirror Discovery** - System auto-discovers all properties via reflection
- **Protocol Composition** - Mix and match slide styles using protocols
- **Data/Presentation Separation** - Clean separation between content and styling
- **23 Slide Types** - Cover, section, list, table, chart, timeline, flowchart, etc.
- **Data-Driven API** - Create slides from arrays, CSV, TSV, or JSON data
- **8 Predefined Themes** - Professional blue, business green, tech purple, etc.
- **4 Presentation Templates** - Project report, training course, annual summary, data analysis
- **Mermaid Diagrams** - Flowcharts, sequence diagrams, Gantt charts
- **Chinese Identifiers** - Natural language-like API in Chinese

## Project Structure

```
B_SwiftSlides/
├── Sources/                    # Framework source code
│   ├── Protocols/              # Core protocols
│   │   ├── Elements/           # Element protocols (Chart, Image, Table, etc.)
│   │   ├── Supporting/         # Supporting types (Enums, Theme, SlideMaster)
│   │   ├── Builders.swift      # Builder DSL
│   │   ├── Presentation.swift  # Presentation protocol
│   │   ├── Section.swift       # Section protocol
│   │   ├── Slide.swift         # Slide protocol
│   │   ├── SlideFactory.swift  # Slide factory
│   │   ├── SlideStyleProtocols.swift  # Style protocols (封面样式, 章节样式, 内容样式)
│   │   └── SlideTypes.swift    # Slide type definitions
│   ├── DataImport/             # CSV/TSV/JSON import
│   │   ├── CSVParser.swift
│   │   └── DataImporter.swift
│   ├── Gantt/                  # Gantt chart generation
│   │   ├── GanttModel.swift
│   │   ├── GanttRenderer.swift
│   │   └── GanttView.swift
│   ├── Mermaid/                # Mermaid diagram generation
│   │   └── MermaidGenerator.swift
│   ├── Supporting/             # Supporting utilities
│   │   ├── NodeJSBridge.swift
│   │   ├── SwiftSlidesError.swift
│   │   └── fakecode.swift
│   └── Templates/              # Presentation templates
│       ├── BuiltInTemplates.swift
│       └── PresentationTemplate.swift
├── Demo/                       # Usage examples
│   ├── main.swift              # Builder mode demo
│   └── ProtocolCompositionDemo.swift  # Protocol composition demo
├── Tests/                      # Test suite
│   └── SwiftSlidesSerializationTests.swift
├── Docs/                       # Documentation
│   ├── ARCHITECTURE_UNDERSTANDING.md
│   ├── DESIGN_PHILOSOPHY.md
│   └── DESIGN_SPECIFICATION.md
├── Scripts/                    # Node.js scripts
│   └── swiftslides-pptx.js     # JSON to PPTX converter
├── Outputs/                    # Generated output examples
├── kimi/                       # AI-assisted exploration
│   ├── Demo/                   # Additional demos
│   ├── Experiments/            # Experimental implementations
│   └── USER_GUIDE.md           # User guide
└── README.md                   # This file
```

## Quick Start (Protocol Composition Mode)

The recommended way to use SwiftSlides with clean separation between content and tools:

### Flat Properties API (Recommended)

Write slides with simple `let` properties - no dictionary wrapping needed:

```swift
import SwiftSlides

// Define your presentation
struct MyPresentation: Presentation {
    let title = "我的演示文稿"
    let author: String? = "作者姓名"
    let sections: [any Section] = [MySection()]
}

struct MySection: Section {
    let title = "我的章节"
    let slides: [any Slide] = [MySlide()]
}

struct MySlide: Slide, ContentStyle {
    let title = "我的幻灯片"
    let items = ["第一项", "第二项", "第三项"]  // Flat property!
    let author = "JK"                          // Flat property!
}

// Generate PPTX
@main
struct MyPresentationApp {
    static func main() async {
        let presentation = MyPresentation()
        try? await PresentationRunner.generate(presentation)
    }
}
```

**Key Points:**
- `contents` is auto-generated internally via Mirror - users never write it
- Property names can be anything (Chinese, English, any language)
- Protocols find data by type matching, not hardcoded key names
- System handles layout, styling, and rendering

### How It Works

```
User writes:     let items = ["A", "B", "C"]
                 let author = "JK"
                 
System does:     1. Mirror discovers all properties
                 2. Auto-generates contents dictionary
                 3. Protocol finds data by type
                 4. Renders beautifully
```

### Using PresentationRunner

Use the universal `PresentationRunner` library to generate any presentation:

```swift
import SwiftSlides
import Runner

@main
struct MyPresentationApp {
    static func main() async {
        let presentation = MyPresentation()
        try? await PresentationRunner.generate(presentation, saveJSON: false)
    }
}
```

See [RUNNER_USAGE.md](Docs/RUNNER_USAGE.md) for detailed documentation.

## Alternative: Builder Mode

For more complex presentations with built-in slide types:

```swift
import SwiftSlides

let presentation = 演示文稿(标题: "项目报告", 作者: "张三", 主题: .专业蓝) {
    章节(标题: "概述") {
        封面页(标题: "项目进展报告", 副标题: "2024年度", 渐变: .蓝色)
        
        幻灯片.概览(项目: [
            ("项目周期", "6个月"),
            ("团队成员", "12人"),
            ("完成进度", "85%"),
        ])
    }
    
    章节(标题: "数据分析") {
        幻灯片.表格(标题: "数据汇总", 数据: [
            ["类别", "数量", "占比"],
            ["A类", "150", "30%"],
            ["B类", "250", "50%"],
        ])
        
        幻灯片.柱状图(标题: "月度趋势", 数据: [
            ("一月", 85), ("二月", 92), ("三月", 88)
        ], Y轴: "评分")
    }
}

let json = try presentation.toJSON()
```

### Data Import

```swift
// From CSV
let data = try 表格数据.从CSV内容("""
月份,销售额,利润
一月,125000,40000
二月,138000,46000
""")

// Auto-generate slides
幻灯片.表格(标题: "销售数据", 数据: data)
幻灯片.柱状图(标题: "销售趋势", 数据: data, 标签列: "月份", 数值列: "销售额")
```

### Mermaid Diagrams

SwiftSlides uses **BeautifulMermaid** - a native Swift package for rendering Mermaid diagrams. No JavaScript runtime required!

> **Note**: We no longer use the JavaScript mermaid.js library. All diagram rendering is done natively in Swift using the BeautifulMermaid package.

```swift
// Flowchart with high-level API
let flowchart = Mermaid流程图(
    方向: .从上到下,
    节点: [
        Mermaid节点(id: "A", 标签: "开始", 形状: .圆形),
        Mermaid节点(id: "B", 标签: "处理", 形状: .矩形),
    ],
    连线: [Mermaid连线(从: "A", 到: "B")],
    配置: .大字体
)

Mermaid流程图页(标题: "业务流程", 流程图: flowchart)

// Gantt Chart - Native SwiftUI rendering
struct 项目进度: Slide, 甘特图样式 {
    let title = "项目进度"
    let ganttTitle = "医院信息化建设进度"
    let ganttTasks: [SlideGanttTask] = [
        SlideGanttTask(name: "需求分析", status: .done, start: "2024-01-01", end: "2024-01-15"),
        SlideGanttTask(name: "系统设计", status: .done, start: "2024-01-16", end: "2024-02-15"),
        SlideGanttTask(name: "开发阶段", status: .active, start: "2024-02-16", end: "2024-04-30"),
    ]
}

// Or use SwiftUI Gantt chart directly (for better rendering)
let ganttChart = Gantt图表(标题: "项目进度", 任务列表: [...])
let imageData = try Gantt渲染器.渲染图片(ganttChart)
```

### Templates

```swift
let config = 模板配置(
    标题: "年度报告",
    副标题: "2024年度总结",
    作者: "财务部",
    主题: .金融金,
    数据: try 表格数据.从CSV内容(csvData)
)

let report = 模板库.年度总结.生成(配置: config)
```

### Generate PPTX

```bash
# Swift generates JSON
swift run SwiftSlidesDemo

# Node.js converts to PPTX
node Scripts/swiftslides-pptx.js output/demo.pptx < output/demo.json
```

## Slide Types

| Type | Chinese Name | Description |
|------|--------------|-------------|
| Cover | 封面页 | Title slide with gradient background |
| Section | 章节页 | Section divider |
| List | 列表页 | Bullet points |
| Cards | 卡片页 | Grid of info cards |
| Table | 表格页 | Data table |
| Chart | 图表页 | Bar, line, pie, radar charts |
| Definition | 定义页 | Term definition |
| Architecture | 架构图页 | Layered architecture |
| Flowchart | 流程图页 | Process steps |
| Timeline | 时间线页 | Event timeline |
| Quote | 引用页 | Quotation |
| Comparison | 对比页 | Side-by-side comparison |
| Pyramid | 金字塔页 | Pyramid structure |
| Matrix | 矩阵页 | 2D matrix |
| Pareto | 柏拉图页 | Pareto analysis |
| TwoColumn | 双栏页 | Two-column layout |
| Image | 图片页 | Image with caption |
| Mermaid Flowchart | Mermaid流程图页 | Mermaid flowchart |
| Mermaid Sequence | Mermaid时序图页 | Mermaid sequence diagram |
| Mermaid Gantt | Mermaid甘特图页 | Mermaid Gantt chart |
| End | 结束页 | Thank you slide |

## Themes

| Theme | Chinese Name | Primary Color |
|-------|--------------|---------------|
| Professional Blue | 专业蓝 | #1F4E79 |
| Business Green | 商务绿 | #2E7D32 |
| Tech Purple | 科技紫 | #6A1B9A |
| Active Orange | 活力橙 | #E65100 |
| Classic Red | 经典红 | #C62828 |
| Medical Blue | 医疗蓝 | #0D47A1 |
| Education Teal | 教育青 | #00695C |
| Financial Gold | 金融金 | #F9A825 |

## Architecture

SwiftSlides uses Protocol-Oriented Programming (POP) with following core protocols:

- `Slide` - Base protocol for all slide types (uses Mirror for property discovery)
- `Node` - Container for slides (节 - logical grouping)
- `Chapter` - Container for nodes or slides (章 - logical grouping)
- `Section` - Container for chapters or slides (册 - physical grouping)
- `Presentation` - Top-level container (演示文稿/古书)

### Five-Level Hierarchy

```
Presentation (演示文稿/古书) ─ 物理整体
  │
  └── Section (册) ─ 物理分组（如上册、下册）
        │
        └── Chapter (章) ─ 逻辑分组（如第一章）
              │
              └── Node (节) ─ 逻辑分组（如1.1节）
                    │
                    └── Slide (幻灯片) ─ 内容单元
```

**Hierarchy Rules:**

1. **Order is Fixed**: The hierarchy order is always Presentation → Section → Chapter → Node → Slide
2. **No Reverse Order**: Cannot skip upward (e.g., Slide cannot contain Node)
3. **Flexible Combination**: Users can skip any intermediate levels as needed
4. **Automatic Numbering**: All level numbers are automatically generated based on array index

### Automatic Numbering System

**Important**: Section, Chapter, and Node numbers are automatically generated based on their position in the parent's array. Users should NOT manually set any numbers to avoid hardcoding.

**How It Works:**

```swift
// User writes:
struct MyPresentation: ChapterBasedPresentation {
    let title = "My Course"
    let chapters: [any Chapter] = [
        Chapter1(),  // Position 0
        Chapter2(),  // Position 1
        Chapter3(),  // Position 2
    ]
}

// System automatically generates:
// Chapter 1 → "第1章"
// Chapter 2 → "第2章"
// Chapter 3 → "第3章"
```

**Numbering Format:**

| Level | Array Index | Auto-Generated Display |
|-------|-------------|---------------------|
| Section 1 | 0 | "第1册" |
| Section 2 | 1 | "第2册" |
| Chapter 1 | 0 | "第1章" |
| Chapter 2 | 1 | "第2章" |
| Node 1 | 0 | "1.1节" |
| Node 2 | 1 | "1.2节" |

**Benefits:**

- ✅ **No Hardcoding**: Numbers are generated dynamically from array structure
- ✅ **Extreme Flexibility**: Add/remove items anywhere without manual renumbering
- ✅ **Automatic Updates**: Numbers update automatically when array changes
- ✅ **Style-Based Display**: PPTX generation can choose to show/hide numbers based on theme

**Implementation Details:**

The numbering is generated during JSON serialization (`toDict()` method):

```swift
// In Presentation.swift
dict["chapters"] = chapters.enumerated().map { index, chapter in
    chapter.toDict(chapterIndex: index)  // Pass index to child
}

// In Chapter.swift
func toDict(chapterIndex: Int? = nil) -> [String: Any] {
    var dict: [String: Any] = [...]
    
    if let chapterIndex = chapterIndex {
        dict["chapterNumber"] = chapterIndex + 1
        dict["chapterNumberDisplay"] = "第\(chapterIndex + 1)章"
    }
    
    return dict
}
```

**Valid Combinations:**

```swift
// Example 1: Simple - Skip all intermediate levels
struct SimplePresentation: Presentation {
    let title = "Simple Demo"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 2: With Section - Skip Chapter and Node
struct SectionPresentation: Presentation {
    let title = "Section Demo"
    let sections: [any Section] = [Section1()]
}

struct Section1: Section {
    let title = "Section 1"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 3: With Chapter - Skip Section and Node
struct ChapterPresentation: Presentation {
    let title = "Chapter Demo"
    let chapters: [any Chapter] = [Chapter1()]
}

struct Chapter1: Chapter {
    let title = "Chapter 1"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 4: Full Hierarchy - All levels
struct FullPresentation: Presentation {
    let title = "Full Demo"
    let sections: [any Section] = [Section1()]
}

struct Section1: Section {
    let title = "Section 1"
    let chapters: [any Chapter] = [Chapter1()]
}

struct Chapter1: Chapter {
    let title = "Chapter 1"
    let nodes: [any Node] = [Node1()]
}

struct Node1: Node {
    let title = "Node 1"
    let slides: [any Slide] = [Slide1()]
}
```

**Key Points:**
- Each level can only contain the next level or lower levels
- Presentation can contain Section, Chapter, Node, or Slide
- Section can contain Chapter, Node, or Slide
- Chapter can contain Node or Slide
- Node can contain Slide
- Slide is the lowest level and cannot contain other levels

### Data Flow

```
User writes flat properties:
    let items = ["A", "B", "C"]
    let author = "JK"
            ↓
Mirror discovers all properties (internal)
            ↓
Auto-generates contents dictionary (internal)
    ["items": ["A", "B", "C"], "author": "JK"]
            ↓
Protocol finds data by type
    ContentStyle → finds [String] → renders as list
            ↓
System generates PPTX output
```

All types are `Sendable` for thread safety and use value semantics (structs) for predictability.

## Installation

### Swift Package

```swift
dependencies: [
    .package(path: "path/to/SwiftOffice/B_SwiftSlides")
]
```

### Node.js Dependencies

```bash
cd B_SwiftSlides
npm install
```

Dependencies:
- `pptxgenjs` - PPTX generation
- `convert-excel-to-json` - Excel reading
- `json-as-xlsx` - Excel writing

## Documentation

- [ARCHITECTURE_UNDERSTANDING.md](Docs/ARCHITECTURE_UNDERSTANDING.md) - Architecture overview
- [DESIGN_PHILOSOPHY.md](Docs/DESIGN_PHILOSOPHY.md) - Design philosophy
- [DESIGN_SPECIFICATION.md](Docs/DESIGN_SPECIFICATION.md) - Detailed specification
- [kimi/USER_GUIDE.md](kimi/USER_GUIDE.md) - User guide

## Requirements

- Swift 6.2+
- macOS 12.0+ (for BeautifulMermaid and SwiftUI Gantt charts)
- Node.js 18+ (optional, for PPTX generation only)

## License

MIT
