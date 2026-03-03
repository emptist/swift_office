import Foundation

@available(macOS 10.15, *)
public protocol Slide: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get set }
    var notes: String? { get }
    var hidden: Bool { get }
    var slideType: String { get }
    func toDict() -> [String: Any]
}

@available(macOS 10.15, *)
public extension Slide {
    var id: UUID { UUID() }
    var notes: String? { nil }
    var hidden: Bool { false }
    var slideType: String { "default" }
    
    func toDict() -> [String: Any] {
        [
            "id": id.uuidString,
            "type": slideType,
            "title": title,
            "notes": notes as Any,
            "hidden": hidden
        ]
    }
}
