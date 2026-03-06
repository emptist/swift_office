# SwiftOffice Project Rules

## Project Overview

SwiftOffice is a Swift-based presentation generation framework that uses Protocol-Oriented Programming (POP) and MVVM architecture to create PowerPoint presentations programmatically.

## Core Design Philosophy

### 1. Data-Presentation Separation

**"内容是一味，呈现看协议"** (Content is one flavor, presentation depends on protocol)

```
┌─────────────────────────────────────────────────────────┐
│              User Writes (Flat Properties)               │
├─────────────────────────────────────────────────────────┤
│  struct MySlide: Slide, ContentStyle {                  │
│      let title = "My Slide"                             │
│      let items = ["A", "B", "C"]                        │
│      let author = "JK"                                  │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         System Discovers via Mirror (Internal)           │
├─────────────────────────────────────────────────────────┤
│  contents = ["items": ["A", "B", "C"], "author": "JK"]  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         Protocol Determines Presentation (Style)         │
├─────────────────────────────────────────────────────────┤
│  ContentStyle → finds [String] → renders as list        │
│  TextStyle → finds String → renders as text             │
│  TableSlideStyle → finds [[String]] → renders as table  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              System Generates Output (PPTX)              │
└─────────────────────────────────────────────────────────┘
```

### 2. Core Elements: Title + Flat Properties

Every slide has:
- **title** - The slide title (identifier, required)
- **Flat properties** - User-defined properties (any name, any type)
- **Style protocol** - Determines how to present the data

**`contents` is auto-generated internally via Mirror - users never write it.**

### 3. Language Convention

- **Technical terms**: English (title, Slide, TextStyle, etc.)
- **User content**: Any language (Chinese, Japanese, Arabic, etc.)
- **Property names**: User-defined, any language, any naming

### 4. Type Wrappers (Optional)

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
│   │       ├── SlideStyleProtocols.swift # Style protocols
│   │       ├── Presentation.swift       # Presentation protocol
│   │       └── Section.swift            # Section protocol
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
