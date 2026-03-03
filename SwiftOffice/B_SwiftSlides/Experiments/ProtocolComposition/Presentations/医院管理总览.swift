import SwiftSlidesCore
import Foundation

// ============================================
// 医院管理总览.pptx
// ============================================

struct SwiftSlidePresentation: Presentation {
    var title = "医院管理总览"
    var author: String? = "医院管理部"

    var sections: [Section] = [
        封面章节(),
        历史沿革章节(),
        现状分析章节(),
        未来展望章节(),
    ]
}

struct 封面章节: Section {
    var title = "封面"
    var slides: [Slide] = [
        封面页(),
    ]
}

struct 历史沿革章节: Section {
    var title = "历史沿革"
    var slides: [Slide] = [
        历史沿革章节首页(),
        古代医院(),
        近代医院(),
        现代医院(),
    ]
}

struct 现状分析章节: Section {
    var title = "现状分析"
    var slides: [Slide] = [
        现状分析章节首页(),
        床位使用率(),
        患者满意度(),
        医疗质量指标(),
    ]
}

struct 未来展望章节: Section {
    var title = "未来展望"
    var slides: [Slide] = [
        未来展望章节首页(),
        发展规划(),
        智慧医院建设(),
    ]
}

struct 封面页: Slide, 封面样式 {
    var title = "医院管理总览"
    var subtitle: String? = "2024年度报告"
    var author: String? = "医院管理部"
}

struct 历史沿革章节首页: Slide, 章节样式 {
    var title = "历史沿革"
    var chapterNumber: Int? = 1
}

struct 现状分析章节首页: Slide, 章节样式 {
    var title = "现状分析"
    var chapterNumber: Int? = 2
}

struct 未来展望章节首页: Slide, 章节样式 {
    var title = "未来展望"
    var chapterNumber: Int? = 3
}

struct 古代医院: Slide, 内容样式 {
    var title = "古代医院"
    var items = [
        "公元前400年：希波克拉底创立医学伦理，奠定西方医学基础",
        "公元100年：罗马建立第一所公立医院，服务平民百姓",
        "公元800年：阿拉伯帝国建立医院体系，推动医学教育发展",
        "公元1100年：欧洲建立修道院医院，提供宗教和医疗服务",
    ]
}

struct 近代医院: Slide, 内容样式 {
    var title = "近代医院"
    var items = [
        "19世纪初：现代医院制度确立，专业化分工开始",
        "19世纪中期：南丁格尔改革护理制度，提升护理质量",
        "19世纪末：X射线发现，医学影像技术诞生",
        "20世纪初：抗生素发现，感染性疾病治疗革命",
    ]
}

struct 现代医院: Slide, 内容样式 {
    var title = "现代医院"
    var items = [
        "信息化管理：电子病历、HIS系统全面应用",
        "精准医疗：基因检测、个性化治疗方案",
        "微创技术：腹腔镜、机器人手术普及",
        "智慧医院：AI辅助诊断、远程医疗服务",
    ]
}

struct 床位使用率: Slide, 内容样式 {
    var title = "床位使用率分析"
    var items = [
        "总体使用率：85%，处于合理区间",
        "内科床位：92%，需求紧张",
        "外科床位：78%，资源充足",
        "优化建议：调整科室床位配置",
    ]
}

struct 患者满意度: Slide, 内容样式 {
    var title = "患者满意度调查"
    var items = [
        "总体满意度：4.5/5.0，高于行业平均",
        "医疗服务：4.6/5.0，专业水平获认可",
        "就医环境：4.3/5.0，设施持续改善",
        "改进方向：缩短候诊时间、优化预约流程",
    ]
}

struct 医疗质量指标: Slide, 内容样式 {
    var title = "医疗质量指标"
    var items = [
        "手术成功率：98.5%，达到国内先进水平",
        "院内感染率：0.8%，低于国家标准",
        "平均住院日：7.2天，效率持续提升",
        "再入院率：5.3%，随访管理加强",
    ]
}

struct 发展规划: Slide, 内容样式 {
    var title = "五年发展规划"
    var items = [
        "床位规模：从800张扩展到1200张",
        "重点专科：建设5个国家级重点专科",
        "人才队伍：引进100名高层次人才",
        "科研能力：年发表SCI论文100篇以上",
    ]
}

struct 智慧医院建设: Slide, 内容样式 {
    var title = "智慧医院建设"
    var items = [
        "AI辅助诊疗：影像AI、病理AI全面部署",
        "互联网医院：在线问诊、药品配送服务",
        "大数据平台：临床决策支持系统建设",
        "物联网应用：智能输液、智能监护系统",
    ]
}

@main
struct Runner {
    static func main() async {
        print("🏥 生成演示文稿: 医院管理总览")
        print("============================")

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
