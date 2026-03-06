# SwiftOffice Project Rules

## Project Overview

SwiftOffice is a Swift-based presentation generation framework that uses Protocol-Oriented Programming (POP) and MVVM architecture to create PowerPoint presentations programmatically.

## Core Design Philosophy

### 1. Data-Presentation Separation

**"内容是一味，呈现看协议"** (Content is one flavor, presentation depends on protocol)

### 2. Five-Level Hierarchy

```
Presentation (演示文稿/古书) ─ 物理整体
  │
  └── Section (册) ─ 物理分组（如上册、下册）
        │
        └── Chapter (章) ─ 逻辑分组（如第一章）
              │
              └── Node (节) ─ 逻辑分组（如1.1节）
                    │
                    └── Slide (幻灯片) ─ 内容单元
```

**Key Distinction:**
- **Presentation & Section**: Grouped by physical materials (物理材料分组)
- **Chapter, Node & Slide**: Grouped by logic and ideas (逻辑内容分组)

**Hierarchy Rules:**

1. **Order is Fixed**: The hierarchy order is always Presentation → Section → Chapter → Node → Slide
2. **No Reverse Order**: Cannot skip upward (e.g., Slide cannot contain Node)
3. **Flexible Combination**: Users can skip any intermediate levels as needed

**Valid Combinations:**

```swift
// Example 1: Simple - Skip all intermediate levels
struct SimplePresentation: Presentation {
    let title = "Simple Demo"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 2: With Section - Skip Chapter and Node
struct SectionPresentation: Presentation {
    let title = "Section Demo"
    let sections: [any Section] = [Section1(), Section2()]
}

struct Section1: Section {
    let title = "Section 1"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 3: With Chapter - Skip Section and Node
struct ChapterPresentation: Presentation {
    let title = "Chapter Demo"
    let chapters: [any Chapter] = [Chapter1(), Chapter2()]
}

struct Chapter1: Chapter {
    let title = "Chapter 1"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 4: With Node - Skip Section and Chapter
struct NodePresentation: Presentation {
    let title = "Node Demo"
    let nodes: [any Node] = [Node1(), Node2()]
}

struct Node1: Node {
    let title = "Node 1"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// Example 5: Full Hierarchy - All levels
struct FullPresentation: Presentation {
    let title = "Full Demo"
    let sections: [any Section] = [Section1()]
}

struct Section1: Section {
    let title = "Section 1"
    let chapters: [any Chapter] = [Chapter1()]
}

struct Chapter1: Chapter {
    let title = "Chapter 1"
    let nodes: [any Node] = [Node1()]
}

struct Node1: Node {
    let title = "Node 1"
    let slides: [any Slide] = [Slide1()]
}
```

**Key Points:**
- Each level can only contain the next level or lower levels
- Presentation can contain Section, Chapter, Node, or Slide
- Section can contain Chapter, Node, or Slide
- Chapter can contain Node or Slide
- Node can contain Slide
- Slide is the lowest level and cannot contain other levels

### 3. Core Elements: Title + Flat Properties

Every slide has:
- **title** - The slide title (identifier, required)
- **Flat properties** - User-defined properties (any name, any type)
- **Style protocol** - Determines how to present the data

**`contents` is auto-generated internally via Mirror - users never write it.**

### 4. Language Convention

- **Technical terms**: English (title, Slide, TextStyle, etc.)
- **User content**: Any language (Chinese, Japanese, Arabic, etc.)
- **Property names**: User-defined, any language, any naming

### 5. Type Wrappers (Optional)

For semantic clarity, users can use lightweight type wrappers:

```swift
let photo: Image = "photo.jpg"    // Image wrapper (not just String)
let movie: Video = "movie.mp4"    // Video wrapper
```

## Architecture

### MVVM + POP

```
Model (Flat Properties)
  ↓ (Mirror discovers)
ViewModel (Protocols)
  ↓ (Type matching)
View (PPTX/JSON Output)
```

### Key Protocols

| Protocol | Purpose | Finds Type |
|----------|---------|------------|
| `TextStyle` | Single text | String |
| `ContentStyle` | List items | [String] |
| `TableSlideStyle` | Table | [[String]] or column dict |
| `TwoColumnStyle` | Two columns | Two [String] arrays |
| `CardStyle` | Card layout | [[String: Any]] |
| `HierarchyStyle` | Hierarchy | [[String]] or nested nodes |
| `CycleFlowStyle` | Cycle flow | [[String: Any]] |
| `ParetoStyle` | Pareto chart | [[String: Any]] |

**Note**: Protocols find values by type matching, not hardcoded property names.

### Cover Styles for Each Level

| Protocol | Level | Description |
|----------|-------|-------------|
| `PresentationCoverStyle` | Presentation | 封面页 |
| `SectionCoverStyle` | Section | 册封面 |
| `ChapterCoverStyle` | Chapter | 章首页 |
| `NodeCoverStyle` | Node | 节首页 |
| `SlideCoverStyle` | Slide | 幻灯片封面 |
| `EndCoverStyle` | Slide | 结束页 |

**Important Principles:**

