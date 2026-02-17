import Testing
import Foundation
@testable import SwiftOfficeValidator

@Suite("PPTX Generator Tests")
struct PPTXGeneratorTests {
    
    @Test("Create PPTX file")
    func testCreatePPTX() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let result = try await bridge.executeScript("pptx", params: [
            "action": "create",
            "title": "SwiftOffice Test Report"
        ])
        
        #expect(result["success"] as? Bool == true)
        print("✅ PPTX created: \(result)")
    }
    
    @Test("Save simple PPTX")
    func testSaveSimplePPTX() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let outputPath = "\(currentPath)/test_output.pptx"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let slidesJSON = """
        [
            {"title": "测试报告", "content": "这是 SwiftOffice 生成的测试报告"},
            {"title": "第二页", "content": "更多内容在这里"}
        ]
        """
        
        let result = try await bridge.executeScript("pptx", params: [
            "action": "save",
            "path": outputPath,
            "slidesJSON": slidesJSON
        ])
        
        #expect(result["success"] as? Bool == true)
        
        let fileExists = FileManager.default.fileExists(atPath: outputPath)
        #expect(fileExists)
        
        print("✅ PPTX saved: \(outputPath)")
        
        if fileExists {
            try FileManager.default.removeItem(atPath: outputPath)
        }
    }
}
