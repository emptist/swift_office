import Foundation

// ============================================
// Slide Style Protocols - Protocol Composition Design
// ============================================
//
// Core Design Principles:
// 1. Protocols define "capabilities", not "fixed types"
// 2. Users compose multiple Protocols to define a Slide
// 3. Protocols use var { get }, implementations use let
// 4. Same data can be presented differently with different Protocols
// 5. Core elements: title + contents, protocol determines presentation
// ============================================

// MARK: - Content Parser

@available(macOS 10.15, *)
public enum ContentParser {
    public static func parseStringArray(_ contents: SlideContent) -> [String] {
        // Format 1: Single item ["label": "text"]
        let dict = contents.dict
        for (_, value) in dict {
            if let str = value as? String {
                return [str]
            }
        }
        // Format 2: Array ["items": ["A", "B"]]
        return contents.asStringArray
    }
    
    public static func parseString(_ contents: SlideContent) -> String {
        // Format: ["label": "text"]
        for (_, value) in contents.dict {
            if let str = value as? String {
                return str
            }
        }
        return contents.asString
    }
    
    public static func parseTable(_ contents: SlideContent) -> (headers: [String], rows: [[String]]) {
        // Format 1: Column-oriented (spreadsheet style)
        // ["Category": ["A", "B"], "Value": ["1", "2"]]
        let dict = contents.dict
        let columnKeys = dict.keys.filter { key in
            if let arr = dict[key] as? [String] { return !arr.isEmpty }
            return false
        }
        if !columnKeys.isEmpty {
            let headers = Array(columnKeys)
            guard let firstColumn = dict[headers[0]] as? [String] else { return ([], []) }
            let rowCount = firstColumn.count
            var rows: [[String]] = []
            for i in 0..<rowCount {
                var row: [String] = []
                for header in headers {
                    if let column = dict[header] as? [String], i < column.count {
                        row.append(column[i])
                    }
                }
                rows.append(row)
            }
            return (headers, rows)
        }
        
        // Format 2: Row-oriented (traditional format) - 支持多语言
        var headers: [String] = []
        var rows: [[String]] = []
        
        for (key, value) in dict {
            if ["表头", "headers", "header", "标题", "titles"].contains(key) {
                headers = value as? [String] ?? []
            }
            if ["行", "rows", "row", "数据", "data"].contains(key) {
                rows = value as? [[String]] ?? []
            }
        }
        
        if !headers.isEmpty || !rows.isEmpty {
            return (headers, rows)
        }
        
        // Fallback: try to parse as string table
        let arr = contents.asStringTable
        if arr.count > 1 {
            return (arr[0], Array(arr[1...]))
        }
        return ([], [])
    }
    
    public static func parseHierarchy(_ contents: SlideContent) -> SlideHierarchyNode? {
        if let levels = contents.dict["levels"] as? [[String]] {
            return parseHierarchyArray(levels)
        }
        return parseHierarchyNode(contents)
    }
    
    private static func parseHierarchyArray(_ levels: [[String]]) -> SlideHierarchyNode? {
        guard !levels.isEmpty else { return nil }
        
        func buildNode(level: Int, index: Int) -> SlideHierarchyNode? {
            guard level < levels.count, index < levels[level].count else { return nil }
            let title = levels[level][index]
            let childIndex = index * 2
            let children: [SlideHierarchyNode]? = {
                let left = buildNode(level: level + 1, index: childIndex)
                let right = buildNode(level: level + 1, index: childIndex + 1)
                return [left, right].compactMap { $0 }
            }()
            return SlideHierarchyNode(
                id: "\(level)-\(index)",
                title: title,
                subtitle: nil,
                children: children?.isEmpty == true ? nil : children
            )
        }
        
        return buildNode(level: 0, index: 0)
    }
    
    private static func parseHierarchyNode(_ contents: SlideContent) -> SlideHierarchyNode? {
        let title = contents["title"]?.asString ?? ""
        guard !title.isEmpty else { return nil }
        let id = contents["id"]?.asString ?? UUID().uuidString
        let subtitle = contents["subtitle"]?.asString
        let children = contents["children"]?.asContentsArray.compactMap { parseHierarchyNode($0) } ?? []
        return SlideHierarchyNode(id: id, title: title, subtitle: subtitle, children: children.isEmpty ? nil : children)
    }
    
