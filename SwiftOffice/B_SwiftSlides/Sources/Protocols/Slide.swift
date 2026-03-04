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
// 7. SlideContent：字典 [String: Any]，可解析、可序列化
// ============================================

// MARK: - SlideContent

/// SlideContent - Dictionary wrapper with type-safe access
public struct SlideContent: Sendable, ExpressibleByDictionaryLiteral {
    public var dict: [String: any Sendable]
    
    public init(dictionaryLiteral elements: (String, any Sendable)...) {
        self.dict = Dictionary(uniqueKeysWithValues: elements)
    }
    
    public init(_ dict: [String: any Sendable] = [:]) {
        self.dict = dict
    }
    
    public subscript(key: String) -> SlideContent? {
        guard let value = dict[key] else { return nil }
        if let d = value as? [String: any Sendable] {
            return SlideContent(d)
        }
        if let arr = value as? [any Sendable] {
            return SlideContent(["items": arr as any Sendable])
        }
        return nil
    }
    
    public var asString: String {
        for (_, value) in dict {
            if let str = value as? String {
                return str
            }
        }
        return ""
    }
    
    public var asStringArray: [String] {
        for (_, value) in dict {
            if let arr = value as? [String] {
                return arr
            }
        }
        return []
    }
    
    public var asDouble: Double? {
        for (_, value) in dict {
            if let num = value as? Double {
                return num
            }
            if let num = value as? Int {
                return Double(num)
            }
        }
        return nil
    }
    
    public var asStringTable: [[String]] {
        for (_, value) in dict {
            if let arr = value as? [[String]] {
                return arr
            }
        }
        return []
    }
    
    public var asDict: [String: any Sendable] { dict }
    
    public var asDictArray: [[String: any Sendable]] {
        for (_, value) in dict {
            if let arr = value as? [[String: any Sendable]] {
                return arr
            }
        }
        return []
    }
    
    public var asContentsArray: [SlideContent] {
        for (_, value) in dict {
            if let arr = value as? [[String: any Sendable]] {
                return arr.map { SlideContent($0) }
            }
        }
        return []
    }
    
    public var asSectionArray: [any Section] {
        for (_, value) in dict {
            if let sections = value as? [any Section] {
                return sections
            }
        }
        return []
    }
    
    public var asSlideArray: [any Slide] {
        for (_, value) in dict {
            if let slides = value as? [any Slide] {
                return slides
            }
        }
        return []
    }
    
    public func toJSONDict() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in dict {
            if let arr = value as? [any Sendable] {
                result[key] = arr.map { item -> Any in
                    if let content = item as? SlideContent {
                        return content.toJSONDict()
                    } else if let section = item as? any Section {
                        return section.toDict()
                    } else if let slide = item as? any Slide {
                        return slide.toDict()
                    } else {
                        return String(describing: item)
                    }
                }
            } else if let contents = value as? SlideContent {
                result[key] = contents.toJSONDict()
            } else if let section = value as? any Section {
                result[key] = section.toDict()
            } else if let slide = value as? any Slide {
                result[key] = slide.toDict()
            } else {
                result[key] = String(describing: value)
            }
        }
        return result
    }
}

extension SlideContent: Codable {
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
        self.dict = codableDict.mapValues { SlideContent.convertToSendable($0.value) }
    }
    
    private static func convertToSendable(_ value: Any) -> any Sendable {
        switch value {
        case let v as any Sendable:
            return v
        case let v as [Any]:
            return v.map { convertToSendable($0) }
        case let v as [String: Any]:
            return v.mapValues { convertToSendable($0) }
        default:
            return String(describing: value)
        }
    }
}

/// AnyCodable helper
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }
}

/// Content typealias for backward compatibility
public typealias Content = SlideContent

// MARK: - Slide Protocol

/// Slide protocol - Core slide protocol
@available(macOS 10.15, *)
public protocol Slide: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var contents: SlideContent { get }
    var notes: String? { get }
    var hidden: Bool { get }
    var fellowSlides: [any Slide] { get }
    func toDict() -> [String: Any]
}

@available(macOS 10.15, *)
public extension Slide {
    var id: UUID { UUID() }
    var notes: String? { nil }
    var hidden: Bool { false }
    var fellowSlides: [any Slide] { [] }
    
    func toDict() -> [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "contents": contents.toJSONDict()
        ]
        if let notes = notes {
            result["notes"] = notes
        }
        if hidden {
            result["hidden"] = hidden
        }
        if !fellowSlides.isEmpty {
            result["fellowSlides"] = fellowSlides.map { $0.toDict() }
        }
        return result
    }
    
    func flattenSlides() -> [any Slide] {
        var result: [any Slide] = [self]
        for slide in fellowSlides {
            result.append(contentsOf: slide.flattenSlides())
        }
        return result
    }
}

// MARK: - Slide Style Protocols
