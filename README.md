# Swift For Office

A Swift library for Office document generation, translating CoffeeScript's class-side programming pattern to Swift 6.2.

## Project Structure

```
swift_office/
├── SwiftOffice/           # Main library
│   ├── A_PreviousDesign/  # Previous experimental designs
│   │   ├── Docs/          # Design documentation
│   │   ├── Sources/       # Swift source code (v1-v6 experiments)
│   │   ├── Tests/         # Test suite
│   │   └── SwiftOfficeValidator/  # Foundation exploration
│   ├── B_SwiftSlides/     # Current SwiftSlides framework
│   │   ├── Sources/       # Framework source code
│   │   ├── Demo/          # Usage examples
│   │   ├── Tests/         # Test suite
│   │   ├── Docs/          # Architecture documentation
│   │   └── kimi/          # AI-assisted exploration
│   ├── Cases/             # Real-world application cases
│   │   └── goodhospital2021/  # Hospital management case
│   ├── Package.swift      # Swift Package manifest
│   └── README.md          # Detailed documentation
└── references/            # Design documentation
```

## Directory Overview

### A_PreviousDesign/

Contains previous experimental designs and approaches:
- **Docs/**: Design documents, architecture decisions, experimental results
- **Sources/**: Swift source code from v1-v6 iterations
- **Tests/**: Test suites for various approaches
- **SwiftOfficeValidator/**: Foundation exploration package (created first)

Key insight from these experiments:
> **struct's lack of inheritance is an advantage**
> By using `static var` with `nonisolated(unsafe)`, we achieve the same lazy-loading + caching pattern as CoffeeScript's `@cso: @dataPrepare?()` without the complexity of inheritance chains.

### B_SwiftSlides/

Current SwiftSlides framework - the main implementation:
- **Sources/**: Framework source code
  - **Protocols/**: Core protocols (Presentation, Section, Slide, etc.)
  - **DataImport/**: CSV data import functionality
  - **Gantt/**: Gantt chart generation
  - **Mermaid/**: Mermaid diagram support
  - **Templates/**: Presentation templates
- **Demo/**: Usage examples including Protocol Composition demo
- **Tests/**: Framework test suite
- **Docs/**: Architecture and design documentation
- **kimi/**: AI-assisted exploration content

### Cases/

Real-world application cases:
- **goodhospital2021/**: Hospital data analysis and report generation case

## Packages

### SwiftOffice

The main library for Office document generation.

**Key Features:**
- Excel read/write via Node.js bridge (`json-as-xlsx`)
- PPTX generation via `pptxgenjs`
- Native Swift JSON handling
- `static var` pattern for lazy-loading + caching
- Protocol-Oriented Programming (POP) for slide composition

**Quick Start:**
```bash
cd SwiftOffice
npm install
swift build
swift test
```

See [SwiftOffice/B_SwiftSlides/README.md](SwiftOffice/B_SwiftSlides/README.md) for full documentation.

### SwiftOfficeValidator

**Created first as a foundation** to understand the core of Swift ↔ CoffeeScript translation. This package served as the exploration ground for:

- Understanding Swift's type system vs CoffeeScript's dynamic nature
- Prototyping the Node.js bridge pattern (stdin/stdout JSON I/O)
- Testing Excel/PPT generation before main implementation
- Discovering how to achieve CoffeeScript-level patterns in Swift

See [SwiftOffice/A_PreviousDesign/SwiftOfficeValidator/](SwiftOffice/A_PreviousDesign/SwiftOfficeValidator/) for details.

## Development History

1. **SwiftOfficeValidator** - Foundation exploration, understanding Swift ↔ CoffeeScript patterns
2. **A_PreviousDesign v1-v6** - Multiple approaches (class inheritance, POP, hybrid)
3. **B_SwiftSlides** - Current SwiftSlides framework with Protocol Composition
4. **adjust branch** - Switch to `json-as-xlsx` (matches hqcoffee reference)

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js 18+

## Origin

This project is a Swift translation of [hqcoffee](../hqcoffee), a CoffeeScript-based hospital data analysis and report generation system.

## License

MIT
