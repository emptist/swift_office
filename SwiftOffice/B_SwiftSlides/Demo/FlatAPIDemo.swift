import Foundation
import SwiftSlides
import Runner

// ============================================
// Flat Property API Demo - New Design
// ============================================

struct FlatAPIDemoPresentation: PresentationCoverStyle {
    let title = "Flat Property API Demo"
    let subtitle: String? = "Mirror-Based Property Discovery"
    let author: String? = "JK"
    let date: String? = "2024"
    let sections: [any Section] = [
        FlatTypeWrapperSection(),
        FlatChineseSection(),
    ]
}

// MARK: - Sections

struct FlatTypeWrapperSection: Section {
    let title = "Type Wrappers"
    let slides: [any Slide] = [
        FlatImageSlide(),
        FlatMultiTypeSlide(),
    ]
}

struct FlatChineseSection: Section {
    let title = "中文属性演示"
    let slides: [any Slide] = [
        FlatChineseSlide(),
    ]
}

// MARK: - Slides (Flat Properties)

struct FlatImageSlide: Slide {
    let title = "Image Type Wrapper"
    let photo: Image = "demo-image.jpg"
    let description = "This slide has an image property"
}

struct FlatMultiTypeSlide: Slide {
    let title = "Multiple Type Wrappers"
    let photo: Image = "photo.jpg"
    let movie: Video = "demo.mp4"
    let link: URLString = "https://github.com"
    let color: HexColor = "#FF5500"
    let items = ["A", "B", "C"]
    let count = 42
    let enabled = true
}

struct FlatChineseSlide: Slide, ContentStyle {
    let title = "中文属性测试"
    let 项目 = [
        "第一项：Mirror自动发现",
        "第二项：任意属性名",
        "第三项：支持中文",
        "第四项：简洁优雅"
    ]
    let 作者 = "张三"
    let 年份 = 2024
}

// MARK: - Runner

@main
struct FlatAPIDemoRunner {
    static func main() async {
        let presentation = FlatAPIDemoPresentation()
        do {
            try await PresentationRunner.generate(presentation, saveJSON: true)
            print("✅ PPTX generated successfully!")
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
