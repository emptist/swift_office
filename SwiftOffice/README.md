# SwiftOffice

A Swift library for Office document generation, translating CoffeeScript's class-side programming pattern to Swift 6.2.

## Overview

SwiftOffice is a Swift translation of [hqcoffee](../hqcoffee), a CoffeeScript-based hospital data analysis and report generation system. The key insight from this translation:

> **struct 无继承性 = 优势！** (struct's lack of inheritance is an advantage)

By using `static var` with `nonisolated(unsafe)`, we achieve the same lazy-loading + caching pattern as CoffeeScript's `@cso: @dataPrepare?()` without the complexity of inheritance chains.

## Features

- **Excel Operations**: Read/write Excel files via Node.js bridge
- **PPTX Generation**: Create PowerPoint presentations with charts and tables
- **JSON Database**: Native Swift JSON handling (no external dependencies)
- **Static Var Pattern**: Elegant translation of CoffeeScript class-side to Swift

## Architecture

### Core Pattern: `static var` + Lazy Loading

**CoffeeScript:**
```coffeescript
class 项目设置
  @cso: @dataPrepare?()  # Lazy load + cache
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

### Why struct > class for this use case

| Aspect | class (inheritance) | struct (static var) |
|--------|---------------------|---------------------|
| Inheritance chain | Up to 6 levels deep | None needed |
| Override complexity | Required | Not applicable |
| State management | Instance + static | Static only |
| Thread safety | Manual | `nonisolated(unsafe)` |
| Simplicity | Medium | High |

## Installation

### Swift Package

Add to your `Package.swift`:

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
- `convert-excel-to-json` - Excel reading
- `json-as-xlsx` - Excel writing (matches hqcoffee reference)
- `pptxgenjs` - PPT generation (ONLY supported PPT library)

> **Note:** The `officegen` package was evaluated but contains bugs and is NOT used. Only `pptxgenjs` is supported for PPT generation. This matches the original CoffeeScript implementation (hqcoffee).

## Quick Start

### Basic Usage

```swift
import SwiftOffice

// JSON operations (native Swift, no Node.js)
let data = SwiftOffice.readJSON(from: "data.json")
SwiftOffice.writeJSON(["key": "value"], to: "output.json")

// Entity access with caching
let alias = SwiftOffice.别名库
let correctedName = alias.adjustedName("内科*")  // Returns "内科"
```

### Excel Operations

```swift
// Read Excel
let excelData = try await SwiftOffice.readExcel(path: "data.xlsx")

// Write Excel - High-level API (Recommended)
let sheets: [ExcelSheet] = [
    ExcelSheet(
        sheet: "数据",
        columns: [
            ExcelColumn(label: "名称", value: "name"),
            ExcelColumn(label: "数值", value: "value")
        ],
        content: [
            ["name": "产品A", "value": 100],
            ["name": "产品B", "value": 200]
        ]
    )
]
let fileName = try await SwiftOffice.writeExcelSheets(fileName: "output", sheets: sheets)
// Creates: output.xlsx

// Write Excel - Low-level API (for advanced use)
let data: [[String: Any]] = [
    [
        "sheet": "数据",
        "columns": [
            ["label": "名称", "value": "name"],
            ["label": "数值", "value": "value"]
        ],
        "content": [
            ["name": "产品A", "value": 100],
            ["name": "产品B", "value": 200]
        ]
    ]
]
try await SwiftOffice.writeExcel(fileName: "output", data: data)
```

### PPT Generation

```swift
try await SwiftOffice.createPPT(
    slides: [
        ["title": "报告标题", "content": "内容"],
        ["type": "barChart", "title": "数据对比", "data": [...]]
    ],
    outputPath: "report.pptx"
)
```

## API Reference

### SwiftOffice Main API

| Method | Description |
|--------|-------------|
| `readJSON(from:)` | Read JSON file (native Swift) |
| `writeJSON(_:to:)` | Write JSON file (native Swift) |
| `readExcel(path:header:columnToKey:)` | Read Excel to JSON (async) |
| `writeExcel(fileName:data:extraLength:)` | Write Excel from raw data (async) |
| `writeExcelSheets(fileName:sheets:extraLength:)` | Write Excel from typed sheets (async, recommended) |
| `createPPT(slides:outputPath:)` | Generate PPTX file (async) |

### Excel Models

```swift
// ExcelSheet - Represents a single worksheet
public struct ExcelSheet {
    public let sheet: String              // Sheet name
    public let columns: [ExcelColumn]     // Column definitions
    public let content: [[String: Any]]   // Row data
}

// ExcelColumn - Defines a column
public struct ExcelColumn {
    public let label: String   // Column header text
    public let value: String   // Key in content dictionary
}
```

### PPTGenerator Enum

```swift
public enum PPTGenerator: String, Sendable {
    case pptxgen = "pg"      // Active: https://github.com/gitbrent/PptxGenJS
    case officegen = "og"    // DEPRECATED: Contains bugs, not recommended
}
```

> **Note:** Only `pptxgenjs` is actively supported. The `officegen` case is preserved for documentation and future comparison purposes.

## Project Structure

```
SwiftOffice/
├── Scripts/                    # Node.js utility scripts
│   ├── pptx.js                # PPT generation (pptxgenjs)
│   ├── readExcel.js           # Excel reading (convert-excel-to-json)
│   └── writeExcel.js          # Excel writing (json-as-xlsx)
├── Sources/SwiftOffice/
│   ├── Protocols/
│   │   └── FileHandling.swift # Core protocols
│   ├── Implementations/
│   │   ├── Entities.swift     # v1 class-based entities
│   │   ├── Handlers.swift     # v2 protocol+struct
│   │   └── RefinedEntities.swift # v3 refined
│   ├── JSONSimple.swift       # Base JSON operations
│   ├── JSONDatabase.swift     # Database layer
│   ├── StormDBSingleton.swift # Singleton pattern
│   ├── NodeJSBridge.swift     # Swift ↔ Node.js IPC
│   ├── SwiftOfficeAPI.swift   # Unified API entry
│   └── V4ProtocolStruct.swift # Protocol inheritance chain
├── Tests/SwiftOfficeTests/    # Test suite
├── deprecated_experiments/     # Archived experiments
└── test_output/               # Test output files
```

## Node.js Scripts

| Script | Purpose | Input | Output |
|--------|---------|-------|--------|
| `readExcel.js` | Read Excel to JSON | stdin: `{path, header, columnToKey}` | stdout: `{success, data}` |
| `writeExcel.js` | Write JSON to Excel | stdin: `{fileName, data}` | stdout: `{success, fileName}` |
| `pptx.js` | Generate PPTX | stdin: `{action, slides, path}` | stdout: `{success}` |

All scripts use stdin/stdout JSON I/O for inter-process communication with Swift.

## Version History

### v1.0.1 (adjust branch) - Excel Package Switch

- Switched from `exceljs` to `json-as-xlsx` (matches hqcoffee reference)
- Added `Scripts/writeExcel.js` using `json-as-xlsx` format
- Moved `stormdb.js` to `deprecated_experiments/` (native Swift implementation exists)
- Updated `.gitignore` for generated files

### v1.0.0 - `static var` Pattern

- Core entity pattern with `nonisolated(unsafe) static var`
- Native Swift JSON operations (no Node.js dependency for JSON)
- Excel read/write via Node.js bridge
- PPTX generation via Node.js bridge

### Branch History

| Branch | Purpose | Status |
|--------|---------|--------|
| **adjust** | Switch to `json-as-xlsx` | **Current** |
| v6-static-var-refactor | `static var` pattern | Base for adjust |
| v5-first-principles | First principles analysis | Merged |
| v4-protocol-struct | Deep protocol chain | Superseded |
| v3-refined | Class + Protocol hybrid | Superseded |
| v2-pop | Protocol-Oriented | Superseded |
| v1-class-side | Class inheritance | Superseded |

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js 18+ (for Excel/PPTX operations)

## References

- [hqcoffee](../hqcoffee) - Original CoffeeScript implementation
- [Cases/DEVELOPER_GUIDE.md](Cases/DEVELOPER_GUIDE.md) - Step-by-step guide for creating new cases
- [ARCHITECTURE.md](Sources/SwiftOffice/ARCHITECTURE.md) - Detailed architecture docs
- [TECHNICAL_DOCUMENTATION.md](Sources/SwiftOffice/TECHNICAL_DOCUMENTATION.md) - Translation experience

## License

MIT
