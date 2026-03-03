# SwiftOffice Project Rules

## Project Overview

SwiftOffice is a Swift-based presentation generation framework that uses Protocol-Oriented Programming (POP) and MVVM architecture to create PowerPoint presentations programmatically.

## Core Design Philosophy

### 1. Data-Presentation Separation

**Everything is a dictionary, protocols determine presentation**

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

### 2. Core Elements: Title + Contents

Every slide has two essential elements:
- **title** - The slide title (identifier)
- **contents** - Dictionary data (substance)

Other properties (notes, hidden, fellowSlides) are optional.

### 3. Language Convention

- **Technical terms**: English (title, contents, Slide, TextStyle, etc.)
- **User content**: Any language (Chinese, Japanese, Arabic, etc.)

## Architecture

### MVVM + POP

```
Model (Data)
  ↓
ViewModel (Protocols)
  ↓
View (PPTX/JSON Output)
```

### Key Protocols

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
| `ContainerStyle` | Container for multiple slides | `["layout": "horizontal", "ratio": [0.382, 0.618]]` |

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
