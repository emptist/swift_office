import Foundation

// ============================================
// Presentation 协议 - 演示文稿协议
// ============================================
//
// # Five-Level Hierarchy
//
// SwiftOffice uses a 5-level hierarchy for organizing presentations:
//
// ```
// Presentation (演示文稿/古书) ─ 物理整体
//   │
//   └── Section (册) ─ 物理分组（如上册、下册）
//         │
//         └── Chapter (章) ─ 逻辑分组（如第一章）
//               │
//               └── Node (节) ─ 逻辑分组（如1.1节）
//                     │
//                     └── Slide (幻灯片) ─ 内容单元
// ```
//
// # Key Distinction
//
// - **Presentation & Section**: Grouped by physical materials (物理材料分组)
// - **Chapter, Node & Slide**: Grouped by logic and ideas (逻辑内容分组)
//
// # Hierarchy Rules
//
// 1. **Order is Fixed**: The hierarchy order is always Presentation → Section → Chapter → Node → Slide
// 2. **No Reverse Order**: Cannot skip upward (e.g., Slide cannot contain Node)
// 3. **Flexible Combination**: Users can skip any intermediate levels as needed
//
// # Automatic Numbering
//
// **Important**: All level numbers are automatically generated based on array index.
// Users should NOT manually set any numbers to avoid hardcoding.
//
// - Section 1 → "第1册"
// - Chapter 1 → "第1章"
// - Node 1 → "1.1节"
//
// The numbering is generated during PPTX generation based on each level's position
// in the parent's array.
//
// # Flexible Combinations
//
// Presentation can use any hierarchy level as the starting point:
// - SectionBasedPresentation: Uses Section level
// - ChapterBasedPresentation: Uses Chapter level
// - NodeBasedPresentation: Uses Node level
// - SlideBasedPresentation: Uses Slide level directly
//
// # Valid Combinations
//
// ```swift
// Example 1: Simple - Skip all intermediate levels
// struct SimplePresentation: SlideBasedPresentation {
//     let title = "Simple Demo"
//     let slides: [any Slide] = [Slide1(), Slide2()]
// }
//
// Example 2: With Chapter - Skip Section and Node
// struct ChapterPresentation: ChapterBasedPresentation {
//     let title = "Chapter Demo"
//     let chapters: [any Chapter] = [Chapter1(), Chapter2()]
// }
//
// Example 3: Full Hierarchy - All levels
// struct FullPresentation: SectionBasedPresentation {
//     let title = "Full Demo"
//     let sections: [any Section] = [Section1()]
// }
// ```
//
// # Design Principles
//
// 1. Protocol uses `var { get }`, implementation uses `let`
// 2. Automatic numbering based on array index (no manual numbering)
// 3. Flexible hierarchy combinations
// 4. Supports PPTX generation
// ============================================

@available(macOS 10.15, *)
public protocol Presentation: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var author: String? { get }
    var theme: 主题? { get }
    func toDict() -> [String: Any]
    func toJSON() throws -> String
    func generatePPTX(outputPath: String) async throws
}

// MARK: - Hierarchy Level Support

/// Protocol for presentations using Section level (册)
@available(macOS 10.15, *)
public protocol SectionBasedPresentation: Presentation {
    var sections: [any Section] { get }
}

/// Protocol for presentations using Chapter level (章)
@available(macOS 10.15, *)
public protocol ChapterBasedPresentation: Presentation {
    var chapters: [any Chapter] { get }
}

/// Protocol for presentations using Node level (节)
@available(macOS 10.15, *)
public protocol NodeBasedPresentation: Presentation {
    var nodes: [any Node] { get }
}

/// Protocol for presentations using Slide level directly
@available(macOS 10.15, *)
public protocol SlideBasedPresentation: Presentation {
    var slides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension Presentation {
    var id: UUID { UUID() }
    var author: String? { nil }
    var theme: 主题? { nil }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title
        ]
        
        if let author = author { dict["author"] = author }
        if let theme = theme { dict["theme"] = theme.toDict() }
        
