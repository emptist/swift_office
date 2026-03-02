import Foundation

@available(macOS 10.15, *)
public protocol Presentation: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get set }
    var author: String? { get set }
    var sections: [any Section] { get set }
}

@available(macOS 10.15, *)
public extension Presentation {
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "sections": sections.map { $0.toDict() }
        ]
        if let author = author { dict["author"] = author }
        return dict
    }
    
    func toJSON() throws -> String {
        let dict = toDict()
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

@available(macOS 10.15, *)
public struct 演示文稿: Presentation {
    public let id = UUID()
    public var title: String
    public var author: String?
    public var sections: [any Section]
    
    public init(
        标题: String,
        作者: String? = nil,
        sections: [any Section] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.sections = sections
    }
}

@available(macOS 10.15, *)
public typealias PresentationBase = 演示文稿
