import Foundation

@available(macOS 10.15, *)
public protocol TextElement: SlideElement {
    var text: String { get set }
    var font: Font { get set }
    var color: Color { get set }
    var alignment: TextAlignment { get set }
    var verticalAlignment: VerticalAlignment { get set }
    var lineSpacing: Double { get set }
    var isBullet: Bool { get set }
    var bulletStyle: BulletStyle { get set }
    var hyperlink: URL? { get set }
}

public enum BulletStyle: String, Codable, Sendable, CaseIterable {
    case none
    case dot
    case number
    case letter
    case custom
}

@available(macOS 10.15, *)
public extension TextElement {
    var estimatedHeight: Double {
        let lineCount = text.components(separatedBy: .newlines).count
        let baseHeight = font.size * Double(lineCount)
        let spacing = lineSpacing * Double(max(0, lineCount - 1))
        return baseHeight + spacing
    }
    
    var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var characterCount: Int {
        text.count
    }
}
