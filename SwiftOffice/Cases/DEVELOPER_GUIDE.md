# Developer Guide - Creating a New Case

This guide explains how to create a new project case using SwiftOffice, translating the CoffeeScript workflow to Swift.

## Table of Contents

1. [Overview](#overview)
2. [Workflow Stages](#workflow-stages)
3. [Step-by-Step: Creating a New Case](#step-by-step-creating-a-new-case)
4. [Key Patterns](#key-patterns)
5. [Data Flow](#data-flow)
6. [Testing and Debugging](#testing-and-debugging)

---

## Overview

A "Case" represents a complete data analysis and report generation project. Each case has:

- **Data files**: Excel files containing project configuration and data
- **Swift code**: `Self.swift` for logic, `ContentTexts.swift` for report content
- **Generated products**: Excel reports, PPT presentations, etc.

The case structure mirrors the original CoffeeScript implementation in [hqcoffee](../../hqcoffee).

---

## Workflow Stages

### Stage 1: Data Collection Preparation

**Goal**: Generate data collection templates for the client.

**Input**: Project configuration (indicator system, department settings)

**Output**:
- 项目指标填报表.xlsx - Indicator data collection form
- 项目对标资料表.xlsx - Benchmark data collection form

**Code**:
```swift
let files = try await Stage1Generator.generateAllStage1Products(outputDir: "./output")
```

### Stage 2: Data Analysis Implementation

**Goal**: Process collected data and generate analysis.

**Input**:
- 院内资料库.xlsx - Internal hospital data
- 对标资料库.xlsx - Benchmark data

**Output**: Processed data, intermediate analysis files

### Stage 3: Report Generation

**Goal**: Generate final reports (PPT, PDF, etc.)

**Input**: All processed data from Stage 2

**Output**: Final deliverable reports

---

## Step-by-Step: Creating a New Case

### Step 1: Create Case Folder

```bash
mkdir -p Cases/yourproject2024
```

### Step 2: Create Data Files

Create the following Excel files:

| File | Purpose | Required Sheets |
|------|---------|-----------------|
| 项目设置.xlsx | Project configuration | 一级指标设置, 二级指标设置, 三级指标设置, 科室设置, 项目信息 |
| 院内资料库.xlsx | Internal data | One sheet per department/year |
| 对标资料库.xlsx | Benchmark data | One sheet per benchmark source |

### Step 3: Create Self.swift

```swift
import Foundation

// MARK: - Project Settings Entity

public struct 项目设置: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        let entity = CachedEntity(basename: "项目设置")
        return entity.cso
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
    
    // Convenience accessors
    public static var customerName: String {
        (cso["项目信息"] as? [String: Any])?["customerName"] as? String ?? "Unknown"
    }
    
    public static var finalYear: Int {
        (cso["项目信息"] as? [String: Any])?["finalYear"] as? Int ?? 2024
    }
}

// MARK: - Additional Entities (as needed)

public struct 院内资料库: CaseSingletonProtocol {
    // Similar pattern...
}

// MARK: - Stage 1 Generator

public struct Stage1Generator {
    
    @available(macOS 10.15, *)
    public static func generate项目指标填报表(outputPath: String) async throws -> String {
        let json = 项目设置.cso
        
        let sheets: [ExcelSheet] = [
            // Define your sheets...
        ]
        
        return try await SwiftOffice.writeExcelSheets(
            fileName: outputPath.replacingOccurrences(of: ".xlsx", with: ""),
            sheets: sheets
        )
    }
}
```

### Step 4: Create ContentTexts.swift

```swift
import Foundation

public enum ContentTexts {
    
    public static func introduction() -> [[String: Any]] {
        [
            [
                "title": "Introduction",
                "content": [
                    "key1": "value1",
                    "key2": "value2"
                ]
            ]
        ]
    }
    
    public static func analysis() -> [[String: Any]] {
        // Report sections...
    }
}
```

### Step 5: Test Your Case

```swift
// In your test file
@Test("Generate Stage 1 products")
func testStage1Generation() async throws {
    let outputDir = "./test_output"
    let files = try await Stage1Generator.generateAllStage1Products(outputDir: outputDir)
    
    #expect(files.count == 2)
    #expect(files.allSatisfy { $0.hasSuffix(".xlsx") })
}
```

---

## Key Patterns

### Pattern 1: CaseSingletonProtocol

**Purpose**: Provides lazy-loading + caching for data entities.

**CoffeeScript equivalent**:
```coffeescript
class 项目设置 extends StormDBSingleton
  @cso: @dataPrepare?()  # Lazy load + cache
```

**Swift implementation**:
```swift
public protocol CaseSingletonProtocol {
    static var cso: [String: Any] { get }
    static func dataPrepare() -> [String: Any]
    static func clearCache()
}

public struct 项目设置: CaseSingletonProtocol {
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
}
```

**Why `nonisolated(unsafe)`?**:
- Swift 6 strict concurrency requires explicit thread-safety
- For single-threaded use cases, this is safe and simple
- Avoids complex actor isolation

### Pattern 2: CachedEntity

**Purpose**: Loads Excel/JSON data into memory.

```swift
let entity = CachedEntity(basename: "项目设置")
let data = entity.cso  // Returns [String: Any]
```

The `CachedEntity` automatically:
1. Looks for `项目设置.xlsx` or `项目设置.json`
2. Parses the file into a dictionary
3. Caches the result

### Pattern 3: ExcelSheet Model

**Purpose**: Type-safe Excel generation.

```swift
let sheet = ExcelSheet(
    sheet: "数据",                    // Sheet name
    columns: [                        // Column definitions
        ExcelColumn(label: "名称", value: "name"),
        ExcelColumn(label: "数值", value: "value")
    ],
    content: [                        // Row data
        ["name": "产品A", "value": 100],
        ["name": "产品B", "value": 200]
    ]
)
```

**Column mapping**:
- `label`: What appears in the Excel header
- `value`: The key in each content dictionary

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Stage 1: Preparation                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   项目设置.xlsx ──┐                                              │
│                   │                                              │
│                   ▼                                              │
│            ┌──────────────┐                                      │
│            │   Self.swift │                                      │
│            │  (项目设置)   │                                      │
│            └──────┬───────┘                                      │
│                   │                                              │
│                   ▼                                              │
│            ┌──────────────┐      ┌─────────────────────────┐    │
│            │ Stage1Gen    │─────▶│ 项目指标填报表.xlsx      │    │
│            └──────────────┘      │ 项目对标资料表.xlsx      │    │
│                                  └─────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Stage 2: Implementation                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   项目指标填报表.xlsx ──┐ (filled by client)                     │
│   项目对标资料表.xlsx ──┤                                        │
│                         ▼                                        │
│                  ┌──────────────┐                                │
│                  │   院内资料库  │                                │
│                  │   对标资料库  │                                │
│                  └──────┬───────┘                                │
│                         │                                        │
│                         ▼                                        │
│                  ┌──────────────┐                                │
│                  │ Data Process │                                │
│                  │   Analysis   │                                │
│                  └──────┬───────┘                                │
│                         │                                        │
│                         ▼                                        │
│                  Processed Data (JSON/Cache)                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Stage 3: Report Generation                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Processed Data ──┐                                             │
│   ContentTexts ────┤                                             │
│                     ▼                                            │
│              ┌──────────────┐                                    │
│              │   Report     │                                    │
│              │  Generator   │                                    │
│              └──────┬───────┘                                    │
│                     │                                            │
│                     ▼                                            │
│              ┌──────────────┐                                    │
│              │  Final PPT   │                                    │
│              │  Final Excel │                                    │
│              └──────────────┘                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Testing and Debugging

### Unit Testing

```swift
import Testing
@testable import SwiftOffice

@Suite("项目设置 Tests")
struct 项目设置Tests {
    
    @Test("项目设置 loads correctly")
    func testLoad() {
        let data = 项目设置.cso
        #expect(!data.isEmpty)
    }
    
    @Test("customerName returns correct value")
    func testCustomerName() {
        let name = 项目设置.customerName
        #expect(!name.isEmpty)
    }
    
    @Test("clearCache resets data")
    func testClearCache() {
        _ = 项目设置.cso
        项目设置.clearCache()
        // Verify cache is cleared
    }
}
```

### Debugging Tips

1. **Check file paths**: Ensure Excel files are in the correct directory
   ```swift
   print("Looking for: \(FileManager.default.currentDirectoryPath)")
   ```

2. **Inspect loaded data**:
   ```swift
   let data = 项目设置.cso
   print("Keys: \(data.keys)")
   if let info = data["项目信息"] as? [String: Any] {
       print("Project info: \(info)")
   }
   ```

3. **Verify Excel structure**: Open Excel files and check:
   - Sheet names match expected keys
   - Column headers match expected values
   - Data types are correct (numbers vs strings)

4. **Node.js bridge issues**:
   ```swift
   // Check if Node.js is installed
   // Run: node --version
   
   // Check if npm packages are installed
   // Run: npm list
   ```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Empty `cso` | File not found | Check file path and name |
| Missing keys | Wrong sheet name | Verify Excel sheet names |
| Type mismatch | Wrong data type | Check Excel cell formats |
| Node.js error | Missing packages | Run `npm install` |
| Async error | Missing `@available` | Add `@available(macOS 10.15, *)` |

---

## Best Practices

1. **Use Chinese names for domain entities** - Matches business domain and original CoffeeScript
2. **Keep entities focused** - Each struct handles one data source
3. **Use convenience accessors** - Extract commonly used values into properties
4. **Clear cache between tests** - Avoid test pollution
5. **Document data structure** - Comment on expected Excel structure

---

## References

- [hqcoffee](../../hqcoffee) - Original CoffeeScript implementation
- [Cases/README.md](README.md) - Case folder structure
- [SwiftOffice README](../README.md) - Main API documentation