1. **Everyone Has a Head, Each Head Needs a Hairstyle**:
   
   **Key Understanding**: Presentation/Chapter/Node/Section themselves ARE covers.
   
   - Every person grows their own head naturally (Presentation/Chapter/Node/Section)
   - A mother doesn't grow a separate head for her child (no extra "Cover" protocols)
   - But each head can have different hairstyles (CoverStyle protocols)
   
   Therefore:
   - Presentation itself is a cover → use `PresentationCoverStyle` for styling
   - Chapter itself is a cover → use `ChapterCoverStyle` for styling
   - Node itself is a cover → use `NodeCoverStyle` for styling
   - Section itself is a cover → use `SectionCoverStyle` for styling
   - Slide needs explicit cover → use `SlideCoverStyle`/`EndCoverStyle`

2. **No Separate Cover Structs**: Cover pages are like book covers - a book has a cover, and each chapter may have a chapter title page. There is no separate "cover struct". Covers should be implemented directly in the Presentation, Section, Chapter, or Node definitions via protocols (PresentationCoverStyle, SectionCoverStyle, ChapterCoverStyle, NodeCoverStyle).

   ❌ Wrong:
   ```swift
   struct Chapter1CoverSlide: Slide, SlideCoverStyle {
       let title = "第一章：AI时代与数据资产"
       let subtitle = "课程时长：1小时"
   }
   ```

   ✅ Correct:
   ```swift
   struct Chapter1: Chapter, ChapterCoverStyle {
       let title = "第一章：AI时代与数据资产"
       let subtitle = "课程时长：1小时"
       let nodes: [any Node] = [...]
   }
   ```

2. **Semantic Naming**: If an intermediate level is not needed, don't force that level's name. Otherwise, it becomes very confusing.

   ❌ Wrong:
   ```swift
   struct Chapter5: Chapter {
       let title = "第五章：..."
       let slides: [any Slide] = [...]  // No Node, but still called Chapter
   }
   ```

   ✅ Correct:
   ```swift
   struct ManagementSystemChapter: Chapter {  // Semantic name
       let title = "第五章：..."
       let slides: [any Slide] = [...]
   }
   ```

   Or skip the Chapter level entirely:
   ```swift
   struct ManagementSystemSection: Section {  // Direct Section
       let title = "第五章：..."
       let slides: [any Slide] = [...]
   }
   ```

3. **No Generic Node Names**: Don't use generic names like `Chapter1Node1`, `Chapter1Node2`. Use semantic names that reflect the actual content.

   ❌ Wrong:
   ```swift
   struct Chapter1Node1: Node {
       let title = "1.1 AI时代背景"  // No semantic meaning
   }
   ```

   ✅ Correct:
   ```swift
   struct AIEraBackgroundNode: Node {  // Semantic name
       let title = "1.1 AI时代背景"
   }
   ```

### User API (Minimal)

**User writes**:
```swift
struct MySlide: Slide, ContentStyle {
    let title = "My Slide"
    let items = ["A", "B", "C"]      // Any property name
    let author = "JK"                 // Any property name
}
```

**System does**:
1. Mirror discovers all properties
2. Auto-generates `contents` dictionary internally
3. Protocol finds data by type
4. Renders beautifully

## Coding Standards

### 1. Swift Version

Use Swift 6.2 to take advantage of new features and improvements.

### 2. Testing

Use new Swift testing features instead of XCTest framework.

### 3. Code Style

- Use English for code and comments
- Follow Swift naming conventions
- Use `let` for immutable properties
- Use protocol composition for flexibility

### 4. Security

- Never expose or log secrets and keys
- Never commit secrets to repository
- Update .gitignore to exclude sensitive files

### 5. Documentation

- Update documentation after completing tasks
- Keep README files up to date
- Document API changes

## Build Commands

```bash
# Build project
swift build

# Run tests
swift test

# Run demo
swift run SwiftSlidesDemo

# Generate PPTX
node B_SwiftSlides/Scripts/swiftslides-pptx.js <input.json> <output.pptx>
```

## File Structure

```
SwiftOffice/
├── B_SwiftSlides/
│   ├── Sources/
│   │   └── Protocols/
│   │       ├── Slide.swift              # Core Slide protocol
│   │       ├── Node.swift               # Node protocol (节)
│   │       ├── Chapter.swift            # Chapter protocol (章)
│   │       ├── Section.swift            # Section protocol (册)
│   │       ├── Presentation.swift       # Presentation protocol
│   │       └── SlideStyleProtocols.swift # Style protocols
│   ├── Demo/
│   │   └── APITest.swift                # API test examples
│   ├── Scripts/
│   │   └── swiftslides-pptx.js          # PPTX generation script
│   └── Documentation/
│       └── API设计.md                    # API design document
├── Cases/                                # User content (gitignored)
├── Outputs/                              # Generated files (gitignored)
└── Package.swift                         # Swift package configuration
```

## Git Ignore

The following directories are excluded from version control:
- `Cases/` - User content files
- `Outputs/` - Generated files
- `.build/` - Build artifacts
- `node_modules/` - Node.js dependencies

## Best Practices

1. **Before making changes**: Understand existing code conventions
2. **Search documentation first**: Check official docs before using tools/libraries
3. **Use latest versions**: Keep dependencies up to date
4. **Think before acting**: Plan complex changes carefully
5. **Clean up**: Delete unnecessary files after testing
6. **Be consistent**: Follow existing code style
7. **Protect privacy**: Never commit sensitive data
