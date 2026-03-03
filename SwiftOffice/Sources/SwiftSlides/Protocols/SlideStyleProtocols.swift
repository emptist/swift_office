import Foundation

// ============================================
// 幻灯片样式协议 - 用于 Protocol 组合
// ============================================

@available(macOS 10.15, *)
public protocol 封面样式: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

@available(macOS 10.15, *)
public protocol 章节样式: Slide {
    var chapterNumber: Int? { get }
}

@available(macOS 10.15, *)
public protocol 内容样式: Slide {
    var items: [String] { get }
}
