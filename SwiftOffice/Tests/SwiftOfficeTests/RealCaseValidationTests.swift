import Testing
import Foundation
@testable import SwiftOffice

@Suite("真实案例验证测试")
struct RealCaseValidationTests {
    
    // ========================================
    // 测试 1: 设置驱动
    // ========================================
    
    @Test("设置驱动: 项目设置决定报告结构")
    func testSettingsDriven() async throws {
        // 模拟项目设置
        struct 项目设置 {
            nonisolated(unsafe) static var _cso: [String: Any]?
            
            static var cso: [String: Any] {
                if _cso == nil {
                    _cso = [
                        "一级指标设置": [
                            "医疗质量": ["权重": 0.4, "排序": 1],
                            "运营效率": ["权重": 0.3, "排序": 2],
                            "可持续发展": ["权重": 0.3, "排序": 3]
                        ],
                        "科室设置": [
                            "内科": ["排序": 1],
                            "外科": ["排序": 2],
                            "妇产科": ["排序": 3]
                        ],
                        "年份设置": ["2021", "2022", "2023"]
                    ]
                }
                return _cso!
            }
            
            static var 一级指标设置: [String: [String: Any]] {
                (cso["一级指标设置"] as? [String: [String: Any]]) ?? [:]
            }
            
            static var 科室设置: [String: [String: Any]] {
                (cso["科室设置"] as? [String: [String: Any]]) ?? [:]
            }
            
            static var 年份设置: [String] {
                (cso["年份设置"] as? [String]) ?? []
            }
        }
        
        // 验证设置驱动报告结构
        let indicators = 项目设置.一级指标设置
        let departments = 项目设置.科室设置
        let years = 项目设置.年份设置
        
        #expect(indicators.count == 3)
        #expect(departments.count == 3)
        #expect(years.count == 3)
        
        // 验证权重
        let weights = indicators.map { $0.value["权重"] as? Double ?? 0 }
        #expect(weights.reduce(0, +) == 1.0)  // 权重总和为 1
    }
    
    // ========================================
    // 测试 2: JSON 证据留存
    // ========================================
    
    @Test("JSON 证据留存: 每一步生成 JSON")
    func testJSONEvidence() async throws {
        let outputDir = "/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/evidence"
        
        // 创建输出目录
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        // 步骤 1: 原始数据
        let rawData: [String: Any] = [
            "科室": "内科",
            "指标": "治愈好转率",
            "年份": "2023",
            "值": 95.5
        ]
        let rawJSON = try JSONSerialization.data(withJSONObject: rawData, options: .prettyPrinted)
        try rawJSON.write(to: URL(fileURLWithPath: "\(outputDir)/01_raw_data.json"))
        
        // 步骤 2: 计算后数据
        let calculatedData: [String: Any] = [
            "科室": "内科",
            "指标": "治愈好转率",
            "年份": "2023",
            "值": 95.5,
            "同比变化": 2.3,
            "排名": 1
        ]
        let calculatedJSON = try JSONSerialization.data(withJSONObject: calculatedData, options: .prettyPrinted)
        try calculatedJSON.write(to: URL(fileURLWithPath: "\(outputDir)/02_calculated_data.json"))
        
        // 步骤 3: 图表数据
        let chartData: [String: Any] = [
            "type": "bar",
            "title": "内科治愈好转率",
            "categories": ["2021", "2022", "2023"],
            "series": [
                ["name": "治愈好转率", "values": [93.2, 94.1, 95.5]]
            ]
        ]
        let chartJSON = try JSONSerialization.data(withJSONObject: chartData, options: .prettyPrinted)
        try chartJSON.write(to: URL(fileURLWithPath: "\(outputDir)/03_chart_data.json"))
        
        // 验证文件存在
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/01_raw_data.json"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/02_calculated_data.json"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/03_chart_data.json"))
    }
    
    // ========================================
    // 测试 3: 多版本输出 (搭积木式组合)
    // ========================================
    
