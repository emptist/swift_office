import Foundation
import SwiftSlides

// ============================================
// Protocol Composition 模式测试
// ============================================
//
// 测试新协议设计：
// 1. let 属性（不可变）
// 2. fellowSlides 层级嵌套
// 3. Protocol 组合
// ============================================

// MARK: - 演示文稿定义

struct 医院管理总览: Presentation {
    let title = "医院管理总览"
    let author: String? = "JK"
    let sections: [any Section] = [
        第一部分(),
        第二部分(),
    ]
}

// MARK: - 章节定义

struct 第一部分: Section {
    let title = "第一部分"
    let slides: [any Slide] = [
        第一章_医院的历史由来(),
        第二章_中国医院的发展历程(),
    ]
}

struct 第二部分: Section {
    let title = "第二部分"
    let slides: [any Slide] = [
        项目进度甘特图(),
    ]
}

// MARK: - 幻灯片定义（带层级嵌套）

struct 第一章_医院的历史由来: Slide, 章节首页样式 {
    let title = "医院的历史由来"
    let chapterNumber: Int? = 1
    let fellowSlides: [any Slide] = [
        第一节_古今纵横(),
        第二节_制度类型(),
    ]
}

struct 第一节_古今纵横: Slide, 带子幻灯片样式 {
    let title = "古今纵横"
    let fellowSlides: [any Slide] = [
        医院出现之前(),
        黑暗时代(),
        现代医院的诞生(),
        AI时代的挑战(),
        后AI时代的展望(),
    ]
}

struct 第二节_制度类型: Slide, 带子幻灯片样式 {
    let title = "制度类型"
    let fellowSlides: [any Slide] = [
        传统制度(),
        现代制度(),
    ]
}

struct 第二章_中国医院的发展历程: Slide, 章节首页样式 {
    let title = "中国医院的发展历程"
    let chapterNumber: Int? = 2
    let fellowSlides: [any Slide] = [
        第一节_中国现代医院的起源(),
    ]
}

struct 第一节_中国现代医院的起源: Slide, 带子幻灯片样式 {
    let title = "中国现代医院的起源"
    let fellowSlides: [any Slide] = [
        中国医院的前身(),
        中国医院的发展(),
    ]
}

// MARK: - 叶子节点幻灯片

struct 医院出现之前: Slide, 纯文本样式 {
    let title = "医院出现之前"
    let content = "在正式医院出现之前，医疗活动主要在家庭、寺庙和宗教场所进行..."
}

struct 黑暗时代: Slide, 纯文本样式 {
    let title = "黑暗时代"
    let content = "中世纪欧洲的医疗主要由修道院承担..."
}

struct 现代医院的诞生: Slide, 纯文本样式 {
    let title = "现代医院的诞生"
    let content = "18-19世纪，现代医院制度逐步确立..."
}

struct AI时代的挑战: Slide, 纯文本样式 {
    let title = "AI时代的挑战"
    let content = "人工智能正在深刻改变医疗行业..."
}

struct 后AI时代的展望: Slide, 纯文本样式 {
    let title = "后AI时代的展望"
    let content = "未来医疗将更加个性化、精准化..."
}

struct 传统制度: Slide, 内容样式 {
    let title = "传统制度"
    let items = [
        "宗教医院：由教会管理",
        "慈善医院：依靠捐赠运营",
        "公立医院：政府主导",
    ]
}

struct 现代制度: Slide, 内容样式 {
    let title = "现代制度"
    let items = [
        "公立医院：政府主导",
        "私立医院：市场化运营",
        "混合所有制：多元投资",
    ]
}

struct 中国医院的前身: Slide, 纯文本样式 {
    let title = "中国医院的前身"
    let content = "中国古代医疗体系以御医院、惠民局为主..."
}

struct 中国医院的发展: Slide, 纯文本样式 {
    let title = "中国医院的发展"
    let content = "新中国成立后，建立了完善的医疗卫生体系..."
}

// MARK: - 甘特图幻灯片

struct 项目进度甘特图: Slide, 甘特图样式 {
    let title = "项目进度"
    let ganttTitle = "医院信息化建设进度"
    let ganttTasks: [SlideGanttTask] = [
        SlideGanttTask(name: "需求分析", status: .done, start: "2024-01-01", end: "2024-01-15"),
        SlideGanttTask(name: "系统设计", status: .done, start: "2024-01-16", end: "2024-02-15"),
        SlideGanttTask(name: "开发阶段", status: .active, start: "2024-02-16", end: "2024-04-30"),
        SlideGanttTask(name: "测试验收", status: .pending, start: "2024-05-01", end: "2024-05-31"),
        SlideGanttTask(name: "上线部署", status: .critical, start: "2024-06-01", end: "2024-06-15"),
    ]
}

// MARK: - 运行器

@main
struct TestRunner {
    static func main() async {
        print("========================================")
        print("Protocol Composition 模式测试")
        print("========================================")
        print("")
        
        let presentation = 医院管理总览()
        
        print("📊 演示文稿: \(presentation.title)")
        print("👤 作者: \(presentation.author ?? "N/A")")
        print("📁 章节数: \(presentation.sections.count)")
        print("")
        
        for section in presentation.sections {
            print("📂 \(section.title)")
            for slide in section.slides {
                printSlideTree(slide, indent: 2)
            }
        }
        
        print("")
        print("📄 总幻灯片数（含嵌套）: \(presentation.allSlides().count)")
        
        print("")
        print("📝 JSON 输出:")
        do {
            let json = try presentation.toJSON()
            print(json.prefix(800))
            print("...")
            
            let outputDir = "Outputs"
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/\(presentation.title).json"
            try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("")
            print("✅ JSON 已保存: \(outputPath)")
            
            print("")
            print("📊 甘特图 Mermaid 代码:")
            if let ganttSlide = presentation.allSlides().first(where: { $0 is any 甘特图样式 }) as? any 甘特图样式 {
                print(ganttSlide.generateMermaidCode())
            }
        } catch {
            print("❌ 错误: \(error)")
        }
    }
    
    static func printSlideTree(_ slide: any Slide, indent: Int) {
        let prefix = String(repeating: " ", count: indent)
        let hasChildren = !slide.fellowSlides.isEmpty
        let icon = hasChildren ? "└─📁" : "└─📄"
        print("\(prefix)\(icon) \(slide.title)")
        
        for child in slide.fellowSlides {
            printSlideTree(child, indent: indent + 4)
        }
    }
}
