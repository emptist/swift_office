# Swift For Office

A Swift library for Office document generation, inspired by CoffeeScript's class-side programming pattern.

## Overview

SwiftOffice enables Swift applications to generate Office documents (Excel, PPTX) by leveraging Node.js packages through a bridge pattern. The core discovery is that **struct + static var** provides an elegant translation of CoffeeScript's class-side programming.

## Quick Start

```swift
import SwiftOffice

// Create a cached entity
let 项目设置 = CachedEntity(basename: "项目设置")
let data = 项目设置.cso  // Lazy loaded

// Generate PPT
let api = SwiftOfficeAPI()
try api.generatePPT(output: "report.pptx", slides: [...])
```

## Core Discovery

| CoffeeScript | Swift |
|--------------|-------|
| `项目设置.cso` | `项目设置.cso` ✅ |
| class-side | static var |
| class inheritance | struct (no inheritance needed) |

**Key Insight**: struct's lack of inheritance is actually an advantage - no override needed, each struct is independent.

## Features

- ✅ Excel read/write (via Node.js bridge)
- ✅ PPTX generation with charts
- ✅ JSON database
- ✅ Multi-version report output
- ✅ Alias handling for Chinese names

## Installation

```swift
dependencies: [
    .package(path: "path/to/SwiftOffice")
]
```

## Requirements

- Swift 6.2+
- macOS 14.0+
- Node.js (for Excel/PPTX operations)

## Documentation

- [SwiftOffice/README.md](SwiftOffice/README.md) - Package documentation
- [EXPERIMENTAL_RESULTS.md](SwiftOffice/Sources/SwiftOffice/EXPERIMENTAL_RESULTS.md) - Core discovery
- [TECHNICAL_DOCUMENTATION.md](SwiftOffice/Sources/SwiftOffice/TECHNICAL_DOCUMENTATION.md) - Full technical details

## Version

**v1.0.0** - [Release Notes](https://github.com/your-repo/swift_office/releases/tag/v1.0.0)

## License

MIT
