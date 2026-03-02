import Foundation

@available(macOS 10.15, *)
public protocol SlideMaster: Identifiable, Codable, Sendable {
    var id: UUID { get }
    var name: String { get set }
    var layout: SlideLayout { get set }
    var placeholderElements: [PlaceholderElement] { get set }
    var backgroundColor: Color? { get set }
    var backgroundFill: Fill? { get set }
    var defaultFont: Font { get set }
    var defaultTextColor: Color { get set }
}

public struct PlaceholderElement: Codable, Sendable, Hashable {
    public let id: UUID
    public let type: PlaceholderType
    public var position: Position
    public var size: Size
    public var font: Font?
    public var color: Color?
    public var isRequired: Bool
    
    public init(
        id: UUID = UUID(),
        type: PlaceholderType,
        position: Position,
        size: Size,
        font: Font? = nil,
        color: Color? = nil,
        isRequired: Bool = false
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.font = font
        self.color = color
        self.isRequired = isRequired
    }
}

public enum PlaceholderType: String, Codable, Sendable, CaseIterable {
    case title
    case body
    case subtitle
    case footer
    case header
    case date
    case slideNumber
    case picture
    case chart
    case table
    case content
    case media
}

@available(macOS 10.15, *)
public struct DefaultSlideMaster: SlideMaster {
    public let id: UUID
    public var name: String
    public var layout: SlideLayout
    public var placeholderElements: [PlaceholderElement]
    public var backgroundColor: Color?
    public var backgroundFill: Fill?
    public var defaultFont: Font
    public var defaultTextColor: Color
    
    public init(
        id: UUID = UUID(),
        name: String,
        layout: SlideLayout,
        placeholderElements: [PlaceholderElement] = [],
        backgroundColor: Color? = nil,
        backgroundFill: Fill? = nil,
        defaultFont: Font = .body,
        defaultTextColor: Color = .black
    ) {
        self.id = id
        self.name = name
        self.layout = layout
        self.placeholderElements = placeholderElements
        self.backgroundColor = backgroundColor
        self.backgroundFill = backgroundFill
        self.defaultFont = defaultFont
        self.defaultTextColor = defaultTextColor
    }
    
    public static let titleMaster = DefaultSlideMaster(
        name: "Title Slide",
        layout: .title,
        placeholderElements: [
            PlaceholderElement(
                type: .title,
                position: Position(x: 457200, y: 2746389),
                size: Size(width: 8229600, height: 1143000),
                font: Font(name: "Arial", size: 44, isBold: true),
                isRequired: true
            ),
            PlaceholderElement(
                type: .subtitle,
                position: Position(x: 457200, y: 3889389),
                size: Size(width: 8229600, height: 457200),
                font: Font(name: "Arial", size: 24)
            )
        ]
    )
    
    public static let titleAndContentMaster = DefaultSlideMaster(
        name: "Title and Content",
        layout: .titleAndContent,
        placeholderElements: [
            PlaceholderElement(
                type: .title,
                position: Position(x: 457200, y: 274638),
                size: Size(width: 8229600, height: 1143000),
                font: Font(name: "Arial", size: 32, isBold: true),
                isRequired: true
            ),
            PlaceholderElement(
                type: .body,
                position: Position(x: 457200, y: 1600200),
                size: Size(width: 8229600, height: 4572000),
                font: Font(name: "Arial", size: 18)
            )
        ]
    )
    
    public static let sectionHeaderMaster = DefaultSlideMaster(
        name: "Section Header",
        layout: .sectionHeader,
        placeholderElements: [
            PlaceholderElement(
                type: .title,
                position: Position(x: 457200, y: 1371600),
                size: Size(width: 8229600, height: 1143000),
                font: Font(name: "Arial", size: 40, isBold: true),
                isRequired: true
            ),
            PlaceholderElement(
                type: .body,
                position: Position(x: 457200, y: 2971800),
                size: Size(width: 8229600, height: 914400),
                font: Font(name: "Arial", size: 20)
            )
        ]
    )
    
    public static let blankMaster = DefaultSlideMaster(
        name: "Blank",
        layout: .blank,
        placeholderElements: []
    )
    
    public static let allMasters: [any SlideMaster] = [
        titleMaster,
        titleAndContentMaster,
        sectionHeaderMaster,
        blankMaster
    ]
}

@available(macOS 10.15, *)
public extension SlideMaster {
    func placeholder(ofType type: PlaceholderType) -> PlaceholderElement? {
        placeholderElements.first { $0.type == type }
    }
    
    var hasTitlePlaceholder: Bool {
        placeholderElements.contains { $0.type == .title }
    }
    
    var hasBodyPlaceholder: Bool {
        placeholderElements.contains { $0.type == .body }
    }
    
    var requiredPlaceholders: [PlaceholderElement] {
        placeholderElements.filter { $0.isRequired }
    }
}
