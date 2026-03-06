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
        
        let json = try presentation.toJSON()
        
        if saveJSON {
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/\(presentation.title).json"
            try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("")
            print("✅ JSON saved: \(outputPath)")
        }
        
        print("")
        print("🔄 Generating PPTX...")
        let pptxPath = try await generatePPTX(json: json, title: presentation.title, outputDir: outputDir)
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
    
    public static func generatePPTX(json: String, title: String, outputDir: String) async throws -> String {
        let scriptPath = "B_SwiftSlides/Scripts/swiftslides-pptx.js"
        let pptxPath = "\(outputDir)/\(title).pptx"
        
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        guard let jsonData = json.data(using: .utf8),
              let jsonObj = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "PPTXGeneration", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        
        let params: [String: Any] = [
            "presentation": jsonObj,
            "outputPath": pptxPath
        ]
        let paramsJSON = try JSONSerialization.data(withJSONObject: params)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/node")
        process.arguments = [scriptPath]
        
        let stdinPipe = Pipe()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardInput = stdinPipe
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        stdinPipe.fileHandleForWriting.write(paramsJSON)
        try stdinPipe.fileHandleForWriting.close()
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        if process.terminationStatus == 0 {
            print(output)
            return pptxPath
        } else {
            print("❌ Node.js error: \(errorOutput)")
            print("❌ Node.js output: \(output)")
            throw NSError(domain: "PPTXGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "PPTX generation failed: \(errorOutput)"])
        }
    }
}
