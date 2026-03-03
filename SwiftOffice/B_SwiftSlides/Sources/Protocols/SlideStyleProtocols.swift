import Foundation

// ============================================
// 幻灯片样式协议 - 用于 Protocol 组合
// ============================================

/// 封面样式协议，用于定义演示文稿封面页的样式能力
///
/// 通过遵循此协议，任何 Slide 类型都可以获得封面页的能力，
/// 包括显示副标题和作者信息
///
/// ## 示例
/// ```swift
/// struct 我的封面: Slide, 封面样式 {
///     var title = "演示标题"
///     var subtitle: String? = "副标题内容"
///     var author: String? = "作者姓名"
/// }
/// ```
///
/// - Author: Kimi-k2.5
/// - Version: 1.0.0
/// - Date: 2026-03-03
@available(macOS 10.15, *)
public protocol 封面样式: Slide {
    /// 封面副标题，可选
    var subtitle: String? { get }
    
    /// 作者信息，可选
    var author: String? { get }
}

/// 章节样式协议，用于定义章节分隔页的样式能力
///
/// 通过遵循此协议，任何 Slide 类型都可以获得章节页的能力，
/// 包括显示章节编号
///
/// ## 示例
/// ```swift
/// struct 章节首页: Slide, 章节样式 {
///     var title = "第一章"
///     var chapterNumber: Int? = 1
/// }
/// ```
///
/// - Author: Kimi-k2.5
/// - Version: 1.0.0
/// - Date: 2026-03-03
@available(macOS 10.15, *)
public protocol 章节样式: Slide {
    /// 章节编号，可选
    var chapterNumber: Int? { get }
}

/// 内容样式协议，用于定义内容页的样式能力
///
/// 通过遵循此协议，任何 Slide 类型都可以获得内容页的能力，
/// 包括显示项目列表
///
/// ## 示例
/// ```swift
/// struct 内容页: Slide, 内容样式 {
///     var title = "要点总结"
///     var items = [
///         "第一点内容",
///         "第二点内容",
///         "第三点内容"
///     ]
/// }
/// ```
///
/// - Author: Kimi-k2.5
/// - Version: 1.0.0
/// - Date: 2026-03-03
@available(macOS 10.15, *)
public protocol 内容样式: Slide {
    /// 内容项目列表
    var items: [String] { get }
}