    @Test("多版本输出: 搭积木式组合不同章节模板")
    func testMultiVersionOutput() async throws {
        // 同一数据源
        struct 报告数据 {
            nonisolated(unsafe) static let data: [String: Any] = [
                "科室": ["内科", "外科", "妇产科"],
                "指标": ["治愈好转率", "死亡率", "平均住院日"],
                "值": [
                    "内科_治愈好转率": 95.5,
                    "内科_死亡率": 0.3,
                    "内科_平均住院日": 8.5,
                    "外科_治愈好转率": 92.3,
                    "外科_死亡率": 0.5,
                    "外科_平均住院日": 9.0
                ]
            ]
        }
        
        // 章节积木 (可复用的章节组件)
        enum 章节积木 {
            case 扉页(String)
            case 目录
            case 总体概述
            case 科室对比
            case 趋势分析
            case 对标分析
            case 问题清单
            case 结论建议
            case 详细数据表
            case 简化摘要
            
            func toSlides() -> [[String: Any]] {
                switch self {
                case .扉页(let title):
                    return [["type": "title", "text": title]]
                case .目录:
                    return [["type": "toc"]]
                case .总体概述:
                    return [
                        ["type": "sectionTitle", "text": "总体概述"],
                        ["type": "text", "content": "本年度医疗质量稳步提升..."]
                    ]
                case .科室对比:
                    return [
                        ["type": "sectionTitle", "text": "科室对比"],
                        ["type": "radarChart", "title": "科室综合评价"]
                    ]
                case .趋势分析:
                    return [
                        ["type": "sectionTitle", "text": "趋势分析"],
                        ["type": "lineChart", "title": "年度趋势"]
                    ]
                case .对标分析:
                    return [
                        ["type": "sectionTitle", "text": "对标分析"],
                        ["type": "barChart", "title": "与标杆对比"]
                    ]
                case .问题清单:
                    return [
                        ["type": "sectionTitle", "text": "问题清单"],
                        ["type": "table", "title": "待改进项"]
                    ]
                case .结论建议:
                    return [
                        ["type": "sectionTitle", "text": "结论建议"],
                        ["type": "text", "content": "建议继续加强..."]
                    ]
                case .详细数据表:
                    return [
                        ["type": "sectionTitle", "text": "详细数据"],
                        ["type": "table", "title": "完整指标数据"]
                    ]
                case .简化摘要:
                    return [
                        ["type": "sectionTitle", "text": "摘要"],
                        ["type": "text", "content": "关键指标摘要..."]
                    ]
                }
            }
        }
        
        // 报告版本定义 (搭积木组合)
        struct 报告版本 {
            let name: String
            let description: String
            let blocks: [章节积木]
            
            func generate() -> [[String: Any]] {
                var slides: [[String: Any]] = []
                for block in blocks {
                    slides.append(contentsOf: block.toSlides())
                }
                return slides
            }
        }
        
        // 版本 1: 简化版 (最少章节)
        let 简化版 = 报告版本(
            name: "简化版",
            description: "仅包含关键信息，适合快速浏览",
            blocks: [
                .扉页("医院质量报告 - 简化版"),
                .简化摘要,
                .结论建议
            ]
        )
        
        // 版本 2: 院内报告 (详细数据)
        let 院内报告 = 报告版本(
            name: "院内报告",
            description: "包含详细数据，供内部使用",
            blocks: [
                .扉页("医院质量报告 - 院内版"),
                .目录,
                .总体概述,
                .科室对比,
                .趋势分析,
                .问题清单,
                .详细数据表,
                .结论建议
            ]
        )
        
        // 版本 3: 汇报版 (适合向上级汇报)
        let 汇报版 = 报告版本(
            name: "汇报版",
            description: "适合向上级汇报，重点突出",
            blocks: [
                .扉页("医院质量报告 - 汇报版"),
                .总体概述,
                .科室对比,
                .结论建议
            ]
        )
        
        // 版本 4: 对标版 (与标杆对比)
        let 对标版 = 报告版本(
            name: "对标版",
            description: "与标杆医院对比分析",
            blocks: [
                .扉页("医院质量报告 - 对标版"),
                .总体概述,
                .对标分析,
                .问题清单,
                .结论建议
            ]
        )
        
        // 生成多套报告
        let versions = [简化版, 院内报告, 汇报版, 对标版]
        
        let outputDir = "/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/multi_version"
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        var generatedFiles: [String] = []
        
        for version in versions {
            let slides = version.generate()
            
            // 保存为 JSON (实际会生成 PPTX)
            let json = try JSONSerialization.data(
                withJSONObject: [
                    "version": version.name,
                    "description": version.description,
                    "slideCount": slides.count,
                    "slides": slides
                ],
                options: .prettyPrinted
            )
            let filename = "\(outputDir)/\(version.name).json"
            try json.write(to: URL(fileURLWithPath: filename))
            generatedFiles.append(filename)
        }
        
        // 验证生成了 4 套不同结构的报告
        #expect(generatedFiles.count == 4)
        
        // 验证章节数量不同
        let 简化版Slides = 简化版.generate()
        let 院内报告Slides = 院内报告.generate()
        let 汇报版Slides = 汇报版.generate()
        let 对标版Slides = 对标版.generate()
        
        #expect(简化版Slides.count < 汇报版Slides.count)
        #expect(汇报版Slides.count < 院内报告Slides.count)
        #expect(院内报告Slides.count > 对标版Slides.count)
        
        // 验证文件存在
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/简化版.json"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/院内报告.json"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/汇报版.json"))
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/对标版.json"))
    }
    
