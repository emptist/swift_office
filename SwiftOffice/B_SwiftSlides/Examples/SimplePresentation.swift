#!/usr/bin/env swift

import Foundation
import SwiftSlides
import Runner

struct SimplePresentation: Presentation {
    let title = "简单演示文稿"
    let contents: SlideContent = SlideContent([
        "author": "演示作者",
        "date": "2024"
    ])
    
    var author: String? {
        for (_, value) in contents.dict {
            if let str = value as? String {
                return str
            }
        }
        return nil
    }
    
    var sections: [any Section] {
        [
            SimpleSection()
        ]
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "contents": contents.toJSONDict(),
            "sections": sections.map { $0.toDict() }
        ]
        if let author = author {
            dict["author"] = author
        }
        return dict
    }
    
    func toJSON() throws -> String {
        let dict = toDict()
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func generatePPTX(outputPath: String) async throws {
        let json = try toJSON()
        _ = try await PresentationRunner.generatePPTX(presentation: self, outputDir: "Outputs")
    }
}

struct SimpleSection: Section {
    let title = "演示章节"
    let contents: SlideContent = SlideContent([
        "slides": [
            SimpleSlide()
        ] as [any Sendable]
    ])
    
    var slides: [any Slide] {
        contents.asSlideArray
    }
    
    func toDict() -> [String: Any] {
        [
            "title": title,
            "contents": contents.toJSONDict(),
            "slides": slides.map { $0.toDict() }
        ]
    }
}

struct SimpleSlide: Slide, ContentStyle {
    let title = "欢迎使用SwiftSlides"
    let contents: SlideContent = SlideContent([
        "items": [
            "这是一个简单的演示文稿",
            "使用PresentationRunner生成PPTX",
            "无需为每个演示文稿创建runner"
        ] as [any Sendable]
    ])
}

@main
struct App {
    static func main() async {
        let presentation = SimplePresentation()
        
        do {
            try await PresentationRunner.generate(presentation)
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
