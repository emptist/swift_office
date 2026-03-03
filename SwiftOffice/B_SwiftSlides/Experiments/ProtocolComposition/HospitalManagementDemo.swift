import Foundation

// ============================================
// Hospital Management Demo - Protocol Composition Example
// ============================================
//
// 此文件展示如何使用 Protocol Composition 模式创建医院管理演示文稿。
//
// 这是完整的独立脚本，演示了：
// - 如何定义 Presentation、Section、Slide 协议
// - 如何使用样式协议（封面样式、章节样式、内容样式）
// - 如何组织多章节演示文稿
// - 如何生成 PPTX 文件
//
// 使用方式：
//   swift HospitalManagementDemo.swift
//
// 注意：这是实验性代码，用于探索 Protocol Composition 模式。
//
// - Author: Kimi-k2.5
// - Version: 0.1.0 (Experimental)
// - Date: 2026-03-03
// ============================================

// MARK: - Core Protocols (from ScriptModeSupport.swift)

/// 幻灯片基础协议
public protocol Slide {
    var id: UUID { get }
    var title: String { get }
}

public extension Slide {
    var id: UUID { UUID() }
}

/// 章节协议
public protocol Section {
    var id: UUID { get }
    var title: String { get }
    var slides: [Slide] { get }
}

public extension Section {
    var id: UUID { UUID() }
}

/// 演示文稿协议
public protocol Presentation {
    var id: UUID { get }
    var title: String { get }
    var sections: [Section] { get }
}

public extension Presentation {
    var id: UUID { UUID() }
    
    func generatePPTX(outputPath: String) async throws {
        let generator = PPTXGenerator()
        try await generator.generate(presentation: self, outputPath: outputPath)
    }
}

// MARK: - Style Protocols

public protocol 封面样式: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

public protocol 章节样式: Slide {
    var chapterNumber: Int? { get }
}

public protocol 内容样式: Slide {
    var items: [String] { get }
}

// MARK: - PPTX Generator

public struct PPTXGenerator {
    public init() {}
    
    public func generate(presentation: Presentation, outputPath: String) async throws {
        let json = try encodeToJSON(presentation: presentation)
        let script = createNodeScript(json: json, outputPath: outputPath)
        try await executeNodeScript(script: script)
    }
    
