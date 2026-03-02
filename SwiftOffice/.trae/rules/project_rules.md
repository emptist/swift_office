# SwiftSlides Project Rules

## Core Architecture

### Protocol-Oriented Programming (POP)
- All slide types are `struct` conforming to `Slide` protocol
- All types must be `Sendable` for thread safety
- Use value semantics (structs) over reference types (classes)
- Protocols define both structure and behavior

### Core Protocols
```
Slide → Section → Presentation
```
- `Slide`: Base protocol with `id`, `title`, `slideType`, `toDict()`
- `Section`: Container for slides with serialization
- `Presentation`: Top-level container with theme support

## Naming Conventions

### Chinese Identifiers
- Use Chinese identifiers for public API (e.g., `演示文稿`, `章节`, `封面页`)
- Use English for internal implementation details
- Factory methods: `幻灯片.柱状图(...)`, `幻灯片.表格(...)`

### File Naming
- Protocol files: `Slide.swift`, `Section.swift`, `Presentation.swift`
- Implementation files: `SlideTypes.swift`, `BuiltInTemplates.swift`
- Supporting files in subdirectories: `Supporting/`, `Elements/`

## Development Workflow

### Build and Test
```bash
# Build and run demo
swift run SwiftSlidesDemo

# Generate PPTX from JSON
node Scripts/swiftslides-pptx.js output/demo.pptx < output/demo.json
```

### File Output
- JSON files: `output/*.json`
- PPTX files: `output/*.pptx`
- CSV test data: `output/*.csv`

## Key Implementation Patterns

### Result Builders
Use `@SectionBuilder` and `@PresentationBuilder` for declarative syntax:
```swift
演示文稿(标题: "报告") {
    章节(标题: "第一章") {
        封面页(标题: "标题")
    }
}
```

### Factory Methods
Use `幻灯片` enum for factory methods:
```swift
幻灯片.柱状图(标题: "趋势", 数据: [...])
幻灯片.表格(标题: "数据", 数据: 表格数据)
```

### Data Import
Use `表格数据` for CSV/TSV/JSON import:
```swift
let data = try 表格数据.从CSV内容(csvString)
幻灯片.柱状图(标题: "图表", 数据: data, 标签列: "月份", 数值列: "销售额")
```

### Mermaid Diagrams
Always use configuration for better rendering:
```swift
Mermaid流程图(..., 配置: .大字体)
```

## Node.js Integration

### PPTX Generation
- Script: `Scripts/swiftslides-pptx.js`
- Input: JSON from stdin
- Output: PPTX file path as argument
- Uses `pptxgenjs` library

### Mermaid Rendering
- Uses mermaid.ink API for diagram rendering
- PNG format with scale=2 for better quality
- Fallback to code display if API fails

## Common Pitfalls

### Variable Naming Conflicts
When a method parameter name conflicts with a method name, use `self.`:
```swift
// Wrong: let 数值 = 数值列(数值列)
// Right:
let 数值 = self.数值列(数值列)
```

### Sendable Conformance
All types must be `Sendable`. Use `@available(macOS 10.15, *)` for new types.

### JSON Serialization
Always implement `toDict()` returning `[String: Any]` for JSON output.

## Future Development

### Priority Areas
1. Excel file import support
2. Animation and transition effects
3. More chart customization options
4. Image handling and optimization
5. Custom theme creation

### Code Style
- No comments unless explicitly requested
- Follow existing patterns in codebase
- Use Chinese for user-facing API
- Use English for internal implementation
