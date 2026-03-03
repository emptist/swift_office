import Foundation

@available(macOS 10.15, *)
public protocol ShapeElement: SlideElement {
    var shapeType: ShapeType { get set }
    var fill: Fill { get set }
    var stroke: Stroke { get set }
    var shadow: Shadow { get set }
    var cornerRadius: Double { get set }
    var text: String? { get set }
    var textProperties: ShapeTextProperties? { get set }
}

public struct ShapeTextProperties: Codable, Sendable, Hashable {
    public let font: Font
    public let color: Color
    public let alignment: TextAlignment
    public let verticalAlignment: VerticalAlignment
    public let margin: EdgeInsets
    
    public init(
        font: Font = .body,
        color: Color = .black,
        alignment: TextAlignment = .center,
        verticalAlignment: VerticalAlignment = .middle,
        margin: EdgeInsets = EdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    ) {
        self.font = font
        self.color = color
        self.alignment = alignment
        self.verticalAlignment = verticalAlignment
        self.margin = margin
    }
}

public struct EdgeInsets: Codable, Sendable, Hashable {
    public let top: Double
    public let left: Double
    public let bottom: Double
    public let right: Double
    
    public init(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    public static let zero = EdgeInsets()
    public static let standard = EdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
}

@available(macOS 10.15, *)
public extension ShapeElement {
    var hasText: Bool {
        guard let text = text else { return false }
        return !text.isEmpty
    }
}
