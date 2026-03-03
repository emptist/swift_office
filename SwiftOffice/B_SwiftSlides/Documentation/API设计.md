# SwiftSlides API Design

## Core Philosophy

**Data-Presentation Separation** - Everything is a dictionary, protocols determine presentation

```
┌─────────────────────────────────────────────────────────┐
│                    Data Sources (Unified Format)         │
├─────────────────────────────────────────────────────────┤
│  JSON file  →  Dictionary  ←  Database  ←  Hand-written │
│                                                         │
│  { "key": "value" }                                     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Protocols (Determine Presentation)    │
├─────────────────────────────────────────────────────────┤
│  TableSlideStyle    →  Table slide                      │
│  CardStyle          →  Card layout                      │
│  ContentStyle       →  List display                     │
│  HierarchyStyle     →  Hierarchy diagram                │
└─────────────────────────────────────────────────────────┘
```

## User Writing Style

Users only need to write two elements:
1. `title` - The slide title
2. `contents` - Dictionary data (user content can be in any language)

### Single Item

```swift
struct IntroSlide: Slide, TextStyle {
    let title = "Introduction"
    let contents = ["Summary": "This course covers medical quality management"]
}
```

### Table (Spreadsheet Format)

```swift
struct CorePoliciesSlide: Slide, TableSlideStyle {
    let title = "Core Policies"
    let contents = [
        "Category": ["First Diagnosis", "Three-Level Rounds", "Difficult Cases"],
        "Policy": ["First Diagnosis Policy", "Three-Level Rounds Policy", "Difficult Case Discussion Policy"]
    ]
}
```

Key = Column name, Value = Column data

### Hierarchy Diagram

```swift
struct SystemStructureSlide: Slide, HierarchyStyle {
    let title = "Quality Management System"
    let contents = [
        "levels": [
            ["Medical Quality Management System"],
            ["Top Design", "Middle Management", "Bottom Execution"]
        ]
    ]
}
```

### Two-Column Layout

```swift
struct ComparisonSlide: Slide, TwoColumnStyle {
    let title = "Comparison Analysis"
    let contents = [
        "left": ["Advantage 1", "Advantage 2"],
        "right": ["Disadvantage 1", "Disadvantage 2"]
    ]
}
```

### Card Layout

```swift
struct FeaturesSlide: Slide, CardStyle {
    let title = "Core Features"
    let contents = [
        "cards": [
            ["title": "Feature 1", "content": "Description 1"],
            ["title": "Feature 2", "content": "Description 2"]
        ]
    ]
}
```

## Available Protocols

| Protocol | Purpose | Contents Format |
|----------|---------|-----------------|
| `TextStyle` | Single text | `["label": "content"]` |
| `ContentStyle` | List items | `["label": ["item1", "item2"]]` |
| `TableSlideStyle` | Table | `["column1": [...], "column2": [...]]` |
| `TwoColumnStyle` | Two columns | `["left": [...], "right": [...]]` |
| `CardStyle` | Card layout | `["cards": [...]]` |
| `HierarchyStyle` | Hierarchy structure | `["levels": [[...]]]` |
| `CycleFlowStyle` | Cycle flow | `["items": [...]]` |
| `ParetoStyle` | Pareto chart | `["items": [...]]` |

## Design Principles

1. **Unified Format** - All contents are dictionaries `[String: Any]`
2. **Protocol Parsing** - Protocols parse dictionaries and determine presentation
3. **User Friendly** - Users don't need to know about `Contents` type
4. **Data Source Agnostic** - JSON, database, hand-written all use the same format
5. **Type Safe** - `Contents` provides type-safe access
6. **Language Agnostic** - User content can be in any language

## Internal Implementation

### Contents Type

```swift
public struct Contents: Sendable, ExpressibleByDictionaryLiteral {
    public var dict: [String: any Sendable]
    
    // Supports dictionary literals
    public init(dictionaryLiteral elements: (String, any Sendable)...)
    
    // Type-safe access
    public var asString: String
    public var asStringArray: [String]
    public var asStringTable: [[String]]
}
```

### ContentParser

```swift
public enum ContentParser {
    // Parse single string
    public static func parseString(_ contents: Contents) -> String
    
    // Parse string array
    public static func parseStringArray(_ contents: Contents) -> [String]
    
    // Parse table (supports spreadsheet format)
    public static func parseTable(_ contents: Contents) -> (headers: [String], rows: [[String]])
    
    // Parse hierarchy structure
    public static func parseHierarchy(_ contents: Contents) -> SlideHierarchyNode?
}
```

## Example: Complete Course

```swift
struct MedicalQualityCourse: Slide, WithSubslidesStyle {
    let title = "Medical Quality Management"
    let contents = ["Subtitle": "Core Knowledge and Skills"]
    
    let fellowSlides: [any Slide] = [
        IntroSlide(),
        CorePoliciesSlide(),
        SystemStructureSlide()
    ]
}
```

## User Content in Any Language

Users can write content in any language they prefer:

```swift
// Chinese content
struct 核心制度页: Slide, TableSlideStyle {
    let title = "核心制度"
    let contents = [
        "类别": ["首诊负责", "三级查房"],
        "制度": ["首诊负责制度", "三级查房制度"]
    ]
}

// Japanese content
struct コア制度ページ: Slide, TableSlideStyle {
    let title = "コア制度"
    let contents = [
        "カテゴリー": ["初診担当", "三回診察"],
        "制度": ["初診担当制度", "三回診察制度"]
    ]
}

// Arabic content
struct السياساتالأساسية: Slide, TableSlideStyle {
    let title = "السياسات الأساسية"
    let contents = [
        "الفئة": ["التشخيص الأول", "الجولات الثلاث"],
        "السياسة": ["سياسة التشخيص الأول", "سياسة الجولات الثلاث"]
    ]
}
```

The framework is language-agnostic - users write content in their preferred language, while the technical API remains in English.
