import Foundation

@available(macOS 10.15, *)
public protocol Section: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get set }
    var slides: [any Slide] { get set }
}

@available(macOS 10.15, *)
public extension Section {
    func toDict() -> [String: Any] {
        [
            "id": id.uuidString,
            "title": title,
            "slides": slides.map { $0.toDict() }
        ]
    }
}

@available(macOS 10.15, *)
public struct 章节: Section {
    public let id = UUID()
    public var title: String
    public var slides: [any Slide]
    
    public init(标题: String, slides: [any Slide] = []) {
        self.title = 标题
        self.slides = slides
    }
}

@available(macOS 10.15, *)
public typealias SectionBase = 章节
