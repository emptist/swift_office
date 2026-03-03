import Foundation
import SwiftSlides

// ============================================
// Protocol Composition 模式示例
// ============================================

/// 医院管理总览演示文稿示例
///
/// 此文件展示了如何使用 Protocol Composition 模式创建演示文稿。
/// 用户只需定义内容结构，无需关心底层实现细节。
///
/// ## 核心概念
/// - **Presentation**: 整个演示文稿的容器
/// - **Section**: 章节，用于组织幻灯片
/// - **Slide**: 单个幻灯片
/// - **样式协议**: 通过 Protocol 组合赋予幻灯片特定能力
///
/// ## 使用方式
/// 1. 定义 Presentation 结构体
/// 2. 定义 Section 结构体
/// 3. 定义 Slide 结构体并组合样式协议
/// 4. 运行程序自动生成 PPTX
///
/// - Author: Kimi-k2.5
/// - Version: 1.0.0
/// - Date: 2026-03-03

// MARK: - 演示文稿定义

/// 医院管理总览演示文稿
///
/// 这是一个完整的演示文稿示例，包含封面和历史沿革两个章节
struct 医院管理总览: Presentation {
    var title = "医院管理总览"
    var author: String? = "张三"
    var theme: 主题? = nil
    var sections: [any Section] = [
        封面章节(),
        历史沿革章节(),
    ]
}

// MARK: - 章节定义

/// 封面章节
///
/// 包含演示文稿的封面页
struct 封面章节: Section {
    var title = "封面"
    var slides: [any Slide] = [
        封面页(),
    ]
}

/// 历史沿革章节
///
/// 展示医院发展的历史脉络
struct 历史沿革章节: Section {
    var title = "历史沿革"
    var slides: [any Slide] = [
        章节首页(),
        古代医院(),
        现代医院(),
    ]
}

// MARK: - 幻灯片定义

/// 封面页
///
/// 使用 `封面样式` 协议组合，获得副标题和作者显示能力
struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "张三"
}

/// 章节首页
///
/// 使用 `章节样式` 协议组合，获得章节编号显示能力
struct 章节首页: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

/// 古代医院内容页
///
/// 使用 `内容样式` 协议组合，获得项目列表显示能力
struct 古代医院: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

/// 现代医院内容页
///
/// 使用 `内容样式` 协议组合，获得项目列表显示能力
struct 现代医院: Slide, 内容样式 {
    var title = "现代医院"
    var items = [
        "19世纪：无菌手术技术",
        "20世纪：抗生素广泛应用",
        "21世纪：数字化医疗",
    ]
}

// ============================================
// 自动执行（用户不用修改）
// ============================================

/// 自动运行器
///
/// 程序入口点，自动创建输出目录并生成 PPTX 文件
@main
struct AutoRunner {
    static func main() async {
        let fileManager = FileManager.default
        let outputsDir = fileManager.currentDirectoryPath + "/outputs"
        try? fileManager.createDirectory(atPath: outputsDir, withIntermediateDirectories: true)
        
        let presentation = 医院管理总览()
        let outputPath = outputsDir + "/\(presentation.title).pptx"
        
        do {
            try await presentation.generatePPTX(outputPath: outputPath)
            print("✅ 生成成功: \(outputPath)")
        } catch {
            print("❌ 生成失败: \(error)")
        }
    }
}
