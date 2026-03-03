import Foundation

// ============================================
// Slide 协议 - 核心幻灯片协议
// ============================================
//
// 设计原则：
// 1. 协议用 var { get }，实现用 let
// 2. 支持 fellowSlides 层级嵌套
// 3. 简洁，只保留必要属性
// 4. 支持样式属性收集
// 5. 复用已有的 Mermaid 类型定义（BeautifulMermaid）
// 6. 核心要素：标题 + 内容，协议决定呈现方式
// 7. Contents：字典 [String: Any]，可解析、可序列化
// ============================================

// MARK: - Contents

/// Contents - Dictionary wrapper with type-safe access
public struct Contents: Sendable, ExpressibleByDictionaryLiteral {
    public var dict: [String: any Sendable]
    
    public init(dictionaryLiteral elements: (String, any Sendable)...) {
        self.dict = Dictionary(uniqueKeysWithValues: elements)
    }
    
    public init(_ dict: [String: any Sendable] = [:]) {
        self.dict = dict
    }
    
    public subscript(key: String) -> Contents? {
        guard let value = dict[key] else { return nil }
        if let d = value as? [String: any Sendable] {
            return Contents(d)
        }
        if let arr = value as? [any Sendable] {
            return Contents(["items": arr as any Sendable])
        }
        return nil
    }
    
    public var asString: String {
        if let str = dict["content"] as? String { return str }
        if let str = dict.first?.value as? String { return str }
        return ""
    }
    
    public var asStringArray: [String] {
        if let arr = dict["items"] as? [String] { return arr }
        if let arr = dict.first?.value as? [String] { return arr }
        return []
    }
    
    public var asStringTable: [[String]] {
        if let arr = dict["rows"] as? [[String]] { return arr }
        if let arr = dict.first?.value as? [[String]] { return arr }
        return []
    }
    
    public var asDict: [String: any Sendable] { dict }
    
    public var asDictArray: [[String: any Sendable]] {
        if let arr = dict["items"] as? [[String: any Sendable]] { return arr }
        if let arr = dict.first?.value as? [[String: any Sendable]] { return arr }
        return []
    }
    
    public var asContentsArray: [Contents] {
        if let arr = dict["items"] as? [[String: any Sendable]] {
            return arr.map { Contents($0) }
        }
        if let arr = dict.first?.value as? [[String: any Sendable]] {
            return arr.map { Contents($0) }
        }
        return []
    }
    
    public func toJSONDict() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = convertToJSONValue(value)
        }
        return result
    }
    
    private func convertToJSONValue(_ value: Any) -> Any {
        if let str = value as? String {
            return str
        } else if let num = value as? NSNumber {
            return num
        } else if let arr = value as? [Any] {
            return arr.map { convertToJSONValue($0) }
        } else if let dict = value as? [String: Any] {
            return dict.mapValues { convertToJSONValue($0) }
        } else if let contents = value as? Contents {
            return contents.toJSONDict()
        } else {
            return String(describing: value)
        }
    }
}

extension Contents: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let codableDict = dict.mapValues { value -> AnyCodable in
            AnyCodable(value)
        }
        try container.encode(codableDict)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let codableDict = try container.decode([String: AnyCodable].self)
        self.dict = codableDict.mapValues { $0.value as! any Sendable }
    }
}

/// AnyCodable helper
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? [String: Any] {
            try container.encode(value.mapValues { AnyCodable($0) })
        } else if let value = value as? [Any] {
            try container.encode(value.map { AnyCodable($0) })
        } else {
            try container.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value.mapValues { $0.value }
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value.map { $0.value }
        } else {
            self.value = NSNull()
        }
    }
}

// MARK: - Slide 协议

@available(macOS 10.15, *)
public protocol Slide: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var contents: Contents { get }
    var fellowSlides: [any Slide] { get }
    var notes: String? { get }
    var hidden: Bool { get }
    func toDict() -> [String: Any]
}

