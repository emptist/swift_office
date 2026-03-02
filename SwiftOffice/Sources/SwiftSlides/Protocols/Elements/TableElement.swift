import Foundation

@available(macOS 10.15, *)
public protocol TableElement: SlideElement {
    var rows: [TableRow] { get set }
    var headers: [String] { get set }
    var style: TableStyle { get set }
    var showHeader: Bool { get set }
    var showBorders: Bool { get set }
}

public struct TableRow: Codable, Sendable, Hashable {
    public let cells: [TableCell]
    
    public init(cells: [TableCell]) {
        self.cells = cells
    }
    
    public init(strings: [String]) {
        self.cells = strings.map { TableCell(text: $0) }
    }
}

public struct TableCell: Codable, Sendable, Hashable {
    public let text: String
    public let alignment: TextAlignment
    public let font: Font?
    public let color: Color?
    public let backgroundColor: Color?
    public let colspan: Int
    public let rowspan: Int
    
    public init(
        text: String,
        alignment: TextAlignment = .left,
        font: Font? = nil,
        color: Color? = nil,
        backgroundColor: Color? = nil,
        colspan: Int = 1,
        rowspan: Int = 1
    ) {
        self.text = text
        self.alignment = alignment
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.colspan = colspan
        self.rowspan = rowspan
    }
}

public struct TableStyle: Codable, Sendable, Hashable {
    public let headerBackgroundColor: Color
    public let headerTextColor: Color
    public let rowBackgroundColor: Color
    public let alternateRowBackgroundColor: Color?
    public let borderColor: Color
    public let borderWidth: Double
    public let cellPadding: EdgeInsets
    
    public init(
        headerBackgroundColor: Color = Color(hex: "4472C4"),
        headerTextColor: Color = .white,
        rowBackgroundColor: Color = .white,
        alternateRowBackgroundColor: Color? = Color(hex: "D9E2F3"),
        borderColor: Color = Color(hex: "8EA9DB"),
        borderWidth: Double = 1.0,
        cellPadding: EdgeInsets = .standard
    ) {
        self.headerBackgroundColor = headerBackgroundColor
        self.headerTextColor = headerTextColor
        self.rowBackgroundColor = rowBackgroundColor
        self.alternateRowBackgroundColor = alternateRowBackgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cellPadding = cellPadding
    }
    
    public static let `default` = TableStyle()
    public static let plain = TableStyle(
        headerBackgroundColor: Color(hex: "CCCCCC"),
        headerTextColor: .black,
        alternateRowBackgroundColor: nil
    )
}

@available(macOS 10.15, *)
public extension TableElement {
    var columnCount: Int {
        headers.isEmpty ? (rows.first?.cells.count ?? 0) : headers.count
    }
    
    var rowCount: Int {
        rows.count
    }
    
    var totalCellCount: Int {
        rows.reduce(0) { $0 + $1.cells.count }
    }
    
    func cell(at row: Int, column: Int) -> TableCell? {
        guard row < rows.count else { return nil }
        let cells = rows[row].cells
        guard column < cells.count else { return nil }
        return cells[column]
    }
}