        // Add cover properties if conforms to CoverStyle
        if let cover = self as? any CoverStyle {
            if let subtitle = cover.subtitle { dict["subtitle"] = subtitle }
            if let date = cover.date { dict["date"] = date }
        }
        
        // Add content based on hierarchy level used
        if let sectionBased = self as? any SectionBasedPresentation {
            if !sectionBased.sections.isEmpty {
                dict["sections"] = sectionBased.sections.enumerated().map { index, section in
                    section.toDict(sectionIndex: index)
                }
            }
        }
        
        if let chapterBased = self as? any ChapterBasedPresentation {
            if !chapterBased.chapters.isEmpty {
                dict["chapters"] = chapterBased.chapters.enumerated().map { index, chapter in
                    chapter.toDict(chapterIndex: index)
                }
            }
        }
        
        if let nodeBased = self as? any NodeBasedPresentation {
            if !nodeBased.nodes.isEmpty {
                dict["nodes"] = nodeBased.nodes.enumerated().map { index, node in
                    node.toDict(nodeIndex: index)
                }
            }
        }
        
        if let slideBased = self as? any SlideBasedPresentation {
            if !slideBased.slides.isEmpty {
                dict["slides"] = slideBased.slides.map { $0.toDict() }
            }
        }
        
        return dict
    }
    
    func toJSON() throws -> String {
        let dict = toDict()
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    func generatePPTX(outputPath: String) async throws {
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let scriptsPath = URL(fileURLWithPath: currentPath)
            .appendingPathComponent("B_SwiftSlides/Scripts")
        
        let bridge = try NodeJSBridge(scriptsPath: scriptsPath)
        let presentationJSON = try toJSON()
        let params: [String: any Sendable & Codable] = [
            "presentation": presentationJSON,
            "outputPath": outputPath
        ]
        let result = try await bridge.executeScript("swiftslides-pptx", params: params)
        guard let success = result["success"] as? Bool, success else {
            throw SwiftSlidesError.scriptExecutionFailed(
                script: "swiftslides-pptx",
                exitCode: 1,
                output: "",
                errorOutput: result["error"] as? String ?? "Unknown error"
            )
        }
    }
    
    func allSlides() -> [any Slide] {
        var result: [any Slide] = []
        
        if let sectionBased = self as? any SectionBasedPresentation {
            for section in sectionBased.sections {
                result.append(contentsOf: section.flattenSlides())
            }
        }
        
        if let chapterBased = self as? any ChapterBasedPresentation {
            for chapter in chapterBased.chapters {
                result.append(contentsOf: chapter.flattenSlides())
            }
        }
        
        if let nodeBased = self as? any NodeBasedPresentation {
            for node in nodeBased.nodes {
                result.append(contentsOf: node.flattenSlides())
            }
        }
        
        if let slideBased = self as? any SlideBasedPresentation {
            for slide in slideBased.slides {
                result.append(contentsOf: slide.flattenSlides())
            }
        }
        
        return result
    }
}

// MARK: - 默认实现

@available(macOS 10.15, *)
public struct 演示文稿: Presentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
    }
}

@available(macOS 10.15, *)
public typealias PresentationBase = 演示文稿

// MARK: - Section-based Presentation

@available(macOS 10.15, *)
public struct SectionPresentation: SectionBasedPresentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let sections: [any Section]
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil,
        sections: [any Section] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
        self.sections = sections
    }
}

// MARK: - Chapter-based Presentation

@available(macOS 10.15, *)
public struct ChapterPresentation: ChapterBasedPresentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let chapters: [any Chapter]
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil,
        chapters: [any Chapter] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
        self.chapters = chapters
    }
}

// MARK: - Node-based Presentation

@available(macOS 10.15, *)
public struct NodePresentation: NodeBasedPresentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let nodes: [any Node]
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil,
        nodes: [any Node] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
        self.nodes = nodes
    }
}

// MARK: - Slide-based Presentation

@available(macOS 10.15, *)
public struct SlidePresentation: SlideBasedPresentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let slides: [any Slide]
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil,
        slides: [any Slide] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
        self.slides = slides
    }
}