    public static func 解析循环步骤(_ contents: SlideContent) -> [SlideCycleStep] {
        contents.asContentsArray.enumerated().map { index, item in
            SlideCycleStep(
                id: item["id"]?.asString ?? "\(index)",
                title: item["title"]?.asString ?? "",
                description: item["description"]?.asString
            )
        }
    }
    
    public static func 解析框图(_ contents: SlideContent) -> [SlideBox] {
        contents.asContentsArray.map { item in
            SlideBox(
                title: item["title"]?.asString,
                content: item["content"]?.asStringArray ?? []
            )
        }
    }
    
    public static func 解析柏拉图(_ contents: SlideContent) -> [SlideParetoItem] {
        var cumulative = 0.0
        return contents.asDictArray.map { item in
            let category = item["category"] as? String ?? ""
            let value = item["value"] as? Double ?? 0
            cumulative += value
            return SlideParetoItem(category: category, value: value, cumulativePercent: cumulative)
        }
    }
}

// MARK: - 基础样式协议

/// Cover style protocol
@available(macOS 10.15, *)
public protocol CoverStyle: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

@available(macOS 10.15, *)
public extension CoverStyle {
    var subtitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(副标题|subtitle|Subtitle)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var author: String? {
        for (key, value) in contents.dict {
            let pattern = "^(作者|author|Author)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
}

/// 章首页样式协议
@available(macOS 10.15, *)
public protocol ChapterCoverStyle: Slide {
    var chapterSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension ChapterCoverStyle {
    var chapterSlides: [any Slide] {
        for (_, value) in contents.dict {
            if let slides = value as? [any Slide] {
                return slides
            }
        }
        return []
    }
}

/// 节首页样式协议
@available(macOS 10.15, *)
public protocol NodeCoverStyle: Slide {
    var nodeSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension NodeCoverStyle {
    var nodeSlides: [any Slide] {
        for (_, value) in contents.dict {
            if let slides = value as? [any Slide] {
                return slides
            }
        }
        return []
    }
}

/// contents样式协议
@available(macOS 10.15, *)
public protocol ContentStyle: Slide {
    var items: [String] { get }
}

@available(macOS 10.15, *)
public extension ContentStyle {
    var items: [String] { ContentParser.parseStringArray(contents) }
}

/// 纯文本样式协议
@available(macOS 10.15, *)
public protocol TextStyle: Slide {
    var content: String { get }
}

@available(macOS 10.15, *)
public extension TextStyle {
    var content: String { ContentParser.parseString(contents) }
}

/// WithSubslidesStyle协议
@available(macOS 10.15, *)
public protocol WithSubslidesStyle: Slide {}

// MARK: - 布局样式协议

/// 双栏布局样式协议
@available(macOS 10.15, *)
public protocol TwoColumnStyle: Slide {
    var leftTitle: String? { get }
    var leftItems: [String] { get }
    var rightTitle: String? { get }
    var rightItems: [String] { get }
}

@available(macOS 10.15, *)
public extension TwoColumnStyle {
    var leftTitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(左|left)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var rightTitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(右|right)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var leftItems: [String] {
        for (key, value) in contents.dict {
            let pattern = "^(左|left)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? [String] ?? []
            }
        }
        return []
    }
    
    var rightItems: [String] {
        for (key, value) in contents.dict {
            let pattern = "^(右|right)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? [String] ?? []
            }
        }
        return []
    }
}

/// 卡片布局样式协议
@available(macOS 10.15, *)
public protocol CardStyle: Slide {
    var cards: [SlideCard] { get }
    var columns: Int { get }
}

@available(macOS 10.15, *)
public extension CardStyle {
    var cards: [SlideCard] {
        for (_, value) in contents.dict {
            if let cardArray = value as? [[String: any Sendable]] {
                return cardArray.map { dict in
                    var title = ""
                    var content = ""
                    
                    for (key, val) in dict {
                        if ["标题", "title", "Title"].contains(key) {
                            title = val as? String ?? ""
                        }
                        if ["内容", "content", "Content"].contains(key) {
                            content = val as? String ?? ""
                        }
                    }
                    
                    return SlideCard(title: title, content: content)
                }
            }
        }
        return []
    }
    
    var columns: Int {
        let cardCount = cards.count
        if cardCount <= 2 { return 1 }
        if cardCount <= 6 { return 2 }
        if cardCount <= 12 { return 3 }
        return 4
    }
}

/// 卡片数据结构
public struct SlideCard: Sendable, Hashable, Codable {
    public let title: String
    public let content: String
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

/// 表格样式协议
@available(macOS 10.15, *)
public protocol TableSlideStyle: Slide {
    var headers: [String] { get }
    var rows: [[String]] { get }
}

@available(macOS 10.15, *)
public extension TableSlideStyle {
    var headers: [String] {
        let (h, _) = ContentParser.parseTable(contents)
        return h
    }
    var rows: [[String]] {
        let (_, r) = ContentParser.parseTable(contents)
        return r
    }
}

/// 时间线样式协议
@available(macOS 10.15, *)
public protocol 时间线样式: Slide {
    var events: [SlideTimelineEvent] { get }
}

/// 时间事件数据结构
public struct SlideTimelineEvent: Sendable, Hashable, Codable {
    public let date: String
    public let title: String
    public let description: String?
    
    public init(date: String, title: String, description: String? = nil) {
        self.date = date
        self.title = title
        self.description = description
    }
}

/// 引用样式协议
@available(macOS 10.15, *)
public protocol 引用样式: Slide {
    var quote: String { get }
    var quoteAuthor: String? { get }
}

/// 结束页样式协议
@available(macOS 10.15, *)
public protocol 结束样式: Slide {
    var subtitle: String? { get }
}

// MARK: - 图表样式协议

/// 幻灯片图表类型枚举
public enum SlideChartType: String, Sendable, Codable {
    case bar = "bar"
    case line = "line"
    case pie = "pie"
    case doughnut = "doughnut"
    case radar = "radar"
    case scatter = "scatter"
}

/// 幻灯片图表数据系列
public struct SlideChartSeries: Sendable, Hashable, Codable {
    public let name: String
    public let values: [Double]
    
    public init(name: String, values: [Double]) {
        self.name = name
        self.values = values
    }
}

/// 图表样式协议
@available(macOS 10.15, *)
public protocol 图表样式: Slide {
    var chartType: SlideChartType { get }
    var labels: [String] { get }
    var series: [SlideChartSeries] { get }
    var xAxisTitle: String? { get }
    var yAxisTitle: String? { get }
    var showLegend: Bool { get }
}

@available(macOS 10.15, *)
public extension 图表样式 {
    var xAxisTitle: String? { nil }
    var yAxisTitle: String? { nil }
    var showLegend: Bool { true }
}

// MARK: - 流程图样式协议

/// 流程步骤数据结构
public struct SlideFlowStep: Sendable, Hashable, Codable {
    public let title: String
    public let description: String?
    
    public init(title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }
}

/// 流程图样式协议（简单版）
@available(macOS 10.15, *)
public protocol 流程图样式: Slide {
    var steps: [SlideFlowStep] { get }
    var isLoop: Bool { get }
}

@available(macOS 10.15, *)
public extension 流程图样式 {
    var isLoop: Bool { false }
}

// MARK: - 图片样式协议

/// 图片样式协议
@available(macOS 10.15, *)
public protocol 图片样式: Slide {
    var imagePath: String { get }
    var caption: String? { get }
}

@available(macOS 10.15, *)
public extension 图片样式 {
    var caption: String? { nil }
}

// MARK: - Mermaid 样式协议（原始手写代码方式）

/// Mermaid 流程图样式协议
@available(macOS 10.15, *)
public protocol Mermaid流程图样式: Slide {
    var mermaidCode: String { get }
}

/// Mermaid 时序图样式协议
@available(macOS 10.15, *)
public protocol Mermaid时序图样式: Slide {
    var mermaidCode: String { get }
}

/// Mermaid 甘特图样式协议
@available(macOS 10.15, *)
public protocol Mermaid甘特图样式: Slide {
    var mermaidCode: String { get }
}

// MARK: - Mermaid 高级 API 样式协议

/// Mermaid 流程图高级样式协议
@available(macOS 10.15, *)
public protocol Mermaid流程图高级样式: Slide {
    var flowchartDirection: Mermaid方向 { get }
    var flowchartNodes: [Mermaid节点] { get }
    var flowchartConnections: [Mermaid连线] { get }
    var flowchartSubgraphs: [Mermaid子图] { get }
    var flowchartConfig: Mermaid配置? { get }
}

@available(macOS 10.15, *)
public extension Mermaid流程图高级样式 {
    var flowchartDirection: Mermaid方向 { .从上到下 }
    var flowchartSubgraphs: [Mermaid子图] { [] }
    var flowchartConfig: Mermaid配置? { nil }
    
    func generateMermaidCode() -> String {
        let flowchart = Mermaid流程图(
            方向: flowchartDirection,
            节点: flowchartNodes,
            连线: flowchartConnections,
            子图: flowchartSubgraphs,
            配置: flowchartConfig
        )
        return flowchart.生成语法()
    }
}

/// Mermaid 时序图高级样式协议
@available(macOS 10.15, *)
public protocol Mermaid时序图高级样式: Slide {
    var sequenceParticipants: [String] { get }
    var sequenceMessages: [Mermaid消息] { get }
    var sequenceConfig: Mermaid配置? { get }
}

@available(macOS 10.15, *)
public extension Mermaid时序图高级样式 {
    var sequenceConfig: Mermaid配置? { nil }
    
    func generateMermaidCode() -> String {
        let diagram = Mermaid时序图(
            参与者: sequenceParticipants,
            消息: sequenceMessages,
            配置: sequenceConfig
        )
        return diagram.生成语法()
    }
}

// MARK: - 甘特图样式协议（高级 API）

/// 甘特图任务数据结构
public struct SlideGanttTask: Sendable, Hashable, Codable {
    public let name: String
    public let status: SlideGanttTaskStatus
    public let start: String
    public let end: String
    
    public init(name: String, status: SlideGanttTaskStatus = .pending, start: String, end: String) {
        self.name = name
        self.status = status
        self.start = start
        self.end = end
    }
}

/// 甘特图任务状态
public enum SlideGanttTaskStatus: String, Sendable, Codable {
    case pending = ""
    case active = "active"
    case done = "done"
    case critical = "crit"
}

/// 甘特图样式协议
@available(macOS 10.15, *)
public protocol 甘特图样式: Slide {
    var ganttTitle: String { get }
    var ganttTasks: [SlideGanttTask] { get }
    var dateFormat: String { get }
}

@available(macOS 10.15, *)
public extension 甘特图样式 {
    var dateFormat: String { "YYYY-MM-DD" }
    
    func generateMermaidCode() -> String {
        var lines: [String] = []
        lines.append("gantt")
        lines.append("    title \(ganttTitle)")
        lines.append("    dateFormat \(dateFormat)")
        
        for task in ganttTasks {
            let statusPrefix = task.status.rawValue.isEmpty ? "" : "\(task.status.rawValue), "
            lines.append("    \(task.name) : \(statusPrefix)\(task.name) : \(task.start), \(task.end)")
        }
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - 主题样式协议

/// 幻灯片渐变色枚举
public enum SlideGradientColor: String, Sendable, Codable {
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case red = "red"
    case orange = "orange"
    case gray = "gray"
}

/// 渐变背景样式协议
@available(macOS 10.15, *)
public protocol 渐变背景样式: Slide {
    var gradientColor: SlideGradientColor { get }
}

// MARK: - 高级图表样式协议

/// 金字塔层级数据
public struct SlidePyramidLevel: Sendable, Hashable, Codable {
    public let title: String
    public let items: [String]
    public let color: String?
    
    public init(title: String, items: [String], color: String? = nil) {
        self.title = title
        self.items = items
        self.color = color
    }
}

/// 金字塔图样式协议
@available(macOS 10.15, *)
public protocol 金字塔图样式: Slide {
    var pyramidLevels: [SlidePyramidLevel] { get }
    var pyramidTitle: String? { get }
}

@available(macOS 10.15, *)
public extension 金字塔图样式 {
    var pyramidTitle: String? { nil }
}

/// 矩阵单元格数据
public struct SlideMatrixCell: Sendable, Hashable, Codable {
    public let content: String
    public let rowHeader: String?
    public let colHeader: String?
    public let color: String?
    
    public init(content: String, rowHeader: String? = nil, colHeader: String? = nil, color: String? = nil) {
        self.content = content
        self.rowHeader = rowHeader
        self.colHeader = colHeader
        self.color = color
    }
}

/// 矩阵图样式协议
@available(macOS 10.15, *)
public protocol 矩阵图样式: Slide {
    var matrixRows: Int { get }
    var matrixCols: Int { get }
    var matrixCells: [SlideMatrixCell] { get }
    var rowHeaders: [String] { get }
    var colHeaders: [String] { get }
}

@available(macOS 10.15, *)
public extension 矩阵图样式 {
    var rowHeaders: [String] { [] }
    var colHeaders: [String] { [] }
}

/// 框图数据
public struct SlideBox: Sendable, Hashable, Codable {
    public let title: String?
    public let content: [String]
    public let borderColor: String?
    public let backgroundColor: String?
    
    public init(title: String? = nil, content: [String], borderColor: String? = nil, backgroundColor: String? = nil) {
        self.title = title
        self.content = content
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }
}

/// 框图样式协议
@available(macOS 10.15, *)
public protocol 框图样式: Slide {
    var boxes: [SlideBox] { get }
    var boxLayout: SlideBoxLayout { get }
}

/// 框图布局方式
public enum SlideBoxLayout: String, Sendable, Codable {
    case vertical
    case horizontal
    case grid
    case custom
}

/// 横框图样式协议
@available(macOS 10.15, *)
public protocol 横框图样式: 框图样式 {}

/// 竖框图样式协议
@available(macOS 10.15, *)
public protocol 竖框图样式: 框图样式 {}

@available(macOS 10.15, *)
public extension 横框图样式 {
    var boxLayout: SlideBoxLayout { .horizontal }
    
    var boxes: [SlideBox] {
        for (_, value) in contents.dict {
            if let items = value as? [[String: any Sendable]] {
                return items.compactMap { item in
                    var title: String?
                    var content: [String]?
                    
                    for (key, val) in item {
                        if ["标题", "title", "Title"].contains(key) {
                            title = val as? String
                        }
                        if ["内容", "content", "Content"].contains(key) {
                            content = val as? [String]
                        }
                    }
                    
                    guard let t = title else { return nil }
                    return SlideBox(title: t, content: content ?? [])
                }
            }
        }
        return []
    }
}

@available(macOS 10.15, *)
public extension 竖框图样式 {
    var boxLayout: SlideBoxLayout { .vertical }
    
    var boxes: [SlideBox] {
        for (_, value) in contents.dict {
            if let items = value as? [[String: any Sendable]] {
                return items.compactMap { item in
                    var title: String?
                    var content: [String]?
                    
                    for (key, val) in item {
                        if ["标题", "title", "Title"].contains(key) {
                            title = val as? String
                        }
                        if ["内容", "content", "Content"].contains(key) {
                            content = val as? [String]
                        }
                    }
                    
                    guard let t = title else { return nil }
                    return SlideBox(title: t, content: content ?? [])
                }
            }
        }
        return []
    }
}

/// 层次架构数据
public struct SlideHierarchyNode: Sendable, Hashable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let children: [SlideHierarchyNode]?
    
    public init(id: String, title: String, subtitle: String? = nil, children: [SlideHierarchyNode]? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.children = children
    }
}

/// 层次架构图样式协议
@available(macOS 10.15, *)
public protocol 层次架构图样式: Slide {
    var levels: [[String]] { get }
    var direction: String { get }
}

/// 层次架构方向
public enum SlideHierarchyDirection: String, Sendable, Codable {
    case topDown
    case bottomUp
    case leftToRight
    case rightToLeft
}

@available(macOS 10.15, *)
public extension 层次架构图样式 {
    var direction: String { "topDown" }
    var hierarchyDirection: SlideHierarchyDirection { SlideHierarchyDirection(rawValue: direction) ?? .topDown }
    var levels: [[String]] { contents.dict["levels"] as? [[String]] ?? [] }
    
    var hierarchyRoot: SlideHierarchyNode? {
        ContentParser.parseHierarchy(contents)
    }
}

/// 柏拉图数据项
public struct SlideParetoItem: Sendable, Hashable, Codable {
    public let category: String
    public let value: Double
    public let cumulativePercent: Double
    
    public init(category: String, value: Double, cumulativePercent: Double) {
        self.category = category
        self.value = value
        self.cumulativePercent = cumulativePercent
    }
}

/// 柏拉图样式协议
@available(macOS 10.15, *)
public protocol 柏拉图样式: Slide {
    var paretoItems: [SlideParetoItem] { get }
    var paretoTitle: String? { get }
    var showCumulativeLine: Bool { get }
}

@available(macOS 10.15, *)
public extension 柏拉图样式 {
    var paretoTitle: String? { nil }
    var showCumulativeLine: Bool { true }
    
    var paretoItems: [SlideParetoItem] {
        let items = contents["items"]?.asContentsArray ?? []
        var cumulative = 0.0
        let total = items.reduce(0.0) { sum, item in
            if let value = item["value"]?.asDouble {
                return sum + value
            }
            return sum
        }
        
        return items.map { item in
            let label = item["category"]?.asString ?? item["label"]?.asString ?? ""
            let value = item["value"]?.asDouble ?? 0.0
            cumulative += value
            let cumulativePercent = total > 0 ? (cumulative / total) * 100 : 0.0
            return SlideParetoItem(category: label, value: value, cumulativePercent: cumulativePercent)
        }
    }
}

/// 循环流程步骤
public struct SlideCycleStep: Sendable, Hashable, Codable {
    public let id: String
    public let title: String
    public let description: String?
    
    public init(id: String, title: String, description: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// 循环流程图样式协议（如 PDCA）
@available(macOS 10.15, *)
public protocol 循环流程图样式: Slide {
    var cycleSteps: [SlideCycleStep] { get }
    var cycleDirection: SlideCycleDirection { get }
}

/// 循环方向
public enum SlideCycleDirection: String, Sendable, Codable {
    case clockwise
    case counterClockwise
}

@available(macOS 10.15, *)
public extension 循环流程图样式 {
    var cycleDirection: SlideCycleDirection { .clockwise }
    
    var cycleSteps: [SlideCycleStep] {
        let items = contents["items"]?.asContentsArray ?? []
        return items.map { item in
            let id = item["id"]?.asString ?? UUID().uuidString
            let title = item["title"]?.asString ?? ""
            let description = item["description"]?.asString
            return SlideCycleStep(id: id, title: title, description: description)
        }
    }
}

public struct SlideBranchNode: Sendable, Hashable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let level: Int
    public let children: [SlideBranchNode]?
    public let annotation: String?
    
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        level: Int,
        children: [SlideBranchNode]? = nil,
        annotation: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.level = level
        self.children = children
        self.annotation = annotation
    }
}

@available(macOS 10.15, *)
public protocol 分支层次图样式: Slide {
    var branchRoot: SlideBranchNode { get }
    var branchLayout: SlideBranchLayout { get }
}

public enum SlideBranchLayout: String, Sendable, Codable {
    case pyramid
    case tree
    case radial
}

@available(macOS 10.15, *)
public extension 分支层次图样式 {
    var branchLayout: SlideBranchLayout { .pyramid }
}

public struct SlideQuadrantCell: Sendable, Hashable, Codable {
    public let title: String
    public let subtitle: String?
    public let quadrant: SlideQuadrant
    public let color: String?
    
    public init(title: String, subtitle: String? = nil, quadrant: SlideQuadrant, color: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.quadrant = quadrant
        self.color = color
    }
}

public enum SlideQuadrant: String, Sendable, Codable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

@available(macOS 10.15, *)
public protocol 四象限矩阵样式: Slide {
    var quadrantCells: [SlideQuadrantCell] { get }
    var xAxisLabel: String { get }
    var yAxisLabel: String { get }
    var xAxisLowLabel: String { get }
    var xAxisHighLabel: String { get }
    var yAxisLowLabel: String { get }
    var yAxisHighLabel: String { get }
}

@available(macOS 10.15, *)
public extension 四象限矩阵样式 {
    var xAxisLabel: String { "" }
    var yAxisLabel: String { "" }
    var xAxisLowLabel: String { "低" }
    var xAxisHighLabel: String { "高" }
    var yAxisLowLabel: String { "低" }
    var yAxisHighLabel: String { "高" }
}

// MARK: - English Chart Style Protocols

/// Hierarchy style protocol
@available(macOS 10.15, *)
public protocol HierarchyStyle: Slide {
    var hierarchyLevels: [[String]] { get }
}

@available(macOS 10.15, *)
public extension HierarchyStyle {
    var hierarchyLevels: [[String]] {
        for (_, value) in contents.dict {
            if let levels = value as? [String] {
                return [levels]
            }
            if let levels = value as? [[String]] {
                return levels
            }
        }
        return []
    }
}

/// Cycle flow style protocol
@available(macOS 10.15, *)
public protocol CycleFlowStyle: Slide {
    var cycleItems: [[String: String]] { get }
}

@available(macOS 10.15, *)
public extension CycleFlowStyle {
    var cycleItems: [[String: String]] {
        let items = contents["items"]?.asContentsArray ?? []
        return items.map { item in
            var result: [String: String] = [:]
            if let id = item["id"]?.asString { result["id"] = id }
            if let title = item["title"]?.asString { result["title"] = title }
            if let desc = item["description"]?.asString { result["description"] = desc }
            return result
        }
    }
}

/// Pareto style protocol
@available(macOS 10.15, *)
public protocol ParetoStyle: Slide {
    var paretoItems: [[String: Any]] { get }
}

@available(macOS 10.15, *)
public extension ParetoStyle {
    var paretoItems: [[String: Any]] {
        let items = contents["items"]?.asContentsArray ?? []
        return items.map { item in
            var result: [String: Any] = [:]
            if let label = item["label"]?.asString { result["label"] = label }
            if let value = item["value"]?.dict["value"] as? Int { result["value"] = value }
            if let value = item["value"]?.dict["value"] as? Double { result["value"] = value }
            return result
        }
    }
}

// MARK: - Container Style Protocol

/// Container style protocol for combining multiple slides
@available(macOS 10.15, *)
public protocol ContainerStyle: Slide {
    var containerLayout: ContainerLayout { get }
    var containerRatio: [Double] { get }
    var containerSlides: [any Slide] { get }
}

public enum ContainerLayout: String, Sendable, Codable {
    case horizontal
    case vertical
}

@available(macOS 10.15, *)
public extension ContainerStyle {
    var containerLayout: ContainerLayout {
        for (key, value) in contents.dict {
            if ["布局", "layout", "Layout"].contains(key) {
                if let str = value as? String {
                    return ContainerLayout(rawValue: str) ?? .horizontal
                }
            }
        }
        return .horizontal
    }
    
    var containerRatio: [Double] {
        for (key, value) in contents.dict {
            if ["比例", "ratio", "Ratio"].contains(key) {
                if let arr = value as? [Double] {
                    return arr
                }
            }
        }
        return [0.5, 0.5]
    }
    
    var containerSlides: [any Slide] {
        return fellowSlides
    }
}
