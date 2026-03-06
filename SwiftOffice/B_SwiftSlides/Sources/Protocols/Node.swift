import Foundation

// ============================================
// Node 协议 - 节协议（逻辑分组）
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
// # Node (节) - Logical Content Grouping
//
// Node represents logical content grouping, similar to sections within a chapter.
// Examples: "1.1 AI时代背景", "1.2 数据资产概念"
//
// # Automatic Numbering
//
// **Important**: Node numbers are automatically generated based on array index.
// Users should NOT manually set node numbers to avoid hardcoding.
//
// - Node 1 → "1.1节"
// - Node 2 → "1.2节"
// - Node 3 → "1.3节"
//
// The numbering is generated during PPTX generation based on node's position
// in parent's nodes array. The chapter number is inherited from the parent.
//
// # Flexible Combinations
//
// Node contains:
// - Slides (幻灯片) - content units
//
// # Valid Combinations
//
// ```swift
// Example: Node with Slides
// struct Node1: Node {
//     let title = "1.1 AI时代背景"
//     let slides: [any Slide] = [Slide1(), Slide2()]
// }
// ```
//
// # Design Principles
//
// 1. Protocol uses `var { get }`, implementation uses `let`
// 2. Node is logical content grouping (e.g., "1.1 AI时代背景")
// 3. Node contains Slides
// 4. Automatic numbering based on array index (no manual numbering)
// ============================================

@available(macOS 10.15, *)
public protocol Node: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var slides: [any Slide] { get }
    func toDict(nodeIndex: Int?) -> [String: Any]
}

@available(macOS 10.15, *)
public extension Node {
    var id: UUID { UUID() }
    
    func toDict(nodeIndex: Int? = nil) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "slides": slides.map { $0.toDict() }
        ]
        
        if let nodeIndex = nodeIndex {
            dict["nodeNumber"] = nodeIndex + 1
            dict["nodeNumberDisplay"] = "\(nodeIndex + 1).1节"
        }
        
        return dict
    }
    
    func flattenSlides() -> [any Slide] {
        var result: [any Slide] = []
        for slide in slides {
            result.append(contentsOf: slide.flattenSlides())
        }
        return result
    }
}

// MARK: - Default Implementation

@available(macOS 10.15, *)
public struct 节: Node {
    public let id = UUID()
    public let title: String
    public let slides: [any Slide]
    
    public init(标题: String, slides: [any Slide] = []) {
        self.title = 标题
        self.slides = slides
    }
}

@available(macOS 10.15, *)
public typealias NodeBase = 节
