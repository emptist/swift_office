import SwiftSlidesCore
import Foundation

// ============================================
// 销售报告.pptx
// ============================================

struct SwiftSlidePresentation: Presentation {
    var title = "销售报告"
    var author: String? = "销售部"

    var sections: [Section] = [
        封面章节(),
        业绩章节(),
        展望章节(),
    ]
}

struct 封面章节: Section {
    var title = "封面"
    var slides: [Slide] = [
        封面页(),
    ]
}

struct 业绩章节: Section {
    var title = "业绩"
    var slides: [Slide] = [
        季度业绩(),
        年度对比(),
    ]
}

struct 展望章节: Section {
    var title = "展望"
    var slides: [Slide] = [
        下季度目标(),
    ]
}

struct 封面页: Slide, 封面样式 {
    var title = "销售报告"
    var subtitle: String? = "2024 Q4"
    var author: String? = "销售部"
}

struct 季度业绩: Slide, 内容样式 {
    var title = "Q4 业绩"
    var items = [
        "销售额：500万，同比增长20%",
        "新客户：50家",
        "客户满意度：95%",
    ]
}

struct 年度对比: Slide, 内容样式 {
    var title = "年度对比"
    var items = [
        "2023年：1800万",
        "2024年：2200万",
        "增长率：22%",
    ]
}

struct 下季度目标: Slide, 内容样式 {
    var title = "Q1 2025 目标"
    var items = [
        "销售额：600万",
        "新客户：60家",
        "市场占有率：提升5%",
    ]
}

@main
struct Runner {
    static func main() async {
        print("📊 生成演示文稿: 销售报告")
        print("========================")

        let fileManager = FileManager.default
        let outputsDir = "../../Outputs"

        do {
            try fileManager.createDirectory(
                atPath: outputsDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("📁 输出目录: \(outputsDir)")
        } catch {
            print("⚠️ 警告: 无法创建输出目录")
        }

        let presentation = SwiftSlidePresentation()
        let outputPath = outputsDir + "/\(presentation.title).pptx"

        print("")
        print("📊 演示文稿结构:")
        print("   标题: \(presentation.title)")
        print("   作者: \(presentation.author ?? "N/A")")
        print("   章节数: \(presentation.sections.count)")

        var totalSlides = 0
        for section in presentation.sections {
            totalSlides += section.slides.count
            print("   - \(section.title): \(section.slides.count) 页")
        }
        print("   总计: \(totalSlides) 页")

        print("")
        print("🚀 正在生成 PPTX...")

        do {
            try await presentation.generatePPTX(outputPath: outputPath)
            print("")
            print("✅ 成功!")
            print("📄 输出: \(outputPath)")
        } catch {
            print("")
            print("❌ 生成失败")
            print("   错误: \(error)")
            exit(1)
        }
    }
}
