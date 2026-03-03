# PreviousDesign Issues

## Build Errors (as of 2026-03-03)

### 1. SwiftOfficeAPI.swift:108 - Type Conversion Error
```
error: cannot convert value of type '[[String : Any]]' to expected dictionary value type 'any Sendable & Codable'
```
**Location:** `SwiftOfficeAPI.swift` line 108
**Issue:** Dictionary with `Any` values cannot conform to `Sendable & Codable`
**Fix needed:** Use typed data structures or separate encoding

### 2. SwiftOfficeAPI.swift:118 - Missing Enum Case
```
error: type 'SwiftOfficeError' has no member 'excelGenerationFailed'
```
**Location:** `SwiftOfficeAPI.swift` line 118
**Issue:** `SwiftOfficeError` enum missing `excelGenerationFailed` case
**Fix needed:** Add case to `SwiftOfficeError` enum

## Warnings

### 1. Unhandled Files
The following markdown files need to be declared as resources or excluded:
- `EXPERIMENTAL_PLAN.md`
- `EXPERIMENTAL_RESULTS.md`
- `ARCHITECTURE.md`
- `TECHNICAL_DOCUMENTATION.md`

### 2. Test Target Path
```
warning: Source files for target SwiftSlidesTests should be located under 'Tests/SwiftSlidesTests'
```

## Status
- **SwiftSlides module:** ✅ Builds successfully
- **PreviousDesign module:** ❌ Has build errors (not blocking SwiftSlides development)

## Resolution
These issues are documented for future fix. Current focus is on SwiftSlides development.
