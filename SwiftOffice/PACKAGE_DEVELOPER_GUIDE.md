# Package Developer Guide

This guide is for **package contributors** who want to develop, extend, or maintain SwiftOffice itself.

> **For application developers**: See [Cases/APPLICATION_DEVELOPER_GUIDE.md](Cases/APPLICATION_DEVELOPER_GUIDE.md) for creating projects using SwiftOffice.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Development Setup](#development-setup)
3. [Project Structure](#project-structure)
4. [Core Patterns](#core-patterns)
5. [Adding New Features](#adding-new-features)
6. [Testing](#testing)
7. [Coding Conventions](#coding-conventions)
8. [Release Process](#release-process)

---

## Architecture Overview

SwiftOffice is a Swift translation of [hqcoffee](../hqcoffee), a CoffeeScript-based hospital data analysis system.

### The Example Case: goodhospital2021

The `Cases/goodhospital2021/` folder serves as both:

1. **A real consulting project** — Originally delivered to a hospital client
2. **A reference implementation** — Demonstrates the complete workflow

This case was selected as the example because:
- It represents a typical hospital data analysis project
- It showcases all three stages (preparation, implementation, reporting)
- It demonstrates the `self.swift` customization pattern
- It has been sanitized for public use (no sensitive data)

### Design Goals

| Goal | How Achieved |
|------|--------------|
| **Minimalism** | One branch = one project, no complex configuration |
| **Usability** | Consultants can use without programming knowledge |
| **Security** | Git-based version control, no database exposure |
| **Historical Truth** | Project branches preserved as-is |
| **Traceability** | Git hash serves as blockchain hash |
| **Evolution** | New projects auto-inherit platform improvements |

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| `struct` over `class` | No inheritance needed, simpler state management |
| `static var` pattern | Matches CoffeeScript's class-side programming |
| `nonisolated(unsafe)` | Swift 6 concurrency for single-threaded use cases |
| Node.js bridge | Leverage existing npm packages for Excel/PPT |
| Protocol-oriented | Composable, testable components |

### Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  (Cases/goodhospital2021/Self.swift, ContentTexts.swift)    │
├─────────────────────────────────────────────────────────────┤
│                      API Layer                               │
│              (SwiftOfficeAPI.swift)                          │
│    readJSON, writeJSON, readExcel, writeExcel, createPPT    │
├─────────────────────────────────────────────────────────────┤
│                    Core Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ CoreEntities │  │ JSONDatabase │  │ NodeJSBridge │      │
│  │ (static var) │  │ (StormDB)    │  │ (IPC)        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                   Scripts Layer                              │
│    readExcel.js, writeExcel.js, pptx.js (Node.js)          │
└─────────────────────────────────────────────────────────────┘
```

### Design Philosophy

> **"文章本天成，妙手偶得之"** — Good design is not deliberately pursued, but naturally emerges through extensive practice.

SwiftOffice is more than a code translation; it is a dialogue between two language paradigms.

#### Original Design Intent (hqcoffee)

The original CoffeeScript framework was designed for consulting companies providing data analysis services. Key requirements:

1. **Easy to use** — Consultants (non-programmers) can use it
2. **Secure** — Data integrity and access control
3. **Historical authenticity** — Projects remain as they were
4. **Traceable** — Every state can be reproduced
5. **Adaptive evolution** — Business logic evolves over time

The elegant solution: **One branch serves one consulting project.**

```
┌─────────────────────────────────────────────────────────────┐
│                     Git as Blockchain                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   main ──► safe ──► goodhospital2021 (project branch)       │
│              │                                               │
│              └──► anotherhospital2022 (project branch)      │
│                                                              │
│   Each project branch = Time capsule, preserved as-is        │
│   Git hash = Blockchain hash, traceable                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

#### Why "self"?

- **self.swift** = The project itself
- Customization needs are implemented here
- Logic that doesn't need reuse goes here
- Each project has its own self

#### Shared vs. Project-Specific

| Location | Purpose | Inheritance |
|----------|---------|-------------|
| `cases/` external | Shared technology | New projects auto-inherit |
| `cases/project/self.swift` | Project-specific | Only for this project |

#### The Exploration Journey

The path to the current design was not straight:

```
v1-class-side      → Class inheritance chain (complex)
v2-pop             → Protocol-oriented (attempt)
v3-refined         → Hybrid approach (transition)
v4-protocol-struct → Deep protocol chain (over-engineered)
v5-first-principles → First principles analysis (reflection)
v6-static-var      → static var pattern (breakthrough!)
v7-json-as-xlsx    → Detail refinement (convergence)
```

#### Key Insight: struct's Lack of Inheritance is an Advantage

| CoffeeScript | Swift |
|--------------|-------|
| `@cso: @dataPrepare?()` | `static var cso` + lazy loading |
| Class inheritance chain | **struct has no inheritance = advantage** |
| Dynamic typing | `[String: Any]` dictionary |
| Git branch = project | Same applies |

The `static var` pattern with `nonisolated(unsafe)` achieves the same lazy-loading + caching pattern as CoffeeScript's class-side programming, without the complexity of inheritance chains.

#### Future Exploration Directions

1. **Swift Concurrency** — Can `actor` provide better cache handling?
2. **Type Safety** — Enhance types while maintaining flexibility?
3. **Cross-platform** — Linux/Windows support
4. **Performance** — Large dataset processing

---

## Development Setup

### Prerequisites

- Xcode 16+ (Swift 6.2)
- Node.js 18+
- npm

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/emptist/swift_office.git
cd swift_office

# Install Node.js dependencies
cd SwiftOffice
npm install

# Open in Xcode
open Package.swift
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter SwiftOfficeAPITests

# Run with verbose output
swift test --verbose
```

---

## Project Structure

```
SwiftOffice/
├── Package.swift              # Swift package manifest
├── README.md                  # User documentation
├── PACKAGE_DEVELOPER_GUIDE.md # This file
│
├── Scripts/                   # Node.js utility scripts
│   ├── pptx.js               # PPT generation (pptxgenjs)
│   ├── readExcel.js          # Excel reading
│   └── writeExcel.js         # Excel writing (json-as-xlsx)
│
├── Sources/SwiftOffice/
│   ├── SwiftOfficeAPI.swift  # Main API entry point
│   ├── CoreEntities.swift    # Cached entities (static var pattern)
│   ├── NodeJSBridge.swift    # Swift ↔ Node.js IPC
│   ├── JSONSimple.swift      # JSON file operations
│   ├── JSONDatabase.swift    # Database layer
│   ├── PPTXGenUtils.swift    # PPT utilities (pptxgenjs)
│   ├── OfficeGenUtils.swift  # DEPRECATED (officegen has bugs)
│   ├── Protocols/            # Protocol definitions
│   └── Implementations/      # v1/v2/v3 entity versions
│
├── Tests/SwiftOfficeTests/   # Test suite
│
├── Cases/                    # Example cases
│   ├── README.md
│   ├── APPLICATION_DEVELOPER_GUIDE.md
│   └── goodhospital2021/
│
├── deprecated_experiments/    # Archived experiments
└── test_output/              # Test output files (gitignored)
```

---

## Core Patterns

### Pattern 1: Static Var + Lazy Loading

The core pattern for data entities:

```swift
public struct 项目设置: CaseSingletonProtocol {
    
    // Storage
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    // Lazy-loaded property
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    // Data preparation
    public static func dataPrepare() -> [String: Any] {
        let entity = CachedEntity(basename: "项目设置")
        return entity.cso
    }
    
    // Cache management
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
}
```

**Why `nonisolated(unsafe)`?**
- Swift 6 strict concurrency requires explicit thread-safety
- For single-threaded use cases, this is safe and simple
- Alternative: Use `@MainActor` or actors, but adds complexity

### Pattern 2: Node.js Bridge

Swift ↔ Node.js communication via stdin/stdout:

```swift
public actor NodeJSBridge {
    public func executeScript(
        _ scriptName: String,
        params: [String: any Sendable & Codable]
    ) async throws -> [String: Any] {
        // 1. Serialize params to JSON
        // 2. Spawn Node.js process
        // 3. Write JSON to stdin
        // 4. Read JSON from stdout
        // 5. Return parsed result
    }
}
```

**Node.js script pattern:**
```javascript
// Read JSON from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const params = JSON.parse(input);
    
    // Process...
    const result = doWork(params);
    
    // Write JSON to stdout
    console.log(JSON.stringify(result));
});
```

### Pattern 3: Protocol-Oriented Design

```swift
// Protocol defines interface
public protocol CaseSingletonProtocol {
    static var cso: [String: Any] { get }
    static func dataPrepare() -> [String: Any]
    static func clearCache()
}

// Struct implements protocol
public struct 项目设置: CaseSingletonProtocol { ... }
```

---

## Adding New Features

### Adding a New API Method

1. **Add to SwiftOfficeAPI.swift:**

```swift
public enum SwiftOffice {
    
    @available(macOS 10.15, *)
    public static func newFeature(input: String) async throws -> String {
        // Implementation
    }
}
```

2. **Add model if needed:**

```swift
public struct NewFeatureModel {
    public let property: String
    
    public init(property: String) {
        self.property = property
    }
}
```

3. **Add tests:**

```swift
@Suite("New Feature Tests")
struct NewFeatureTests {
    @Test("newFeature works correctly")
    func testNewFeature() async throws {
        let result = try await SwiftOffice.newFeature(input: "test")
        #expect(!result.isEmpty)
    }
}
```

4. **Update README.md API Reference**

### Adding a New Node.js Script

1. **Create script in Scripts/:**

```javascript
// Scripts/newScript.js
const newPackage = require('new-package');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    try {
        const params = JSON.parse(input);
        const result = doWork(params);
        console.log(JSON.stringify({ success: true, data: result }));
    } catch (error) {
        console.log(JSON.stringify({ success: false, error: error.message }));
    }
});

function doWork(params) {
    // Implementation
    return params;
}
```

2. **Add package to package.json:**

```bash
npm install new-package
```

3. **Add Swift bridge method in NodeJSBridge.swift** (if needed)

4. **Add high-level API in SwiftOfficeAPI.swift**

---

## Testing

### Test Structure

```swift
import Testing
@testable import SwiftOffice

@Suite("Feature Name Tests")
struct FeatureTests {
    
    @Test("specific behavior")
    func testBehavior() async throws {
        // Arrange
        let input = "test"
        
        // Act
        let result = try await SwiftOffice.someMethod(input)
        
        // Assert
        #expect(result == expected)
    }
}
```

### Test Categories

| Category | Location | Purpose |
|----------|----------|---------|
| Unit Tests | `Tests/SwiftOfficeTests/` | Test individual components |
| Integration Tests | `Tests/SwiftOfficeTests/` | Test Node.js bridge |
| Case Tests | `Cases/*/Tests/` | Test case-specific logic |

### Running Tests

```bash
# All tests
swift test

# Specific suite
swift test --filter SwiftOfficeAPITests

# With coverage
swift test --enable-code-coverage
```

---

## Coding Conventions

### Swift Style

1. **Use English in code and comments** (per user rules)
2. **Use Chinese for domain entities** (项目设置, 院内资料库, etc.)
3. **Mark async methods with `@available(macOS 10.15, *)`**
4. **Use `nonisolated(unsafe)` for static cache variables**
5. **Prefer `struct` over `class`**

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Struct | PascalCase | `ExcelSheet` |
| Protocol | PascalCase + Protocol | `CaseSingletonProtocol` |
| Function | camelCase | `writeExcelSheets` |
| Variable | camelCase | `fileName` |
| Static var | camelCase | `cso` |

### File Organization

```swift
// MARK: - Section Name

public struct Example {
    // MARK: - Properties
    
    public let property: String
    
    // MARK: - Initialization
    
    public init(property: String) {
        self.property = property
    }
    
    // MARK: - Public Methods
    
    public func doSomething() { }
    
    // MARK: - Private Methods
    
    private func helper() { }
}
```

---

## Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable release |
| `develop` | Integration branch |
| `feature/*` | New features |
| `fix/*` | Bug fixes |

### Release Checklist

1. Update version in README.md
2. Update CHANGELOG (if exists)
3. Run all tests: `swift test`
4. Update documentation
5. Create PR to `develop`
6. Merge to `main` after review
7. Tag release: `git tag v1.0.0`

---

## References

- [hqcoffee](../hqcoffee) - Original CoffeeScript implementation
- [Swift 6 Documentation](https://docs.swift.org/)
- [Swift Testing](https://github.com/apple/swift-testing)
- [json-as-xlsx](https://www.npmjs.com/package/json-as-xlsx)
- [pptxgenjs](https://github.com/gitbrent/PptxGenJS)
