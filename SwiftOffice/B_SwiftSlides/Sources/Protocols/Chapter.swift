import Foundation

// ============================================
// Chapter 协议 - 章协议（逻辑分组）
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
// # Chapter (章) - Logical Content Grouping
//
// Chapter represents logical content grouping, similar to chapters in a book.
// Examples: "第一章：AI时代背景", "第二章：数据资产管理"
//
// # Automatic Numbering
//
// **Important**: Chapter numbers are automatically generated based on array index.
// Users should NOT manually set chapter numbers to avoid hardcoding.
//
// - Chapter 1 → "第1章"
// - Chapter 2 → "第2章"
// - Chapter 3 → "第3章"
//
// The numbering is generated during PPTX generation based on chapter's position
// in parent's chapters array.
//
// # Flexible Combinations
//
// Chapter can contain:
// - Nodes (节) - logical content grouping
// - Slides (幻灯片) - content units
//
// Only one type of content should be used per Chapter to maintain clarity.
//
// # Valid Combinations
//
// ```swift
// Example 1: Chapter with Nodes
// struct Chapter1: Chapter {
//     let title = "第一章：AI时代背景"
//     let nodes: [any Node] = [Node1(), Node2()]
// }
//
// Example 2: Chapter with Slides (skip Node level)
// struct Chapter1: Chapter {
//     let title = "第一章：AI时代背景"
//     let slides: [any Slide] = [Slide1(), Slide2()]
// }
// ```
//
// # Design Principles
//
// 1. Protocol uses `var { get }`, implementation uses `let`
// 2. Chapter is logical content grouping (e.g., "第一章：AI时代背景")
// 3. Chapter contains Nodes or Slides
// 4. Automatic numbering based on array index (no manual numbering)
// ============================================

@available(macOS 10.15, *)
public protocol Chapter: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var nodes: [any Node] { get }
    var slides: [any Slide] { get }
    func toDict(chapterIndex: Int?) -> [String: Any]
}

@available(macOS 10.15, *)
public extension Chapter {
    var id: UUID { UUID() }
    var nodes: [any Node] { [] }
    var slides: [any Slide] { [] }
    
    func toDict(chapterIndex: Int? = nil) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title
        ]
        
        if let chapterIndex = chapterIndex {
            dict["chapterNumber"] = chapterIndex + 1
            dict["chapterNumberDisplay"] = "第\(chapterIndex + 1)章"
        }
        
        if !nodes.isEmpty {
            dict["nodes"] = nodes.enumerated().map { index, node in
                node.toDict(nodeIndex: index)
            }
        }
        
        if !slides.isEmpty {
            dict["slides"] = slides.map { $0.toDict() }
        }
        
        return dict
    }
    
    func flattenSlides() -> [any Slide] {
        var result: [any Slide] = []
        
        for node in nodes {
            result.append(contentsOf: node.flattenSlides())
        }
        
        for slide in slides {
            result.append(contentsOf: slide.flattenSlides())
        }
        
        return result
    }
}

// MARK: - Default Implementation

@available(macOS 10.15, *)
public struct 章: Chapter {
    public let id = UUID()
    public let title: String
    public let nodes: [any Node]
    public let slides: [any Slide]
    
    public init(标题: String, nodes: [any Node] = [], slides: [any Slide] = []) {
        self.title = 标题
        self.nodes = nodes
        self.slides = slides
    }
}

@available(macOS 10.15, *)
public typealias ChapterBase = 章
