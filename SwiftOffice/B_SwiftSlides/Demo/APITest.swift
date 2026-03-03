import Foundation
import SwiftSlides

// ============================================
// Protocol Composition Test - All Slide Types
// ============================================

struct TestPresentation: Presentation {
    let title = "SwiftSlides API Test"
    let author: String? = "JK"
    let sections: [any Section] = [
        BasicTypesSection(),
        ChartTypesSection(),
        LayoutTypesSection(),
    ]
}

// MARK: - Sections

struct BasicTypesSection: Section {
    let title = "Basic Types"
    let slides: [any Slide] = [
        CoverSlide(),
        TextSlideDemo(),
        ContentSlideDemo(),
        TableSlideDemo(),
    ]
}

struct ChartTypesSection: Section {
    let title = "Chart Types"
    let slides: [any Slide] = [
        HierarchySlideDemo(),
        CycleFlowSlideDemo(),
        ParetoSlideDemo(),
    ]
}

struct LayoutTypesSection: Section {
    let title = "Layout Types"
    let slides: [any Slide] = [
        TwoColumnSlideDemo(),
        CardSlideDemo(),
        ChapterCoverDemo(),
    ]
}

// MARK: - Basic Types

struct CoverSlide: Slide, CoverStyle {
    let title = "SwiftSlides API Test"
    let contents: Contents = [
        "Subtitle": "Protocol-Based Content Design",
        "Author": "JK",
        "Date": "2024"
    ]
}

struct TextSlideDemo: Slide, TextStyle {
    let title = "Text Style Demo"
    let contents: Contents = [
        "Content": "This is a simple text slide. Users can write any content here in any language they prefer."
    ]
}

struct ContentSlideDemo: Slide, ContentStyle {
    let title = "Content Style Demo"
    let contents: Contents = [
        "Items": [
            "First item in the list",
            "Second item with more details",
            "Third item to show flexibility",
            "Fourth item demonstrates scalability"
        ] as [any Sendable]
    ]
}

struct TableSlideDemo: Slide, TableSlideStyle {
    let title = "Table Style Demo"
    let contents: Contents = [
        "Category": ["First Diagnosis", "Three-Level Rounds", "Difficult Cases", "Critical Values"] as [any Sendable],
        "Policy": ["First Diagnosis Policy", "Three-Level Rounds Policy", "Difficult Case Discussion", "Critical Value Reporting"] as [any Sendable],
        "Status": ["Active", "Active", "Active", "Active"] as [any Sendable]
    ]
}

// MARK: - Chart Types

struct HierarchySlideDemo: Slide, HierarchyStyle {
    let title = "Hierarchy Style Demo"
    let contents: Contents = [
        "levels": [
            ["Medical Quality Management System"] as [String],
            ["Top Design", "Middle Management"] as [String],
            ["Quality Policy", "Quality System", "Quality Control", "Quality Improvement"] as [String]
        ] as [any Sendable]
    ]
}

struct CycleFlowSlideDemo: Slide, CycleFlowStyle {
    let title = "Cycle Flow Style Demo"
    let contents: Contents = [
        "items": [
            ["id": "P", "title": "PLAN", "description": "Plan the process"] as [String: any Sendable],
            ["id": "D", "title": "DO", "description": "Execute the plan"] as [String: any Sendable],
            ["id": "C", "title": "CHECK", "description": "Check the results"] as [String: any Sendable],
            ["id": "A", "title": "ACT", "description": "Act on the results"] as [String: any Sendable]
        ] as [any Sendable]
    ]
}

struct ParetoSlideDemo: Slide, ParetoStyle {
    let title = "Pareto Style Demo"
    let contents: Contents = [
        "items": [
            ["label": "Category A", "value": 45] as [String: any Sendable],
            ["label": "Category B", "value": 25] as [String: any Sendable],
            ["label": "Category C", "value": 15] as [String: any Sendable],
            ["label": "Category D", "value": 10] as [String: any Sendable],
            ["label": "Others", "value": 5] as [String: any Sendable]
        ] as [any Sendable]
    ]
}

// MARK: - Layout Types

struct TwoColumnSlideDemo: Slide, TwoColumnStyle {
    let title = "Two Column Style Demo"
    let contents: Contents = [
        "left": [
            "Advantage 1: Easy to use",
            "Advantage 2: Flexible design",
            "Advantage 3: Type safe"
        ] as [any Sendable],
        "right": [
            "Consideration 1: Learning curve",
            "Consideration 2: Initial setup",
            "Consideration 3: Documentation"
        ] as [any Sendable]
    ]
}

struct CardSlideDemo: Slide, CardStyle {
    let title = "Card Style Demo"
    let contents: Contents = [
        "cards": [
            ["title": "Feature 1", "content": "Protocol-based design for maximum flexibility"] as [String: any Sendable],
            ["title": "Feature 2", "content": "Type-safe content handling with dictionary support"] as [String: any Sendable],
            ["title": "Feature 3", "content": "Language-agnostic user content"] as [String: any Sendable],
            ["title": "Feature 4", "content": "Simple title + contents API"] as [String: any Sendable]
        ] as [any Sendable]
    ]
}

struct ChapterCoverDemo: Slide, CoverStyle {
    let title = "Chapter Cover Demo"
    let contents: Contents = [
        "ChapterNumber": "1",
        "Subtitle": "This is a chapter cover slide"
    ]
}

// MARK: - Runner

@main
struct TestRunner {
    static func main() async {
        print("========================================")
        print("SwiftSlides API Test - All Slide Types")
        print("========================================")
        print("")
        
        let presentation = TestPresentation()
        
        print("📊 Presentation: \(presentation.title)")
        print("👤 Author: \(presentation.author ?? "N/A")")
        print("📁 Sections: \(presentation.sections.count)")
        print("")
        
        for section in presentation.sections {
            print("📂 \(section.title)")
            for slide in section.slides {
                printSlideTree(slide, indent: 2)
            }
        }
        
        print("")
        print("📄 Total slides: \(presentation.allSlides().count)")
        
        do {
            let json = try presentation.toJSON()
            
            let outputDir = "Outputs"
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/\(presentation.title).json"
            try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("")
            print("✅ JSON saved: \(outputPath)")
            
            print("")
            print("🔄 Generating PPTX...")
            let pptxPath = try await generatePPTX(json: json, outputDir: outputDir, presentationTitle: presentation.title)
            print("✅ PPTX saved: \(pptxPath)")
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func printSlideTree(_ slide: any Slide, indent: Int) {
        let prefix = String(repeating: " ", count: indent)
        let hasChildren = !slide.fellowSlides.isEmpty
        let icon = hasChildren ? "└─📁" : "└─📄"
        print("\(prefix)\(icon) \(slide.title)")
        
        for child in slide.fellowSlides {
            printSlideTree(child, indent: indent + 4)
        }
    }
    
    static func generatePPTX(json: String, outputDir: String, presentationTitle: String) async throws -> String {
        let scriptPath = "B_SwiftSlides/Scripts/swiftslides-pptx.js"
        let jsonPath = "\(outputDir)/\(presentationTitle).json"
        let pptxPath = "\(outputDir)/\(presentationTitle).pptx"
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/node")
        process.arguments = [scriptPath, jsonPath, pptxPath]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            return pptxPath
        } else {
            throw NSError(domain: "PPTXGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "PPTX generation failed"])
        }
    }
}