    // ========================================
    // 测试 4: 章节结构管理
    // ========================================
    
    @Test("章节结构管理: PPT 章节自动生成")
    func testSectionManagement() async throws {
        // 章节协议
        protocol PPTSection {
            var title: String { get }
            var order: Int { get }
            func generateContent() -> [[String: Any]]
        }
        
        // 扉页章节
        struct 扉页Section: PPTSection {
            let title = "扉页"
            let order = 0
            func generateContent() -> [[String: Any]] {
                [["type": "title", "text": "医院质量报告"]]
            }
        }
        
        // 目录章节
        struct 目录Section: PPTSection {
            let title = "目录"
            let order = 1
            func generateContent() -> [[String: Any]] {
                [["type": "toc", "items": ["医疗质量", "运营效率", "可持续发展"]]]
            }
        }
        
        // 数据章节
        struct 数据Section: PPTSection {
            let title: String
            let order: Int
            let data: [String: Any]
            
            func generateContent() -> [[String: Any]] {
                [
                    ["type": "sectionTitle", "text": title],
                    ["type": "table", "data": data]
                ]
            }
        }
        
        // 构建章节列表
        let sections: [any PPTSection] = [
            扉页Section(),
            目录Section(),
            数据Section(title: "医疗质量", order: 2, data: ["治愈好转率": 95.5]),
            数据Section(title: "运营效率", order: 3, data: ["平均住院日": 8.5]),
            数据Section(title: "可持续发展", order: 4, data: ["科研经费": 1000])
        ]
        
        // 按顺序生成 PPT 内容
        let sortedSections = sections.sorted { $0.order < $1.order }
        var pptContent: [[String: Any]] = []
        
        for section in sortedSections {
            pptContent.append(["section": section.title])
            pptContent.append(contentsOf: section.generateContent())
        }
        
        // 验证
        #expect(pptContent.count > 0)
        #expect(pptContent.first?["section"] as? String == "扉页")
    }
    
    // ========================================
    // 测试 5: 多种 PPT 内容形式
    // ========================================
    
