import Foundation
import SwiftSlides
import Runner

@main
struct MyPresentation {
    static func main() async {
        let presentation = MyPresentation.createPresentation()
        
        do {
            try await PresentationRunner.generate(presentation)
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func createPresentation() -> any Presentation {
        struct MySection: Section {
            let title = "我的章节"
            let contents: SlideContent = SlideContent([
                "slides": [
                    MySlide(),
                    AnotherSlide()
                ] as [any Sendable]
            ])
            
            var slides: [any Slide] {
                contents.asSlideArray
            }
        }
        
        struct MySlide: Slide, ContentStyle {
            let title = "我的幻灯片"
            let contents: SlideContent = SlideContent([
                "items": [
                    "第一项内容",
                    "第二项内容",
                    "第三项内容"
                ] as [any Sendable]
            ])
        }
        
        struct AnotherSlide: Slide, TextStyle {
            let title = "另一张幻灯片"
            let contents: SlideContent = SlideContent([
                "content": "这是一段文本内容"
            ])
        }
        
        struct MyPresentation: Presentation {
            let title = "我的演示文稿"
            let contents: SlideContent = SlideContent([
                "author": "作者姓名",
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
                    MySection()
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
                _ = try await PresentationRunner.generatePPTX(json: json, outputDir: "Outputs", presentationTitle: title)
            }
        }
        
        return MyPresentation()
    }
}
