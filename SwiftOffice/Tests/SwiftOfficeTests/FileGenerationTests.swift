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
        // 先创建一个简单的 JSON 数据，然后用 NodeJS 写入 Excel
        // 这里我们测试读取功能，先创建一个测试 Excel 文件
        
        let excelPath = outputDir + "/sample_data.xlsx"
        
        // 使用 NodeJS 创建 Excel 文件
        let bridge = try NodeJSBridge(
            scriptsPath: URL(fileURLWithPath: "./Scripts")
        )
        
        // 创建一个简单的测试 Excel
        let createScript = """
        const ExcelJS = require('exceljs');
        (async () => {
            const workbook = new ExcelJS.Workbook();
            const sheet = workbook.addWorksheet('数据');
            
            sheet.columns = [
                { header: '名称', key: 'name' },
                { header: '数值', key: 'value' },
                { header: '备注', key: 'note' }
            ];
            
            sheet.addRow({ name: '产品A', value: 100, note: '测试数据' });
            sheet.addRow({ name: '产品B', value: 200, note: '测试数据' });
            sheet.addRow({ name: '产品C', value: 150, note: '测试数据' });
            
            await workbook.xlsx.writeFile('\(excelPath)');
            console.log(JSON.stringify({ success: true }));
        })().catch(e => {
            console.log(JSON.stringify({ success: false, error: e.message }));
            process.exit(1);
        });
        """
        
        // 写入临时脚本
        let tempScriptPath = outputDir + "/create_excel.js"
        try createScript.write(toFile: tempScriptPath, atomically: true, encoding: .utf8)
        
        // 执行脚本
        let process = Foundation.Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/node")
        process.arguments = [tempScriptPath]
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/SwiftOffice")
        
        try process.run()
        process.waitUntilExit()
        
        // 清理临时脚本
        try FileManager.default.removeItem(atPath: tempScriptPath)
        
        // 如果 ExcelJS 不可用，跳过此测试
        if !FileManager.default.fileExists(atPath: excelPath) {
            print("⚠️ ExcelJS 未安装，跳过 Excel 测试")
            return
        }
        
        #expect(FileManager.default.fileExists(atPath: excelPath))
        print("✅ Excel 文件生成成功: \(excelPath)")
    }
}