    @Test("多种 PPT 内容形式: 表格、图表、文本")
    func testMultiplePPTContentTypes() async throws {
        // 内容类型协议
        protocol PPTContent {
            var type: String { get }
            func toSlideData() -> [String: Any]
        }
        
        // 表格内容
        struct TableContent: PPTContent {
            let type = "table"
            let title: String
            let headers: [String]
            let rows: [[Any]]
            
            func toSlideData() -> [String: Any] {
                [
                    "type": "table",
                    "title": title,
                    "headers": headers,
                    "rows": rows
                ]
            }
        }
        
        // 柱状图内容
        struct BarChartContent: PPTContent {
            let type = "barChart"
            let title: String
            let categories: [String]
            let values: [Double]
            
            func toSlideData() -> [String: Any] {
                [
                    "type": "barChart",
                    "title": title,
                    "categories": categories,
                    "values": values
                ]
            }
        }
        
        // 雷达图内容
        struct RadarChartContent: PPTContent {
            let type = "radarChart"
            let title: String
            let indicators: [String]
            let values: [Double]
            
            func toSlideData() -> [String: Any] {
                [
                    "type": "radarChart",
                    "title": title,
                    "indicators": indicators,
                    "values": values
                ]
            }
        }
        
        // 文本内容
        struct TextContent: PPTContent {
            let type = "text"
            let title: String
            let content: String
            
            func toSlideData() -> [String: Any] {
                [
                    "type": "text",
                    "title": title,
                    "content": content
                ]
            }
        }
        
        // 构建多种内容
        let contents: [any PPTContent] = [
            TableContent(
                title: "科室指标汇总",
                headers: ["科室", "指标", "值"],
                rows: [["内科", "治愈好转率", 95.5], ["外科", "治愈好转率", 92.3]]
            ),
            BarChartContent(
                title: "治愈好转率对比",
                categories: ["内科", "外科", "妇产科"],
                values: [95.5, 92.3, 97.1]
            ),
            RadarChartContent(
                title: "综合评价",
                indicators: ["医疗质量", "运营效率", "可持续发展"],
                values: [90, 85, 80]
            ),
            TextContent(
                title: "分析结论",
                content: "本年度医疗质量稳步提升，治愈好转率平均达到 95%。"
            )
        ]
        
        // 生成 PPT 数据
        var slides: [[String: Any]] = []
        for content in contents {
            slides.append(content.toSlideData())
        }
        
        // 验证
        #expect(slides.count == 4)
        #expect(slides[0]["type"] as? String == "table")
        #expect(slides[1]["type"] as? String == "barChart")
        #expect(slides[2]["type"] as? String == "radarChart")
        #expect(slides[3]["type"] as? String == "text")
    }
    
    // ========================================
    // 测试 6: 完整流程验证
    // ========================================
    
    @Test("完整流程: 设置 → 数据 → JSON → PPT")
    func testCompleteFlow() async throws {
        // 1. 设置驱动
        struct 报告设置 {
            static let 一级指标 = ["医疗质量", "运营效率"]
            static let 年份 = ["2022", "2023"]
        }
        
        // 2. 数据准备
        struct 报告数据 {
            nonisolated(unsafe) static var _data: [String: Any]?
            
            static var data: [String: Any] {
                if _data == nil {
                    _data = [
                        "医疗质量": [
                            "治愈好转率": ["2022": 93.2, "2023": 95.5],
                            "死亡率": ["2022": 0.5, "2023": 0.3]
                        ],
                        "运营效率": [
                            "平均住院日": ["2022": 9.0, "2023": 8.5],
                            "床位使用率": ["2022": 85.0, "2023": 88.0]
                        ]
                    ]
                }
                return _data!
            }
        }
        
        // 3. JSON 证据
        let outputDir = "/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/complete"
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        let json = try JSONSerialization.data(
            withJSONObject: 报告数据.data,
            options: .prettyPrinted
        )
        try json.write(to: URL(fileURLWithPath: "\(outputDir)/report_data.json"))
        
        // 4. PPT 生成
        var slides: [[String: Any]] = []
        
        // 扉页
        slides.append(["type": "title", "text": "医院质量报告 2023"])
        
        // 各指标章节
        for indicator in 报告设置.一级指标 {
            slides.append(["type": "sectionTitle", "text": indicator])
            
            if let indicatorData = 报告数据.data[indicator] as? [String: [String: Double]] {
                for (metric, values) in indicatorData {
                    slides.append([
                        "type": "barChart",
                        "title": metric,
                        "categories": 报告设置.年份,
                        "values": 报告设置.年份.map { values[$0] ?? 0 }
                    ])
                }
            }
        }
        
        // 验证
        #expect(FileManager.default.fileExists(atPath: "\(outputDir)/report_data.json"))
        #expect(slides.count >= 5)  // 1 扉页 + 2 章节标题 + 4 图表
    }
}
