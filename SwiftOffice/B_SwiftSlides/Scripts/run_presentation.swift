#!/usr/bin/env swift

import Foundation
import SwiftSlides
import Runner

if CommandLine.arguments.count < 2 {
    print("Usage: swift run_presentation.swift <presentation_file.swift>")
    print("\nExample:")
    print("  swift run_presentation.swift my_presentation.swift")
    exit(1)
}

let filePath = CommandLine.arguments[1]
let fileURL = URL(fileURLWithPath: filePath)

guard FileManager.default.fileExists(atPath: filePath) else {
    print("❌ Error: File not found: \(filePath)")
    exit(1)
}

print("📂 Loading presentation from: \(filePath)")
print("")

// Read the Swift file content
guard let sourceCode = try? String(contentsOf: fileURL, encoding: .utf8) else {
    print("❌ Error: Cannot read file")
    exit(1)
}

// Extract presentation type name
let typeNamePattern = #"struct\s+(\w+).*Presentation"#
guard let regex = try? NSRegularExpression(pattern: typeNamePattern),
      let match = regex.firstMatch(in: sourceCode, range: NSRange(sourceCode.startIndex..., in: sourceCode)),
      let typeNameRange = Range(match.range(at: 1), in: sourceCode) else {
    print("❌ Error: Cannot find Presentation struct in file")
    exit(1)
}

let typeName = String(sourceCode[typeNameRange])
print("📊 Found presentation type: \(typeName)")
print("")

// Create a temporary Swift file with the presentation code and runner
let tempDir = FileManager.default.temporaryDirectory
let tempFile = tempDir.appendingPathComponent("temp_presentation_\(UUID().uuidString).swift")

let runnerCode = """
import Foundation
import SwiftSlides
import Runner

\(sourceCode)

@main
struct UniversalRunner {
    static func main() async {
        let presentation = \(typeName)()
        try? await PresentationRunner.generate(presentation, saveJSON: false)
    }
}
"""

try runnerCode.write(to: tempFile, atomically: true, encoding: .utf8)

print("🔄 Running presentation...")
print("")

// Run the temporary file
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
process.arguments = [tempFile.path]

process.standardOutput = FileHandle.standardOutput
process.standardError = FileHandle.standardError

try process.run()
process.waitUntilExit()

// Clean up
try? FileManager.default.removeItem(at: tempFile)

exit(process.terminationStatus)
