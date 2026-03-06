import Foundation

// ============================================
// Section 协议 - 章节协议
// ============================================
//
// 设计原则：
// 1. 协议用 var { get }，实现用 let
// 2. Section 可以在不同 Presentation 中复用
// ============================================

@available(macOS 10.15, *)
public protocol Section: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var slides: [any Slide] { get }
    func toDict() -> [String: Any]
}

@available(macOS 10.15, *)
public extension Section {
    var id: UUID { UUID() }
    
    func toDict() -> [String: Any] {
        let dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "slides": slides.map { $0.toDict() }
        ]
        return dict
    }
    
    func flattenSlides() -> [any Slide] {
        var result: [any Slide] = []
        for slide in slides {
            result.append(contentsOf: slide.flattenSlides())
        }
        return result
    }
}

// MARK: - 默认实现

/// 章节默认实现
///
/// 用户可以直接使用，也可以自定义 struct 遵循 Section 协议
@available(macOS 10.15, *)
public struct 章节: Section {
    public let id = UUID()
    public let title: String
    public let slides: [any Slide]
    
    public init(标题: String, slides: [any Slide] = []) {
        self.title = 标题
        self.slides = slides
    }
}

@available(macOS 10.15, *)
public typealias SectionBase = 章节
