import Testing
import Foundation
@testable import SwiftOfficeValidator

@Suite("Radar Chart Tests")
struct RadarChartTests {
    
    @Test("Generate radar chart PPT")
    func testGenerateRadarChartPPT() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let outputPath = "\(currentPath)/radar_test.pptx"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let slidesJSON = """
        [
            {
                "title": "科室绩效雷达图报告",
                "chart": {
                    "type": "radar",
                    "title": "内科绩效",
                    "data": [
                        {
                            "name": "内科",
                            "labels": ["医疗质量", "运营效率", "持续发展", "满意度", "科研能力"],
                            "values": [85, 78, 92, 88, 75]
                        }
                    ],
                    "x": 0.5,
                    "y": 1.0,
                    "w": 9,
                    "h": 5
                }
            },
            {
                "title": "外科绩效",
                "chart": {
                    "type": "radar",
                    "title": "外科绩效",
                    "data": [
                        {
                            "name": "外科",
                            "labels": ["医疗质量", "运营效率", "持续发展", "满意度", "科研能力"],
                            "values": [90, 85, 80, 82, 95]
                        }
                    ],
                    "x": 0.5,
                    "y": 1.0,
                    "w": 9,
                    "h": 5
                }
            }
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
        
        print("✅ Radar chart PPT generated: \(outputPath)")
        
        if fileExists {
            try FileManager.default.removeItem(atPath: outputPath)
        }
    }
    
    @Test("Generate multi-department comparison radar chart")
    func testMultiDepartmentRadarChart() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let outputPath = "\(currentPath)/multi_radar_test.pptx"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let slidesJSON = """
        [
            {
                "title": "多科室绩效对比",
                "chart": {
                    "type": "radar",
                    "title": "科室对比",
                    "data": [
                        {
                            "name": "内科",
                            "labels": ["医疗质量", "运营效率", "持续发展", "满意度"],
                            "values": [85, 78, 92, 88]
                        },
                        {
                            "name": "外科",
                            "labels": ["医疗质量", "运营效率", "持续发展", "满意度"],
                            "values": [90, 85, 80, 82]
                        },
                        {
                            "name": "妇产科",
                            "labels": ["医疗质量", "运营效率", "持续发展", "满意度"],
                            "values": [88, 90, 85, 95]
                        }
                    ],
                    "x": 0.5,
                    "y": 1.0,
                    "w": 9,
                    "h": 5
                }
            }
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
        
        print("✅ Multi-department radar chart generated: \(outputPath)")
        
        if fileExists {
            try FileManager.default.removeItem(atPath: outputPath)
        }
    }
}
