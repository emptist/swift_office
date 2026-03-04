import Foundation
import SwiftSlides

public struct PresentationRunner {
    public static func generate(_ presentation: any Presentation, outputDir: String = "Outputs", saveJSON: Bool = false) async throws {
        print("========================================")
        print("SwiftSlides - \(presentation.title)")
        print("========================================")
        print("")
        
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
        
        var json: String?
        if saveJSON {
            json = try presentation.toJSON()
            
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/\(presentation.title).json"
            try json!.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("")
            print("✅ JSON saved: \(outputPath)")
        }
        
        print("")
        print("🔄 Generating PPTX...")
        let pptxPath = try await generatePPTX(presentation: presentation, outputDir: outputDir)
        print("✅ PPTX saved: \(pptxPath)")
    }
    
    public static func printSlideTree(_ slide: any Slide, indent: Int) {
        let prefix = String(repeating: " ", count: indent)
        let hasChildren = !slide.fellowSlides.isEmpty
        let icon = hasChildren ? "└─📁" : "└─📄"
        print("\(prefix)\(icon) \(slide.title)")
        
        for child in slide.fellowSlides {
            printSlideTree(child, indent: indent + 4)
        }
    }
    
    public static func generatePPTX(presentation: any Presentation, outputDir: String) async throws -> String {
        let scriptPath = "B_SwiftSlides/Scripts/swiftslides-pptx.js"
        let json = try presentation.toJSON()
        let jsonPath = "\(outputDir)/\(presentation.title).json"
        let pptxPath = "\(outputDir)/\(presentation.title).pptx"
        
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        try json.write(toFile: jsonPath, atomically: true, encoding: .utf8)
        
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
