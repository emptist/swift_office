# Changelog - 2026-03-06

## Major Design Change: Flat Properties API

### Summary

Changed from dictionary-based `contents` to flat properties with Mirror-based discovery.

### Before (Old API)

```swift
struct MySlide: Slide, ContentStyle {
    let title = "My Slide"
    let contents: SlideContent = [
        "items": ["A", "B", "C"] as [any Sendable],
        "author": "JK"
    ]
}
```

### After (New API)

```swift
struct MySlide: Slide, ContentStyle {
    let title = "My Slide"
    let items = ["A", "B", "C"]
    let author = "JK"
}
```

---

## Changes Made

### 1. Slide Protocol (Slide.swift)

**Removed from protocol:**
- `var contents: SlideContent { get }`

**Added as computed property (auto-generated):**
```swift
var contents: SlideContent {
    var dict: [String: any Sendable] = [:]
    let mirror = Mirror(reflecting: self)
    let excludedProperties = ["id", "title", "notes", "hidden", "fellowSlides", "contents"]
    
    for child in mirror.children {
        guard let label = child.label,
              !excludedProperties.contains(label) else {
            continue
        }
        // Type matching for supported types
        if let value = child.value as? String { dict[label] = value }
        else if let value = child.value as? [String] { dict[label] = value as any Sendable }
        // ... more types
    }
    return SlideContent(dict)
}
```

### 2. Style Protocols (SlideStyleProtocols.swift)

**Changed:** All hardcoded key access replaced with type-based traversal.

**Example - ContentStyle:**
```swift
// Before
var items: [String] { contents["items"]?.asStringArray ?? [] }

// After
var items: [String] { ContentParser.parseStringArray(contents) }
```

**Example - TwoColumnStyle:**
```swift
// Before
var leftItems: [String] { contents["left"]?.asStringArray ?? [] }

// After
var leftItems: [String] {
    for (key, value) in contents.dict {
        let pattern = "^(左|left)$"
        if key.range(of: pattern, options: .regularExpression) != nil {
            return value as? [String] ?? []
        }
    }
    return []
}
```

### 3. ContentParser (SlideStyleProtocols.swift)

**Added helper methods:**
- `parseStringArray(_ contents: SlideContent) -> [String]`
- `parseString(_ contents: SlideContent) -> String`
- `parseTable(_ contents: SlideContent) -> (headers: [String], rows: [[String]])`
- `parseHierarchy(_ contents: SlideContent) -> SlideHierarchyNode?`

### 4. project_rules.md

**Updated:**
- New design philosophy diagram
- Flat properties API examples
- Removed `contents` from user API
- Added Mirror discovery explanation

---

## Files Modified

| File | Changes |
|------|---------|
| `Sources/Protocols/Slide.swift` | Removed `contents` from protocol, added Mirror-based auto-generation |
| `Sources/Protocols/SlideStyleProtocols.swift` | Fixed hardcoded keys, added type-based traversal |
| `.trae/rules/project_rules.md` | Updated design philosophy documentation |

---

## Backward Compatibility

**Breaking change:** Old code using `let contents: SlideContent = [...]` will still compile but `contents` is now computed, not stored.

**Migration:** Simply remove the `contents` wrapper and use flat properties:

```swift
// Old
let contents: SlideContent = ["items": ["A", "B"]]

// New
let items = ["A", "B"]
```

---

## Design Philosophy

**"内容是一味，呈现看协议"** (Content is one flavor, presentation depends on protocol)

1. **User provides**: Flat properties (any name, any type)
2. **Mirror discovers**: All properties auto-collected into `contents`
3. **Protocol determines**: How to find and present data by type
4. **System renders**: Beautiful PPTX output

---

## Next Steps

- [ ] Add lightweight type wrappers (Image, Video, Chart)
- [ ] Create tests for new flat property API
- [ ] Update APITest.swift to use new API
