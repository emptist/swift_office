import Foundation

public protocol Theme: Codable, Sendable {
    var id: UUID { get }
    var name: String { get set }
    var colorScheme: ThemeColorScheme { get set }
    var fontScheme: ThemeFontScheme { get set }
    var formatScheme: ThemeFormatScheme { get set }
}

public struct ThemeColorScheme: Codable, Sendable, Hashable {
    public let primary: Color
    public let secondary: Color
    public let accent1: Color
    public let accent2: Color
    public let accent3: Color
    public let accent4: Color
    public let background: Color
    public let text: Color
    public let hyperlink: Color
    public let followedHyperlink: Color
    
    public init(
        primary: Color,
        secondary: Color,
        accent1: Color,
        accent2: Color,
        accent3: Color,
        accent4: Color,
        background: Color = .white,
        text: Color = .black,
        hyperlink: Color = Color(hex: "0000FF"),
        followedHyperlink: Color = Color(hex: "800080")
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent1 = accent1
        self.accent2 = accent2
        self.accent3 = accent3
        self.accent4 = accent4
        self.background = background
        self.text = text
        self.hyperlink = hyperlink
        self.followedHyperlink = followedHyperlink
    }
    
    public static let `default` = ThemeColorScheme(
        primary: Color(hex: "4472C4"),
        secondary: Color(hex: "ED7D31"),
        accent1: Color(hex: "A5A5A5"),
        accent2: Color(hex: "FFC000"),
        accent3: Color(hex: "5B9BD5"),
        accent4: Color(hex: "70AD47")
    )
    
    public static let dark = ThemeColorScheme(
        primary: Color(hex: "4472C4"),
        secondary: Color(hex: "ED7D31"),
        accent1: Color(hex: "A5A5A5"),
        accent2: Color(hex: "FFC000"),
        accent3: Color(hex: "5B9BD5"),
        accent4: Color(hex: "70AD47"),
        background: Color(hex: "1F1F1F"),
        text: Color(hex: "FFFFFF")
    )
}

public struct ThemeFontScheme: Codable, Sendable, Hashable {
    public let headingFont: Font
    public let bodyFont: Font
    public let titleFont: Font
    public let subtitleFont: Font
    
    public init(
        headingFont: Font = Font(name: "Arial", size: 24, isBold: true),
        bodyFont: Font = Font(name: "Arial", size: 14),
        titleFont: Font = Font(name: "Arial", size: 36, isBold: true),
        subtitleFont: Font = Font(name: "Arial", size: 20)
    ) {
        self.headingFont = headingFont
        self.bodyFont = bodyFont
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
    }
    
    public static let `default` = ThemeFontScheme()
    public static let serif = ThemeFontScheme(
        headingFont: Font(name: "Times New Roman", size: 24, isBold: true),
        bodyFont: Font(name: "Times New Roman", size: 14),
        titleFont: Font(name: "Times New Roman", size: 36, isBold: true),
        subtitleFont: Font(name: "Times New Roman", size: 20)
    )
}

public struct ThemeFormatScheme: Codable, Sendable, Hashable {
    public let fillStyles: [Fill]
    public let lineStyles: [Stroke]
    public let effectStyles: [Shadow]
    
    public init(
        fillStyles: [Fill] = [],
        lineStyles: [Stroke] = [],
        effectStyles: [Shadow] = []
    ) {
        self.fillStyles = fillStyles
        self.lineStyles = lineStyles
        self.effectStyles = effectStyles
    }
    
    public static let `default` = ThemeFormatScheme(
        fillStyles: [
            Fill.solid(Color(hex: "4472C4")),
            Fill.solid(Color(hex: "ED7D31")),
            Fill.solid(Color(hex: "A5A5A5"))
        ],
        lineStyles: [
            Stroke(color: Color(hex: "4472C4"), width: 1.0),
            Stroke(color: Color(hex: "ED7D31"), width: 2.0),
            Stroke(color: Color(hex: "A5A5A5"), width: 1.0)
        ],
        effectStyles: [
            Shadow.defaultShadow
        ]
    )
}

public struct DefaultTheme: Theme {
    public let id: UUID
    public var name: String
    public var colorScheme: ThemeColorScheme
    public var fontScheme: ThemeFontScheme
    public var formatScheme: ThemeFormatScheme
    
    public init(
        id: UUID = UUID(),
        name: String = "Default",
        colorScheme: ThemeColorScheme = .default,
        fontScheme: ThemeFontScheme = .default,
        formatScheme: ThemeFormatScheme = .default
    ) {
        self.id = id
        self.name = name
        self.colorScheme = colorScheme
        self.fontScheme = fontScheme
        self.formatScheme = formatScheme
    }
    
    public static let standard = DefaultTheme()
    public static let dark = DefaultTheme(
        name: "Dark",
        colorScheme: .dark
    )
    public static let minimal = DefaultTheme(
        name: "Minimal",
        colorScheme: ThemeColorScheme(
            primary: Color(hex: "000000"),
            secondary: Color(hex: "666666"),
            accent1: Color(hex: "333333"),
            accent2: Color(hex: "999999"),
            accent3: Color(hex: "CCCCCC"),
            accent4: Color(hex: "EEEEEE")
        )
    )
}
