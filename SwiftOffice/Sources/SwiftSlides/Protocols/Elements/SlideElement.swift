import Foundation

@available(macOS 10.15, *)
public protocol SlideElement: Identifiable, Codable, Sendable {
    var id: UUID { get }
    var position: Position { get set }
    var size: Size { get set }
    var isVisible: Bool { get set }
    var zIndex: Int { get set }
    var name: String? { get set }
    var rotation: Double { get set }
}

@available(macOS 10.15, *)
public extension SlideElement {
    var rect: Rect {
        Rect(position: position, size: size)
    }
    
    func contains(point: Position) -> Bool {
        point.x >= position.x &&
        point.x <= position.x + size.width &&
        point.y >= position.y &&
        point.y <= position.y + size.height
    }
    
    func intersects(other: any SlideElement) -> Bool {
        let r1 = rect
        let r2 = other.rect
        return r1.position.x < r2.position.x + r2.size.width &&
               r1.position.x + r1.size.width > r2.position.x &&
               r1.position.y < r2.position.y + r2.size.height &&
               r1.position.y + r1.size.height > r2.position.y
    }
}
