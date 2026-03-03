#!/usr/bin/env swift

import Foundation

// ============================================
// 工具层：协议定义和 PPTX 生成（SwiftSlides）
// ============================================

// MARK: - 核心协议

public protocol Slide {
    var id: UUID { get }
    var title: String { get }
}

public extension Slide {
    var id: UUID { UUID() }
}

public protocol Section {
    var id: UUID { get }
    var title: String { get }
    var slides: [Slide] { get }
}

public extension Section {
    var id: UUID { UUID() }
}

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

// MARK: - 样式协议

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

// MARK: - PPTX 生成器

public struct PPTXGenerator {
    public init() {}
    
    public func generate(presentation: Presentation, outputPath: String) async throws {
        let json = try encodeToJSON(presentation: presentation)
        
        let script = createNodeScript(json: json, outputPath: outputPath)
        try await executeNodeScript(script: script)
    }
    
    private func encodeToJSON(presentation: Presentation) throws -> String {
        var slidesData: [[String: Any]] = []
        
        // 封面
        slidesData.append([
            "type": "title",
            "title": presentation.title
        ])
        
        // 遍历所有 section 和 slide
        for section in presentation.sections {
            for slide in section.slides {
                var slideData: [String: Any] = [
                    "type": getSlideType(slide),
                    "title": slide.title
                ]
                
                // 根据样式提取数据
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
        return """
        const PptxGenJS = require('/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/node_modules/pptxgenjs');
        
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

// ============================================
// 用户定义的内容（数据层）
// ============================================

struct 医院管理总览: Presentation {
    let title = "医院管理总览"
    
    let sections: [Section] = [
        封面章节(),
        历史沿革章节(),
    ]
}

struct 封面章节: Section {
    let title = "封面"
    let slides: [Slide] = [
        封面页(),
    ]
}

struct 历史沿革章节: Section {
    let title = "历史沿革"
    let slides: [Slide] = [
        章节首页(),
        古代医院(),
        现代医院(),
    ]
}

struct 封面页: Slide, 封面样式 {
    let title = "医院管理总览"
    let subtitle: String? = "2024年度报告"
    let author: String? = "张三"
}

struct 章节首页: Slide, 章节样式 {
    let title = "历史沿革"
    let chapterNumber: Int? = 1
}

struct 古代医院: Slide, 内容样式 {
    let title = "古代医院"
    let items = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

struct 现代医院: Slide, 内容样式 {
    let title = "现代医院" 
    let items = [
        "19世纪：无菌手术技术",
        "20世纪：抗生素广泛应用",
        "21世纪：数字化医疗",
    ]
}

// ============================================
// 执行代码
// ============================================

import Dispatch

let semaphore = DispatchSemaphore(value: 0)

Task {
    let presentation = 医院管理总览()
    
    // 创建 outputs 目录
    let fileManager = FileManager.default
    let outputsDir = fileManager.currentDirectoryPath + "/outputs"
    try? fileManager.createDirectory(atPath: outputsDir, withIntermediateDirectories: true)
    
    let outputPath = outputsDir + "/医院管理总览.pptx"
    
    do {
        try await presentation.generatePPTX(outputPath: outputPath)
        print("✅ 生成成功: \(outputPath)")
    } catch {
        print("❌ 生成失败: \(error)")
        print("💡 提示：需要安装 Node.js 和 pptxgenjs")
        print("   npm install pptxgenjs")
    }
    semaphore.signal()
}

semaphore.wait()