@available(macOS 10.15, *)
public extension Slide {
    var id: UUID { UUID() }
    var contents: Contents { Contents([:]) }
    var fellowSlides: [any Slide] { [] }
    var notes: String? { nil }
    var hidden: Bool { false }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "contents": contents.toJSONDict(),
            "notes": notes as Any,
            "hidden": hidden
        ]
        
        if !fellowSlides.isEmpty {
            dict["fellowSlides"] = fellowSlides.map { $0.toDict() }
        }
        
        dict.merge(collectStyleProperties()) { (_, new) in new }
        
        return dict
    }
    
    func flattenSlides() -> [any Slide] {
        var result: [any Slide] = [self]
        for slide in fellowSlides {
            result.append(contentsOf: slide.flattenSlides())
        }
        return result
    }
    
    private func collectStyleProperties() -> [String: Any] {
        var props: [String: Any] = [:]
        
        if let styled = self as? any CoverStyle {
            props["subtitle"] = styled.subtitle
            props["author"] = styled.author
            props["slideType"] = "cover"
        } else if let styled = self as? any ChapterCoverStyle {
            props["chapterNumber"] = styled.chapterNumber
            props["slideType"] = "chapterCover"
        } else if let styled = self as? any ContentStyle {
            props["items"] = styled.items
            props["slideType"] = "content"
        } else if let styled = self as? any TextStyle {
            props["content"] = styled.content
            props["slideType"] = "text"
        } else if let styled = self as? any TwoColumnStyle {
            props["leftTitle"] = styled.leftTitle
            props["leftItems"] = styled.leftItems
            props["rightTitle"] = styled.rightTitle
            props["rightItems"] = styled.rightItems
            props["slideType"] = "twoColumn"
        } else if let styled = self as? any CardStyle {
            props["cards"] = styled.cards.map { ["title": $0.title, "content": $0.content] }
            props["columns"] = styled.columns
            props["slideType"] = "cards"
        } else if let styled = self as? any TableSlideStyle {
            props["headers"] = styled.headers
            props["rows"] = styled.rows
            props["slideType"] = "table"
        } else if let styled = self as? any 时间线样式 {
            props["events"] = styled.events.map { [
                "date": $0.date,
                "title": $0.title,
                "description": $0.description as Any
            ] }
            props["slideType"] = "timeline"
        } else if let styled = self as? any 引用样式 {
            props["quote"] = styled.quote
            props["quoteAuthor"] = styled.quoteAuthor
            props["slideType"] = "quote"
        } else if let styled = self as? any 结束样式 {
            props["subtitle"] = styled.subtitle
            props["slideType"] = "end"
        } else if let styled = self as? any 图表样式 {
            props["chartType"] = styled.chartType.rawValue
            props["labels"] = styled.labels
            props["series"] = styled.series.map { ["name": $0.name, "values": $0.values] }
            props["xAxisTitle"] = styled.xAxisTitle
            props["yAxisTitle"] = styled.yAxisTitle
            props["showLegend"] = styled.showLegend
            props["slideType"] = "chart"
        } else if let styled = self as? any 流程图样式 {
            props["steps"] = styled.steps.map { [
                "title": $0.title,
                "description": $0.description as Any
            ] }
            props["isLoop"] = styled.isLoop
            props["slideType"] = "flowchart"
        } else if let styled = self as? any 图片样式 {
            props["imagePath"] = styled.imagePath
            props["caption"] = styled.caption
            props["slideType"] = "image"
        } else if let styled = self as? any Mermaid流程图样式 {
            props["mermaidCode"] = styled.mermaidCode
            props["slideType"] = "mermaidFlowchart"
        } else if let styled = self as? any Mermaid时序图样式 {
            props["mermaidCode"] = styled.mermaidCode
            props["slideType"] = "mermaidSequence"
        } else if let styled = self as? any Mermaid甘特图样式 {
            props["mermaidCode"] = styled.mermaidCode
            props["slideType"] = "mermaidGantt"
        } else if let styled = self as? any Mermaid流程图高级样式 {
            props["mermaidCode"] = styled.generateMermaidCode()
            props["flowchartDirection"] = styled.flowchartDirection.rawValue
            props["slideType"] = "mermaidFlowchart"
        } else if let styled = self as? any Mermaid时序图高级样式 {
            props["mermaidCode"] = styled.generateMermaidCode()
            props["slideType"] = "mermaidSequence"
        } else if let styled = self as? any 甘特图样式 {
            props["ganttTitle"] = styled.ganttTitle
            props["ganttTasks"] = styled.ganttTasks.map { [
                "name": $0.name,
                "status": $0.status.rawValue,
                "start": $0.start,
                "end": $0.end
            ] }
            props["dateFormat"] = styled.dateFormat
            props["mermaidCode"] = styled.generateMermaidCode()
            props["slideType"] = "gantt"
        }
        
        if let styled = self as? any 渐变背景样式 {
            props["gradientColor"] = styled.gradientColor.rawValue
        }
        
        if let styled = self as? any 金字塔图样式 {
            props["pyramidLevels"] = styled.pyramidLevels.map { [
                "title": $0.title,
                "items": $0.items,
                "color": $0.color as Any
            ] }
            props["pyramidTitle"] = styled.pyramidTitle as Any
            props["slideType"] = "pyramid"
        }
        
        if let styled = self as? any 矩阵图样式 {
            props["matrixRows"] = styled.matrixRows
            props["matrixCols"] = styled.matrixCols
            props["matrixCells"] = styled.matrixCells.map { [
                "content": $0.content,
                "rowHeader": $0.rowHeader as Any,
                "colHeader": $0.colHeader as Any,
                "color": $0.color as Any
            ] }
            props["rowHeaders"] = styled.rowHeaders
            props["colHeaders"] = styled.colHeaders
            props["slideType"] = "matrix"
        }
        
        if let styled = self as? any 框图样式 {
            props["boxes"] = styled.boxes.map { [
                "title": $0.title as Any,
                "content": $0.content,
                "borderColor": $0.borderColor as Any,
                "backgroundColor": $0.backgroundColor as Any
            ] }
            props["boxLayout"] = styled.boxLayout.rawValue
            props["slideType"] = "boxDiagram"
        }
        
        if let styled = self as? any 层次架构图样式 {
            if let root = styled.hierarchyRoot {
                props["hierarchyRoot"] = hierarchyNodeToDict(root)
            }
            props["hierarchyDirection"] = styled.hierarchyDirection.rawValue
            props["slideType"] = "hierarchy"
        }
        
        if let styled = self as? any 柏拉图样式 {
            props["paretoItems"] = styled.paretoItems.map { [
                "category": $0.category,
                "value": $0.value,
                "cumulativePercent": $0.cumulativePercent
            ] }
            props["paretoTitle"] = styled.paretoTitle as Any
            props["showCumulativeLine"] = styled.showCumulativeLine
            props["slideType"] = "pareto"
        }
        
        if let styled = self as? any 循环流程图样式 {
            props["cycleSteps"] = styled.cycleSteps.map { [
                "id": $0.id,
                "title": $0.title,
                "description": $0.description as Any
            ] }
            props["cycleDirection"] = styled.cycleDirection.rawValue
            props["slideType"] = "cycleFlow"
        }
        
        if let styled = self as? any 分支层次图样式 {
            props["branchRoot"] = branchNodeToDict(styled.branchRoot)
            props["branchLayout"] = styled.branchLayout.rawValue
            props["slideType"] = "branchedHierarchy"
        }
        
        if let styled = self as? any 四象限矩阵样式 {
            props["quadrantCells"] = styled.quadrantCells.map { [
                "title": $0.title,
                "subtitle": $0.subtitle as Any,
                "quadrant": $0.quadrant.rawValue,
                "color": $0.color as Any
            ] }
            props["xAxisLabel"] = styled.xAxisLabel
            props["yAxisLabel"] = styled.yAxisLabel
            props["xAxisLowLabel"] = styled.xAxisLowLabel
            props["xAxisHighLabel"] = styled.xAxisHighLabel
            props["yAxisLowLabel"] = styled.yAxisLowLabel
            props["yAxisHighLabel"] = styled.yAxisHighLabel
            props["slideType"] = "quadrantMatrix"
        }
        
        return props
    }
    
    private func hierarchyNodeToDict(_ node: SlideHierarchyNode) -> [String: Any] {
        var dict: [String: Any] = [
            "id": node.id,
            "title": node.title,
            "subtitle": node.subtitle as Any
        ]
        if let children = node.children {
            dict["children"] = children.map { hierarchyNodeToDict($0) }
        }
        return dict
    }
    
    private func branchNodeToDict(_ node: SlideBranchNode) -> [String: Any] {
        var dict: [String: Any] = [
            "id": node.id,
            "title": node.title,
            "subtitle": node.subtitle as Any,
            "level": node.level,
            "annotation": node.annotation as Any
        ]
        if let children = node.children {
            dict["children"] = children.map { branchNodeToDict($0) }
        }
        return dict
    }
}
