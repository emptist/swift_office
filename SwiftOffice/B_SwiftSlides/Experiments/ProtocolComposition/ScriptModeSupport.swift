import Foundation

// ============================================
// Script Mode Support - Experimental
// ============================================
//
// 此文件是 Protocol Composition 模式的脚本模式支持实验。
//
// 目标：探索如何让用户通过单个 Swift 脚本文件创建 PPTX，
// 无需复杂的 Swift Package 配置。
//
// 使用方式：
//   swift ScriptModeSupport.swift
//
// 注意：这是实验性代码，API 可能会变化。
//
// - Author: Kimi-k2.5
// - Version: 0.1.0 (Experimental)
// - Date: 2026-03-03
// ============================================

// MARK: - Core Protocols

/// 幻灯片基础协议
///
/// 所有幻灯片类型都必须遵循此协议。提供唯一标识和标题。
public protocol Slide {
    /// 幻灯片唯一标识符
    var id: UUID { get }
    /// 幻灯片标题
    var title: String { get }
}

public extension Slide {
    /// 默认实现：自动生成 UUID
    var id: UUID { UUID() }
}

/// 章节协议
///
/// 用于组织幻灯片的逻辑分组。一个章节包含多个幻灯片。
public protocol Section {
    /// 章节唯一标识符
    var id: UUID { get }
    /// 章节标题
    var title: String { get }
    /// 章节包含的幻灯片数组
    var slides: [Slide] { get }
}

public extension Section {
    /// 默认实现：自动生成 UUID
    var id: UUID { UUID() }
}

/// 演示文稿协议
///
/// 整个 PPTX 文件的顶层容器。包含多个章节。
public protocol Presentation {
    /// 演示文稿唯一标识符
    var id: UUID { get }
    /// 演示文稿标题
    var title: String { get }
    /// 演示文稿包含的章节数组
    var sections: [Section] { get }
}

public extension Presentation {
    /// 默认实现：自动生成 UUID
    var id: UUID { UUID() }
    
    /// 生成 PPTX 文件的便捷方法
    func generatePPTX(outputPath: String) async throws {
        let generator = PPTXGenerator()
        try await generator.generate(presentation: self, outputPath: outputPath)
    }
}

// MARK: - Style Protocols

/// 封面样式协议
public protocol 封面样式: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

/// 章节样式协议
public protocol 章节样式: Slide {
    var chapterNumber: Int? { get }
}

/// 内容样式协议
public protocol 内容样式: Slide {
    var items: [String] { get }
}

// MARK: - PPTX Generator

/// PPTX 文件生成器
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
        // 从 B_SwiftSlides/Outputs/ 向上两级到 SwiftOffice/
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

// MARK: - Example Presentation

struct 医院管理总览示例: Presentation {
    var title = "医院管理总览"
    var sections: [Section] = [
        封面章节示例(),
        历史沿革章节示例(),
    ]
}

struct 封面章节示例: Section {
    var title = "封面"
    var slides: [Slide] = [
        封面页示例(),
    ]
}

struct 历史沿革章节示例: Section {
    var title = "历史沿革"
    var slides: [Slide] = [
        章节首页示例(),
        古代医院示例(),
        现代医院示例(),
    ]
}

struct 封面页示例: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "张三"
}

struct 章节首页示例: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

struct 古代医院示例: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

struct 现代医院示例: Slide, 内容样式 {
    var title = "现代医院"
    var items = [
        "19世纪：无菌手术技术",
        "20世纪：抗生素广泛应用",
        "21世纪：数字化医疗",
    ]
}

// MARK: - Script Entry Point

print("🚀 Script Mode Support - Experimental")
print("=====================================")

let fileManager = FileManager.default
let projectDir = fileManager.currentDirectoryPath
    .replacingOccurrences(of: "/Experiments/ProtocolComposition", with: "")
let outputsDir = projectDir + "/Outputs"

do {
    try fileManager.createDirectory(
        atPath: outputsDir,
        withIntermediateDirectories: true
    )
    print("📁 Created output directory: \(outputsDir)")
} catch {
    print("⚠️ Failed to create output directory: \(error)")
}

let presentation = 医院管理总览示例()
let outputPath = outputsDir + "/\(presentation.title).pptx"

do {
    print("📝 Generating presentation...")
    try await presentation.generatePPTX(outputPath: outputPath)
    print("✅ Success! Output: \(outputPath)")
} catch {
    print("❌ Failed to generate PPTX: \(error)")
    exit(1)
}
