import Foundation
import SwiftSlides

// ============================================
// 用户内容定义
// ============================================

struct 医院管理总览: Presentation {
    var title = "医院管理总览"
    var author: String? = "张三"
    var theme: 主题? = nil
    var sections: [any Section] = [
        封面章节(),
        历史沿革章节(),
    ]
}

struct 封面章节: Section {
    var title = "封面"
    var slides: [any Slide] = [
        封面页(),
    ]
}

struct 历史沿革章节: Section {
    var title = "历史沿革"
    var slides: [any Slide] = [
        章节首页(),
        古代医院(),
        现代医院(),
    ]
}

struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "张三"
}

struct 章节首页: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

struct 古代医院: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理",
        "公元100年：罗马建立第一所公立医院",
    ]
}

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
