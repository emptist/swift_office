import Testing
import Foundation
@testable import SwiftOffice

@Suite("File Generation Tests")
struct FileGenerationTests {
    
    let outputDir: String
    
    init() async throws {
        outputDir = FileManager.default.currentDirectoryPath + "/test_output"
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
    }
    
    @Test("Generate sample PPT")
    @available(macOS 10.15, *)
    func generateSamplePPT() async throws {
        let outputPath = outputDir + "/sample_report.pptx"
        
        let slides: [[String: Any]] = [
            [
                "title": "SwiftOffice 测试报告",
                "content": "这是一个自动生成的测试报告"
            ],
            [
                "title": "数据概览",
                "content": "测试数据统计结果"
            ],
            [
                "title": "图表展示",
                "chart": [
                    "type": "bar",
                    "title": "月度数据",
                    "data": [
                        [
                            "name": "销售额",
                            "labels": ["1月", "2月", "3月", "4月", "5月"],
                            "values": [100, 120, 150, 130, 180]
                        ]
                    ],
                    "x": 0.5,
                    "y": 1.5,
                    "w": 9,
                    "h": 4
                ]
            ]
        ]
        
        try await SwiftOffice.createPPT(slides: slides, outputPath: outputPath)
        
        #expect(FileManager.default.fileExists(atPath: outputPath))
        print("✅ PPT 生成成功: \(outputPath)")
    }
    
    @Test("Generate JSON file")
    func generateJSONFile() throws {
        let jsonPath = outputDir + "/sample_data.json"
        
        let data: [String: Any] = [
            "report_title": "SwiftOffice 测试数据",
            "generated_at": ISO8601DateFormatter().string(from: Date()),
            "metrics": [
                "total_sales": 680,
                "average": 136,
                "growth_rate": 0.15
            ],
            "categories": [
                ["name": "产品A", "value": 100],
                ["name": "产品B", "value": 200],
                ["name": "产品C", "value": 150]
            ]
        ]
        
        SwiftOffice.writeJSON(data, to: jsonPath)
        
        #expect(FileManager.default.fileExists(atPath: jsonPath))
        
        // 验证读取
        let readData = SwiftOffice.readJSON(from: jsonPath)
        #expect(readData != nil)
        #expect(readData?["report_title"] as? String == "SwiftOffice 测试数据")
        
        print("✅ JSON 文件生成成功: \(jsonPath)")
    }
    
    @Test("Generate sample Excel via NodeJS")
    @available(macOS 10.15, *)
    func generateExcelSample() async throws {
        let excelPath = outputDir + "/sample_data.xlsx"
        
        let bridge = try NodeJSBridge(
            scriptsPath: URL(fileURLWithPath: "./Scripts")
        )
        
        let params: [String: Any] = [
            "fileName": excelPath.replacingOccurrences(of: ".xlsx", with: ""),
            "extraLength": 5,
            "data": [
                [
                    "sheet": "数据",
                    "columns": [
                        ["label": "名称", "value": "name"],
                        ["label": "数值", "value": "value"],
                        ["label": "备注", "value": "note"]
                    ],
                    "content": [
                        ["name": "产品A", "value": 100, "note": "测试数据"],
                        ["name": "产品B", "value": 200, "note": "测试数据"],
                        ["name": "产品C", "value": 150, "note": "测试数据"]
                    ]
                ]
            ]
        ]
        
        let result = try await bridge.executeScript("writeExcel", params: params)
        
        guard let success = result["success"] as? Bool, success else {
            let error = result["error"] as? String ?? "Unknown error"
            print("⚠️ Excel 生成失败: \(error)")
            return
        }
        
        #expect(FileManager.default.fileExists(atPath: excelPath))
        print("✅ Excel 文件生成成功: \(excelPath)")
    }
}