    private func encodeToJSON(presentation: Presentation) throws -> String {
        var slidesData: [[String: Any]] = []
        
        slidesData.append([
            "type": "title",
            "title": presentation.title
        ])
        
        for section in presentation.sections {
            for slide in section.slides {
                var slideData: [String: Any] = [
                    "type": getSlideType(slide),
                    "title": slide.title
                ]
                
                if let cover = slide as? 封面样式 {
                    slideData["subtitle"] = cover.subtitle
                    slideData["author"] = cover.author
                }
                
                if let chapter = slide as? 章节样式 {
                    slideData["chapterNumber"] = chapter.chapterNumber
                }
                
                if let content = slide as? 内容样式 {
                    slideData["items"] = content.items
                }
                
                slidesData.append(slideData)
            }
        }
        
        let dict: [String: Any] = [
            "title": presentation.title,
            "slides": slidesData
        ]
        
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    private func getSlideType(_ slide: Slide) -> String {
        if slide is 封面样式 { return "cover" }
        if slide is 章节样式 { return "chapter" }
        if slide is 内容样式 { return "content" }
        return "default"
    }
    
    private func createNodeScript(json: String, outputPath: String) -> String {
        // 获取 SwiftOffice 根目录的 node_modules 路径
        var nodeModulesPath = outputPath
        if let bSwiftSlidesRange = nodeModulesPath.range(of: "/B_SwiftSlides/") {
            nodeModulesPath = String(nodeModulesPath[..<bSwiftSlidesRange.lowerBound]) + "/node_modules"
        }
        
        return """
        const nodeModulesPath = '\(nodeModulesPath)';
        module.paths.unshift(nodeModulesPath);
        const PptxGenJS = require('pptxgenjs');
        
        const data = \(json);
        const pres = new PptxGenJS();
        
        pres.title = data.title;
        pres.author = 'SwiftSlides';
        
        data.slides.forEach(slide => {
            const s = pres.addSlide();
            
            if (slide.type === 'cover') {
                s.addText(slide.title, { 
                    x: 1, y: 2, w: 8, h: 1, 
                    fontSize: 44, bold: true, align: 'center' 
                });
                if (slide.subtitle) {
                    s.addText(slide.subtitle, { 
                        x: 1, y: 3.5, w: 8, h: 0.5, 
                        fontSize: 24, align: 'center' 
                    });
                }
            } else if (slide.type === 'chapter') {
                if (slide.chapterNumber) {
                    s.addText('第' + slide.chapterNumber + '章', { 
                        x: 1, y: 2, w: 8, h: 0.5, 
                        fontSize: 24, color: '666666', align: 'center' 
                    });
                }
                s.addText(slide.title, { 
                    x: 1, y: 3, w: 8, h: 1, 
                    fontSize: 40, bold: true, align: 'center' 
                });
            } else {
                s.addText(slide.title, { 
                    x: 0.5, y: 0.5, w: 9, h: 0.8, 
                    fontSize: 32, bold: true 
                });
                
                if (slide.items) {
                    slide.items.forEach((item, index) => {
                        s.addText('• ' + item, { 
                            x: 1, y: 1.8 + index * 0.6, w: 8, h: 0.5, 
                            fontSize: 20 
                        });
                    });
                }
            }
        });
        
        pres.writeFile({ fileName: '\(outputPath)' })
            .then(() => console.log('✅ PPTX generated: \(outputPath)'))
            .catch(err => {
                console.error('❌ Error:', err.message);
                process.exit(1);
            });
        """
    }
    
    private func executeNodeScript(script: String) async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let scriptPath = tempDir.appendingPathComponent("pptx_\(UUID().uuidString).js")
        
        try script.write(to: scriptPath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: scriptPath) }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["node", scriptPath.path]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
            print(output)
        }
        
        if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
            print(error)
        }
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "PPTXGenerator", code: Int(process.terminationStatus))
        }
    }
}

// MARK: - Presentation Definition

/// 医院管理总览演示文稿
struct 医院管理总览: Presentation {
    var title = "医院管理总览（完整版）"
    var author: String? = "医院管理部"
    
    var sections: [Section] = [
        封面章节(),
        历史沿革章节(),
        现状分析章节(),
        未来展望章节(),
    ]
}

// MARK: - Section Definitions

struct 封面章节: Section {
    var title = "封面"
    var slides: [Slide] = [
        封面页(),
    ]
}

struct 历史沿革章节: Section {
    var title = "历史沿革"
    var slides: [Slide] = [
        历史沿革章节首页(),
        古代医院(),
        近代医院(),
        现代医院(),
    ]
}

struct 现状分析章节: Section {
    var title = "现状分析"
    var slides: [Slide] = [
        现状分析章节首页(),
        床位使用率(),
        患者满意度(),
        医疗质量指标(),
    ]
}

struct 未来展望章节: Section {
    var title = "未来展望"
    var slides: [Slide] = [
        未来展望章节首页(),
        发展规划(),
        智慧医院建设(),
    ]
}

// MARK: - Slide Definitions

struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "医院管理部"
}

struct 历史沿革章节首页: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

struct 现状分析章节首页: Slide, 章节样式 {
    var title = "现状分析"
    var chapterNumber: Int? = 2
}

struct 未来展望章节首页: Slide, 章节样式 {
    var title = "未来展望"
    var chapterNumber: Int? = 3
}

struct 古代医院: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理，奠定西方医学基础",
        "公元100年：罗马建立第一所公立医院，服务平民百姓",
        "公元800年：阿拉伯帝国建立医院体系，推动医学教育发展",
        "公元1100年：欧洲建立修道院医院，提供宗教和医疗服务",
    ]
}

