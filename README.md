# Swift For Office

A Swift library for Office document generation, translating CoffeeScript's class-side programming pattern to Swift 6.2.

## Project Structure

```
swift_office/
├── SwiftOffice/           # Main library
│   ├── Sources/           # Swift source code
│   ├── Scripts/           # Node.js utility scripts
│   ├── Tests/             # Test suite
│   └── README.md          # Detailed documentation
├── SwiftOfficeValidator/  # Foundation exploration (created first)
│   ├── Sources/
│   ├── Scripts/
│   └── Tests/
└── references/            # Design documentation
```

## Packages

### SwiftOffice

The main library for Office document generation.

**Key Features:**
- Excel read/write via Node.js bridge (`json-as-xlsx`)
- PPTX generation via `pptxgenjs`
- Native Swift JSON handling
- `static var` pattern for lazy-loading + caching

**Quick Start:**
```bash
cd SwiftOffice
npm install
swift build
swift test
```

See [SwiftOffice/README.md](SwiftOffice/README.md) for full documentation.

### SwiftOfficeValidator

**Created first as a foundation** to understand the core of Swift ↔ CoffeeScript translation. This package served as the exploration ground for:

- Understanding Swift's type system vs CoffeeScript's dynamic nature
- Prototyping the Node.js bridge pattern (stdin/stdout JSON I/O)
- Testing Excel/PPT generation before main implementation
- Discovering how to achieve CoffeeScript-level patterns in Swift

See [SwiftOfficeValidator/](SwiftOfficeValidator/) for details.

## Development History

1. **SwiftOfficeValidator** - Foundation exploration, understanding Swift ↔ CoffeeScript patterns
2. **SwiftOffice v1-v5** - Multiple approaches (class inheritance, POP, hybrid)
3. **SwiftOffice v6** - `static var` pattern discovery (final approach)
4. **adjust branch** - Switch to `json-as-xlsx` (matches hqcoffee reference)

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js 18+

## Origin

This project is a Swift translation of [hqcoffee](../hqcoffee), a CoffeeScript-based hospital data analysis and report generation system.

## Key Insight

> **struct's lack of inheritance is an advantage**

By using `static var` with `nonisolated(unsafe)`, we achieve the same lazy-loading + caching pattern as CoffeeScript's `@cso: @dataPrepare?()` without the complexity of inheritance chains.

## License

MIT
