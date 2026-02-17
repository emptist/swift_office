# SwiftOffice

A Swift library for Office document generation, inspired by CoffeeScript's class-side programming pattern.

## Features

- **Excel Operations**: Read/write Excel files via Node.js bridge
- **PPTX Generation**: Create PowerPoint presentations with charts and tables
- **JSON Database**: Simple JSON-based data storage
- **Static Var Pattern**: Elegant translation of CoffeeScript class-side to Swift

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(path: "path/to/SwiftOffice")
]
```

## Quick Start

### Basic Usage

```swift
import SwiftOffice

// Create a cached entity
let 项目设置 = CachedEntity(basename: "项目设置")
let data = 项目设置.cso  // Lazy loaded

// Alias handling
let 别名 = AliasEntity(basename: "别名库")
let correctName = 别名.adjustedName("内科*")  // Returns "内科"
```

### File Operations

```swift
// JSON file operations
let filename = FileTools.getJSONFilename([
    "dirname": "/path/to/dir",
    "basename": "数据"
])

// Read/write JSON
let data = FileTools.readFromJSON(filename)
FileTools.write2JSON(filename, obj: ["key": "value"])
```

### PPT Generation

```swift
// Generate PPT with charts
let api = SwiftOfficeAPI()
try api.generatePPT(
    output: "report.pptx",
    slides: [
        ["type": "title", "text": "报告标题"],
        ["type": "barChart", "title": "数据对比", "data": [...]]
    ]
)
```

## Architecture

### Core Discovery: `static var` Pattern

**CoffeeScript:**
```coffeescript
class 项目设置
  @cso: @dataPrepare?()
```

**Swift:**
```swift
struct 项目设置 {
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
}
```

### Key Insight

**struct 无继承性 = 优势！**

- No inheritance chain to consider
- No override needed
- Each struct is independent
- Direct `static var` simulates class-side

## Core Components

| Component | Description |
|-----------|-------------|
| `FileTools` | File operations (JSON, Excel) |
| `DatabaseEntity` | Database operations |
| `CachedEntity` | Lazy loading + caching |
| `AliasEntity` | Name alias handling |
| `SwiftOfficeAPI` | Unified API entry point |

## Multi-Version Output

Build different report versions from the same data:

```swift
// Section blocks (reusable components)
enum 章节积木 {
    case 扉页(String)
    case 总体概述
    case 科室对比
    case 结论建议
}

// Compose versions
let 简化版 = 报告版本(
    name: "简化版",
    blocks: [.扉页("报告"), .总体概述, .结论建议]
)
```

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js (for Excel/PPTX operations)

## License

MIT

## Version History

### v1.0.0 (Current)
- Core entity pattern with `static var`
- File operations (JSON, Excel)
- PPTX generation via Node.js bridge
- Multi-version report output
- Comprehensive test coverage