struct 近代医院: Slide, 内容样式 {
    var title = "近代医院"
    var items = [
        "19世纪初：现代医院制度确立，专业化分工开始",
        "19世纪中期：南丁格尔改革护理制度，提升护理质量",
        "19世纪末：X射线发现，医学影像技术诞生",
        "20世纪初：抗生素发现，感染性疾病治疗革命",
    ]
}

struct 现代医院: Slide, 内容样式 {
    var title = "现代医院"
    var items = [
        "信息化管理：电子病历、HIS系统全面应用",
        "精准医疗：基因检测、个性化治疗方案",
        "微创技术：腹腔镜、机器人手术普及",
        "智慧医院：AI辅助诊断、远程医疗服务",
    ]
}

struct 床位使用率: Slide, 内容样式 {
    var title = "床位使用率分析"
    var items = [
        "总体使用率：85%，处于合理区间",
        "内科床位：92%，需求紧张",
        "外科床位：78%，资源充足",
        "优化建议：调整科室床位配置",
    ]
}

struct 患者满意度: Slide, 内容样式 {
    var title = "患者满意度调查"
    var items = [
        "总体满意度：4.5/5.0，高于行业平均",
        "医疗服务：4.6/5.0，专业水平获认可",
        "就医环境：4.3/5.0，设施持续改善",
        "改进方向：缩短候诊时间、优化预约流程",
    ]
}

struct 医疗质量指标: Slide, 内容样式 {
    var title = "医疗质量指标"
    var items = [
        "手术成功率：98.5%，达到国内先进水平",
        "院内感染率：0.8%，低于国家标准",
        "平均住院日：7.2天，效率持续提升",
        "再入院率：5.3%，随访管理加强",
    ]
}

struct 发展规划: Slide, 内容样式 {
    var title = "五年发展规划"
    var items = [
        "床位规模：从800张扩展到1200张",
        "重点专科：建设5个国家级重点专科",
        "人才队伍：引进100名高层次人才",
        "科研能力：年发表SCI论文100篇以上",
    ]
}

struct 智慧医院建设: Slide, 内容样式 {
    var title = "智慧医院建设"
    var items = [
        "AI辅助诊疗：影像AI、病理AI全面部署",
        "互联网医院：在线问诊、药品配送服务",
        "大数据平台：临床决策支持系统建设",
        "物联网应用：智能输液、智能监护系统",
    ]
}

// MARK: - Script Entry Point

print("🏥 Hospital Management Demo")
print("============================")
print("")
print("This demo showcases the Protocol Composition pattern")
print("for creating PowerPoint presentations with Swift.")
print("")

let fileManager = FileManager.default
// 获取项目根目录（SwiftOffice/B_SwiftSlides/）
let projectDir = fileManager.currentDirectoryPath
    .replacingOccurrences(of: "/Experiments/ProtocolComposition", with: "")
let outputsDir = projectDir + "/Outputs"

// 创建输出目录
do {
    try fileManager.createDirectory(
        atPath: outputsDir,
        withIntermediateDirectories: true,
        attributes: nil
    )
    print("📁 Output directory: \(outputsDir)")
} catch {
    print("⚠️ Warning: Could not create output directory")
}

// 创建演示文稿
let presentation = 医院管理总览()
let outputPath = outputsDir + "/\(presentation.title).pptx"

print("")
print("📝 Presentation Structure:")
print("   Title: \(presentation.title)")
print("   Author: \(presentation.author ?? "N/A")")
print("   Sections: \(presentation.sections.count)")

var totalSlides = 0
for section in presentation.sections {
    totalSlides += section.slides.count
    print("   - \(section.title): \(section.slides.count) slides")
}
print("   Total: \(totalSlides) slides")

// 生成 PPTX
print("")
print("🚀 Generating PPTX...")

do {
    try await presentation.generatePPTX(outputPath: outputPath)
    print("")
    print("✅ Success!")
    print("📄 Output: \(outputPath)")
} catch {
    print("")
    print("❌ Failed to generate PPTX")
    print("   Error: \(error)")
    exit(1)
}
