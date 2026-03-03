# SwiftOffice

A Swift library for Office document generation using Protocol-Oriented Programming (POP) with Swift 6.2.

## SwiftSlides - PowerPoint Generation Framework

SwiftSlides is a powerful, natural language-like Swift framework for generating PowerPoint presentations. It uses Protocol-Oriented Programming (POP) principles and supports Chinese identifiers for intuitive content creation.

### Features

- **Protocol Composition** - Mix and match slide styles using protocols
- **Data/Presentation Separation** - Clean separation between content and styling
- **Script Mode Support** - Run directly with `swift run` or as scripts
- **23 Slide Types** - Cover, section, list, table, chart, timeline, flowchart, etc.
- **Data-Driven API** - Create slides from arrays, CSV, TSV, or JSON data
- **8 Predefined Themes** - Professional blue, business green, tech purple, etc.
- **4 Presentation Templates** - Project report, training course, annual summary, data analysis
- **Mermaid Diagrams** - Flowcharts, sequence diagrams, Gantt charts
- **Chinese Identifiers** - Natural language-like API in Chinese

## Quick Start (Protocol Composition Mode)

The recommended way to use SwiftSlides with clean separation between content and tools:

### 1. Define Your Content

Edit `Sources/UserPresentation/main.swift`:

```swift
import SwiftSlides

// Define your presentation structure
struct 医院管理总览: Presentation {
    var title = "医院管理总览"
    var author: String? = "张三"
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

struct 历史沿革章节: Section {
    var title = "历史沿革"
    var slides: [any Slide] = [
        章节首页(),
        古代医院(),
        现代医院(),
    ]
}

// Define slides with protocol composition
struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "张三"
}

struct 章节首页: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

struct 古代医院: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

struct 现代医院: Slide, 内容样式 {
    var title = "现代医院"
    var items = [
        "19世纪：无菌手术技术",
        "20世纪：抗生素广泛应用",
        "21世纪：数字化医疗",
    ]
}

// Auto-generated runner (don't modify)
@main
struct AutoRunner {
    static func main() async {
        let presentation = 医院管理总览()
        try? await presentation.generatePPTX(outputPath: "outputs/\(presentation.title).pptx")
    }
}
```

### 2. Generate PPTX

```bash
swift run UserPresentation
```

Output: `outputs/医院管理总览.pptx`

### Style Protocols

Use protocol composition to style your slides:

| Protocol | Properties | Purpose |
|----------|------------|---------|
| `封面样式` | `subtitle`, `author` | Cover slides |
| `章节样式` | `chapterNumber` | Section dividers |
| `内容样式` | `items: [String]` | Bullet point lists |

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

```swift
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

SwiftSlides uses Protocol-Oriented Programming (POP) with the following core protocols:

- `Slide` - Base protocol for all slide types
- `Section` - Container for slides
- `Presentation` - Top-level container

All types are `Sendable` for thread safety and use value semantics (structs) for predictability.

## Installation

### Swift Package

```swift
dependencies: [
    .package(path: "path/to/SwiftOffice")
]
```

### Node.js Dependencies

```bash
cd SwiftOffice
npm install
```

Dependencies:
- `pptxgenjs` - PPTX generation
- `convert-excel-to-json` - Excel reading
- `json-as-xlsx` - Excel writing

## Project Structure

```
SwiftOffice/
├── Sources/
│   ├── SwiftSlides/
│   │   ├── Protocols/           # Core protocols
│   │   │   ├── Slide.swift
│   │   │   ├── Section.swift
│   │   │   ├── Presentation.swift
│   │   │   ├── SlideTypes.swift
│   │   │   ├── Builders.swift
│   │   │   ├── SlideFactory.swift
│   │   │   └── Supporting/
│   │   │       └── Theme.swift
│   │   ├── DataImport/          # CSV/TSV/JSON import
│   │   │   ├── DataImporter.swift
│   │   │   └── CSVParser.swift
│   │   ├── Templates/           # Presentation templates
│   │   │   ├── PresentationTemplate.swift
│   │   │   └── BuiltInTemplates.swift
│   │   └── Mermaid/             # Mermaid diagram generation
│   │       └── MermaidGenerator.swift
│   └── SwiftSlidesDemo/         # Demo application
├── Scripts/
│   └── swiftslides-pptx.js      # JSON to PPTX converter
├── output/                       # Generated files
└── Package.swift
```

## Requirements

- Swift 6.2+
- macOS 10.15+
- Node.js 18+ (for PPTX generation)

## License

MIT
