import Foundation

@available(macOS 10.15, *)
public protocol Slide: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get set }
    var notes: String? { get set }
    var hidden: Bool { get set }
    var slideType: String { get }
    func toDict() -> [String: Any]
}

@available(macOS 10.15, *)
public extension Slide {
    var id: UUID { UUID() }
    var notes: String? { nil }
    var hidden: Bool { false }
}
