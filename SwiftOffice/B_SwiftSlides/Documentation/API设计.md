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
│  ContainerStyle     →  Multi-slide container            │
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
    let contents: Contents = [
        "Summary": "This course covers medical quality management"
    ]
}
```

### Table (Spreadsheet Format)

```swift
struct CorePoliciesSlide: Slide, TableSlideStyle {
    let title = "Core Policies"
    let contents: Contents = [
        "Category": ["First Diagnosis", "Three-Level Rounds", "Difficult Cases"] as [any Sendable],
        "Policy": ["First Diagnosis Policy", "Three-Level Rounds Policy", "Difficult Case Discussion"] as [any Sendable]
    ]
}
```

Key = Column name, Value = Column data

### Hierarchy Diagram

```swift
struct SystemStructureSlide: Slide, HierarchyStyle {
    let title = "Quality Management System"
    let contents: Contents = [
        "levels": [
            ["Medical Quality Management System"] as [String],
            ["Top Design", "Middle Management"] as [String],
            ["Quality Policy", "Quality System", "Quality Control"] as [String]
        ] as [any Sendable]
    ]
}
```

### Two-Column Layout (Simple)

```swift
struct ComparisonSlide: Slide, TwoColumnStyle {
    let title = "Comparison Analysis"
    let contents: Contents = [
        "left": ["Advantage 1", "Advantage 2"] as [any Sendable],
        "right": ["Disadvantage 1", "Disadvantage 2"] as [any Sendable]
    ]
}
```

### Container Layout (Complex)

For complex layouts that combine multiple slides:

```swift
struct ComparisonContainer: Slide, ContainerStyle {
    let title = "Before vs After Comparison"
    let contents: Contents = [
        "layout": "horizontal",
        "ratio": [0.382, 0.618]  // Golden ratio
    ]
    let fellowSlides: [any Slide] = [
        BeforeSlide(),
        AfterSlide()
    ]
}
```

### Card Layout

```swift
struct FeaturesSlide: Slide, CardStyle {
    let title = "Core Features"
    let contents: Contents = [
        "cards": [
            ["title": "Feature 1", "content": "Description 1"] as [String: any Sendable],
            ["title": "Feature 2", "content": "Description 2"] as [String: any Sendable]
        ] as [any Sendable]
    ]
}
```

## Available Protocols

| Protocol | Purpose | Contents Format |
|----------|---------|-----------------|
| `TextStyle` | Single text | `["label": "content"]` |
| `ContentStyle` | List items | `["label": ["item1", "item2"]]` |
| `TableSlideStyle` | Table | `["column1": [...], "column2": [...]]` |
| `TwoColumnStyle` | Two columns (simple) | `["left": [...], "right": [...]]` |
| `ContainerStyle` | Container (complex) | `["layout": "horizontal", "ratio": [...]]` |
| `CardStyle` | Card layout | `["cards": [...]]` |
| `HierarchyStyle` | Hierarchy structure | `["levels": [[...]]]` |
| `CycleFlowStyle` | Cycle flow | `["items": [...]]` |
| `ParetoStyle` | Pareto chart | `["items": [...]]` |
| `CoverStyle` | Cover slide | `["Subtitle": "...", "Author": "..."]` |
| `ChapterCoverStyle` | Chapter cover | `["ChapterNumber": "1"]` |

## Design Principles

1. **Unified Format** - All contents are dictionaries `[String: any Sendable]`
2. **Protocol Parsing** - Protocols parse dictionaries and determine presentation
3. **User Friendly** - Users only need `title` + `contents`
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
    
    // JSON serialization
    public func toJSONDict() -> [String: Any]
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
    let contents: Contents = [
        "Subtitle": "Core Knowledge and Skills"
    ]
    
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
    let contents: Contents = [
        "类别": ["首诊负责", "三级查房"] as [any Sendable],
        "制度": ["首诊负责制度", "三级查房制度"] as [any Sendable]
    ]
}

// Japanese content
struct コア制度ページ: Slide, TableSlideStyle {
    let title = "コア制度"
    let contents: Contents = [
        "カテゴリー": ["初診担当", "三回診察"] as [any Sendable],
        "制度": ["初診担当制度", "三回診察制度"] as [any Sendable]
    ]
}
```

The framework is language-agnostic - users write content in their preferred language, while the technical API remains in English.

## Two-Column Layout Types

### Simple Type - Horizontal Table

For simple two-column comparisons:

```swift
struct SimpleComparison: Slide, TwoColumnStyle {
    let title = "Simple Comparison"
    let contents: Contents = [
        "left": ["Item 1", "Item 2"] as [any Sendable],
        "right": ["Item A", "Item B"] as [any Sendable]
    ]
}
```

### Complex Type - Container with Sub-slides

For complex layouts with full slide content:

```swift
struct ComplexComparison: Slide, ContainerStyle {
    let title = "Complex Comparison"
    let contents: Contents = [
        "layout": "horizontal",
        "ratio": [0.382, 0.618]  // Golden ratio
    ]
    let fellowSlides: [any Slide] = [
        BeforeImprovement(),  // Full slide with any content
        AfterImprovement()    // Full slide with any content
    ]
}
```

## Notes on Type Annotations

Due to Swift 6's strict concurrency checking, array values in dictionaries need type annotations:

```swift
// Required
let contents: Contents = [
    "items": ["A", "B"] as [any Sendable]
]

// Future improvement: Automatic type inference
// let contents: Contents = [
//     "items": ["A", "B"]
// ]
```

This ensures type safety while maintaining the simple dictionary-based API.
