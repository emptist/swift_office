import Foundation
import SwiftSlides

struct TestPresentation: Presentation {
    let title = "SwiftSlides API Test"
    let author: String? = "JK"
    let sections: [any Section] = [
        BasicTypesSection(),
    ]
}

struct BasicTypesSection: Section {
    let title = "Basic Types"
    let slides: [any Slide] = [
        TextSlideDemo(),
        ContentSlideDemo(),
        TableSlideDemo(),
    ]
}

struct TextSlideDemo: Slide, TextStyle {
    let title = "Text Style Demo"
    let contents: Contents = [
        "Content": "This is a simple text slide."
    ]
}

struct ContentSlideDemo: Slide, ContentStyle {
    let title = "Content Style Demo"
    let contents: Contents = [
        "Items": [
            "First item",
            "Second item",
            "Third item"
        ] as [any Sendable]
    ]
}

struct TableSlideDemo: Slide, TableSlideStyle {
    let title = "Table Style Demo"
    let contents: Contents = [
        "Category": ["Type A", "Type B"] as [any Sendable],
        "Policy": ["Policy A", "Policy B"] as [any Sendable]
    ]
}

@main
struct TestRunner {
    static func main() async {
        let presentation = TestPresentation()
        
        do {
            let json = try presentation.toJSON()
            let outputDir = "Outputs"
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/SimpleTest.json"
            try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("✅ JSON saved: \(outputPath)")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
