# A_PreviousDesign

This directory contains previous experimental designs and approaches for the SwiftOffice library. These experiments led to the key insights that shaped the current SwiftSlides framework in `B_SwiftSlides/`.

## Overview

The code here represents multiple iterations (v1-v6) exploring different approaches to translate CoffeeScript's class-side programming patterns to Swift 6.2.

## Project Structure

```
A_PreviousDesign/
├── Docs/                       # Design documentation
│   ├── ARCHITECTURE.md         # Architecture overview
│   ├── EXPERIMENTAL_PLAN.md    # Experimental plan
│   ├── EXPERIMENTAL_RESULTS.md # Results and findings
│   ├── ISSUES.md               # Known issues and challenges
│   ├── PACKAGE_DEVELOPER_GUIDE.md # Developer guide
│   └── TECHNICAL_DOCUMENTATION.md   # Technical details
├── Implementations/            # Implementation experiments
│   ├── Entities.swift
│   ├── Handlers.swift
│   └── RefinedEntities.swift
├── Protocols/                  # Protocol experiments
│   └── FileHandling.swift
├── Scripts/                    # Node.js utility scripts
│   ├── pptx.js
│   ├── readExcel.js
│   └── writeExcel.js
├── Sources/                    # Swift source code (v1-v6)
│   ├── Alias.swift
│   ├── AnyGlobalSingleton.swift
│   ├── CoreEntities.swift
│   ├── ExperimentalExploration.swift
│   ├── FullTranslation.swift
│   ├── InheritanceProblem.swift
│   ├── JSONDatabase.swift
│   ├── JSONSimple.swift
│   ├── MoreEntities.swift
│   ├── MultiProtocolAdvantage.swift
│   ├── NodeJSBridge.swift
│   ├── NodeJSConfig.swift
│   ├── OfficeGenUtils.swift
│   ├── PPTXGenUtils.swift
│   ├── ProtocolAnalysis.swift
│   ├── Singletons.swift
│   ├── StormDBSingleton.swift
│   ├── SwiftOfficeAPI.swift
│   ├── SwiftOfficeError.swift
│   └── V4ProtocolStruct.swift
├── SwiftOfficeValidator/       # Foundation exploration package
│   ├── Sources/                # Validator source code
│   ├── Tests/                  # Validator tests
│   ├── Scripts/                # Utility scripts
│   ├── Package.swift
│   └── package.json
├── Tests/                      # Test suite for experiments
│   ├── CoreEntitiesTests.swift
│   ├── ExperimentalExplorationTests.swift
│   ├── FileGenerationTests.swift
│   ├── FullTranslationTests.swift
│   ├── InheritanceProblemTests.swift
│   ├── MoreEntitiesTests.swift
│   ├── MultiProtocolAdvantageTests.swift
│   ├── ProtocolAnalysisTests.swift
│   ├── RealCaseValidationTests.swift
│   ├── SwiftOfficeTests.swift
│   ├── SwiftOfficeV3Tests.swift
│   └── V4ProtocolStructTests.swift
├── deprecated_experiments/     # Deprecated experiments
│   ├── ai.md
│   └── stormdb.js
└── test_output/                # Test output files
    ├── complete/
    ├── core/
    ├── evidence/
    ├── multi_version/
    ├── versions/
    └── sample_data.json
```

## Key Experiments

### 1. SwiftOfficeValidator

**Created first as a foundation** to understand the core of Swift ↔ CoffeeScript translation.

This package served as the exploration ground for:
- Understanding Swift's type system vs CoffeeScript's dynamic nature
- Prototyping the Node.js bridge pattern (stdin/stdout JSON I/O)
- Testing Excel/PPT generation before main implementation
- Discovering how to achieve CoffeeScript-level patterns in Swift

### 2. Version Iterations

#### v1-v2: Class Inheritance Approach
- Attempted to use class inheritance to mimic CoffeeScript's class-side patterns
- Encountered issues with Swift's initialization rules and reference semantics

#### v3-v4: Protocol-Oriented Programming (POP)
- Shifted to POP approach using structs and protocols
- Explored protocol composition and extensions
- `V4ProtocolStruct.swift` contains key insights

#### v5: Hybrid Approach
- Combined classes and structs
- `MultiProtocolAdvantage.swift` explores multiple protocol benefits

#### v6: `static var` Pattern Discovery
- **Key insight**: struct's lack of inheritance is an advantage
- By using `static var` with `nonisolated(unsafe)`, achieved the same lazy-loading + caching pattern as CoffeeScript's `@cso: @dataPrepare?()` without the complexity of inheritance chains
- See `Singletons.swift` and `AnyGlobalSingleton.swift` for implementations

### 3. Key Files

| File | Description |
|------|-------------|
| `InheritanceProblem.swift` | Analysis of inheritance issues in Swift |
| `ProtocolAnalysis.swift` | Protocol-oriented design analysis |
| `MultiProtocolAdvantage.swift` | Benefits of multiple protocols |
| `Singletons.swift` | Singleton pattern experiments |
| `NodeJSBridge.swift` | Node.js bridge implementation |
| `JSONDatabase.swift` | JSON-based data handling |
| `ExperimentalExploration.swift` | Various experimental patterns |

## Key Insights

### 1. Struct vs Class

> **struct's lack of inheritance is an advantage**

Classes with inheritance led to complex initialization chains and reference semantics issues. Structs with protocols provided cleaner, more predictable behavior.

### 2. `static var` Pattern

```swift
struct DataStore {
    nonisolated(unsafe) static var shared: DataStore = {
        var store = DataStore()
        store.loadData()
        return store
    }()
}
```

This pattern achieves:
- Lazy initialization (only when first accessed)
- Caching (computed once, reused)
- Thread safety (with appropriate annotations)
- No inheritance complexity

### 3. Protocol Composition

Instead of inheritance hierarchies, use protocol composition:

```swift
protocol Slide { }
protocol 封面样式: Slide { }
protocol 章节样式: Slide { }

struct 封面页: Slide, 封面样式 { }
struct 章节页: Slide, 章节样式 { }
```

## Documentation

- [ARCHITECTURE.md](Docs/ARCHITECTURE.md) - Architecture overview
- [EXPERIMENTAL_PLAN.md](Docs/EXPERIMENTAL_PLAN.md) - Experimental plan and methodology
- [EXPERIMENTAL_RESULTS.md](Docs/EXPERIMENTAL_RESULTS.md) - Results and findings
- [TECHNICAL_DOCUMENTATION.md](Docs/TECHNICAL_DOCUMENTATION.md) - Technical details
- [ISSUES.md](Docs/ISSUES.md) - Known issues and challenges
- [PACKAGE_DEVELOPER_GUIDE.md](Docs/PACKAGE_DEVELOPER_GUIDE.md) - Developer guide

## Relationship to B_SwiftSlides

The experiments in this directory directly informed the design of `B_SwiftSlides/`:

- **Protocol Composition** → Core architecture in B_SwiftSlides
- **`static var` Pattern** → Data handling approach
- **Node.js Bridge** → PPTX generation mechanism
- **JSON-based Data Flow** → Serialization approach

## Running Experiments

```bash
cd A_PreviousDesign
swift build
swift test
```

For SwiftOfficeValidator:

```bash
cd SwiftOfficeValidator
npm install
swift build
swift test
```

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js 18+ (for some experiments)

## License

MIT
