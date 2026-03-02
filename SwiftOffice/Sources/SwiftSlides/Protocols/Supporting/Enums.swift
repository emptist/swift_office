import Foundation

public struct Position: Codable, Sendable, Hashable {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Position(x: 0, y: 0)
}

public struct Size: Codable, Sendable, Hashable {
    public let width: Double
    public let height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public static let zero = Size(width: 0, height: 0)
}

public struct Rect: Codable, Sendable, Hashable {
    public let position: Position
    public let size: Size
    
    public init(position: Position, size: Size) {
        self.position = position
        self.size = size
    }
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.position = Position(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

public struct Color: Codable, Sendable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.red = Double(r) / 255
        self.green = Double(g) / 255
        self.blue = Double(b) / 255
        self.alpha = Double(a) / 255
    }
    
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 1, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1)
    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}

public struct Font: Codable, Sendable, Hashable {
    public let name: String
    public let size: Double
    public let isBold: Bool
    public let isItalic: Bool
    
    public init(name: String = "Arial", size: Double = 12, isBold: Bool = false, isItalic: Bool = false) {
        self.name = name
        self.size = size
        self.isBold = isBold
        self.isItalic = isItalic
    }
    
    public static let system = Font(name: "Arial", size: 12)
    public static let title = Font(name: "Arial", size: 24, isBold: true)
    public static let subtitle = Font(name: "Arial", size: 18)
    public static let body = Font(name: "Arial", size: 14)
}

public enum TextAlignment: String, Codable, Sendable, CaseIterable {
    case left
    case center
    case right
    case justify
}

public enum VerticalAlignment: String, Codable, Sendable, CaseIterable {
    case top
    case middle
    case bottom
}

public enum SlideLayout: String, Codable, Sendable, CaseIterable {
    case title
    case titleAndContent
    case sectionHeader
    case twoContent
    case comparison
    case titleOnly
    case blank
    case contentWithCaption
    case pictureWithCaption
    case custom
}

public enum ShapeType: String, Codable, Sendable, CaseIterable {
    case rectangle
    case roundedRectangle
    case ellipse
    case triangle
    case diamond
    case pentagon
    case hexagon
    case star
    case arrow
    case line
    case custom
}

public enum ChartType: String, Codable, Sendable, CaseIterable {
    case bar
    case stackedBar
    case column
    case stackedColumn
    case line
    case area
    case pie
    case doughnut
    case scatter
    case bubble
    case radar
    case combo
}

public enum ImageFormat: String, Codable, Sendable, CaseIterable {
    case png
    case jpeg
    case gif
    case svg
    case bmp
    case tiff
}

public enum FillType: String, Codable, Sendable, CaseIterable {
    case none
    case solid
    case gradient
    case pattern
    case picture
}

public struct Fill: Codable, Sendable, Hashable {
    public let type: FillType
    public let color: Color?
    public let gradientColors: [Color]?
    
    public init(type: FillType, color: Color? = nil, gradientColors: [Color]? = nil) {
        self.type = type
        self.color = color
        self.gradientColors = gradientColors
    }
    
    public static let none = Fill(type: .none)
    public static func solid(_ color: Color) -> Fill {
        Fill(type: .solid, color: color)
    }
}

public struct Stroke: Codable, Sendable, Hashable {
    public let color: Color
    public let width: Double
    public let isDashed: Bool
    
    public init(color: Color, width: Double = 1.0, isDashed: Bool = false) {
        self.color = color
        self.width = width
        self.isDashed = isDashed
    }
    
    public static let none = Stroke(color: .clear, width: 0)
    public static let defaultStroke = Stroke(color: .black, width: 1.0)
}

public struct Shadow: Codable, Sendable, Hashable {
    public let color: Color
    public let blur: Double
    public let offset: Position
    public let angle: Double
    
    public init(color: Color = Color(red: 0, green: 0, blue: 0, alpha: 0.5), blur: Double = 4.0, offset: Position = Position(x: 2, y: 2), angle: Double = 45.0) {
        self.color = color
        self.blur = blur
        self.offset = offset
        self.angle = angle
    }
    
    public static let none = Shadow(color: .clear, blur: 0, offset: .zero, angle: 0)
    public static let defaultShadow = Shadow()
}
