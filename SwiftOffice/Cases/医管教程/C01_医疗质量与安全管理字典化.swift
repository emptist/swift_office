import Foundation
import SwiftSlides

// ============================================
// 医院医疗质量与安全管理课程
// ============================================
//
// 这是一个实际教案的 Swift 实现
// 用于测试 API 是否足够自然、易用
// ============================================

// MARK: - 课程元数据

struct 课程信息 {
    let 名称 = "医院医疗质量与安全管理"
    let 定位 = "医院管理核心模块课程"
    let 时长 = "12小时（2天）"
    let 对象 = [
        "医院院长、分管副院长",
        "质控部主任、医务部主任",
        "护理部主任、临床科室主任",
    ]
    let 方法 = ["理论讲授", "方法演练", "案例分析", "课堂讨论", "实操练习"]
}

// MARK: - 课程目标

struct 课程目标 {
    struct 知识目标 {
        let items = [
            "掌握医疗质量管理体系的构成",
            "熟悉质量管理工具与方法",
            "了解患者安全目标与措施",
        ]
    }
    
    struct 能力目标 {
        let items = [
            "能够建立质量管理体系",
            "能够运用质量管理工具",
            "能够处理质量安全事件",
        ]
    }
    
    struct 素质目标 {
        let items = [
            "培养质量安全意识",
            "提升质量管理能力",
        ]
    }
}

// MARK: - 演示文稿定义

//// 首先，抽象出两个必备的要素：title + content 
//// 或者使用中文，标题，内容
// 第二步， 所有的内容，都是字典，至于如何呈现，看幻灯片遵从什么协议
// 如果字典有限制，那可以是 tuple （任意:type,都: “可以）
struct 医疗质量与安全管理课程: Presentation, 简单封面 {
    // 标题
    let title = "医院医疗质量与安全管理"
    // 内容 [auther:"xxxx",章节:[各章节]]
    let author: String? = "医管培训中心"
    let sections: [any Section] = [
        课程概述章节(),
        第一章_医疗质量管理概述(),
        第二章_医疗质量管理体系(),
        第三章_质量管理工具与方法(),
        第四章_患者安全目标与措施(),
        第五章_重点环节质量管理(),
    ]
}

// MARK: - 课程概述章节

struct 课程概述章节: Section {
    // 标题
    let title = "课程概述"
    // 内容 （slides: [,]
    let slides: [any Slide] = [
        课程信息页(),
        课程目标页(),
    ]
}

struct 课程信息页: Slide, 封面样式 {
    let title = "医院医疗质量与安全管理"
    let subtitle: String? = "医院管理核心模块课程 · 12小时"
    let author: String? = "医管培训中心"
}

struct 课程目标页: Slide, 内容样式 {
    let title = "课程目标"
    let items = [
        "【知识】掌握质量管理体系、工具方法、安全目标",
        "【能力】建立体系、运用工具、处理事件",
        "【素质】质量安全意识、质量管理能力",
    ]
}

// MARK: - 第一章：医疗质量管理概述

struct 第一章_医疗质量管理概述: Section {
    let title = "第一章"
    let slides: [any Slide] = [
        第一章首页(),
        第一节_医疗质量概念(),
        第二节_质量管理体系(),
        第三节_管理趋势(),
    ]
}

struct 第一章首页: Slide, 章节首页样式 {
    let title = "医疗质量管理概述"
    let chapterNumber: Int? = 1
}

struct 第一节_医疗质量概念: Slide, 带子幻灯片样式 {
    let title = "医疗质量概念"
    let fellowSlides: [any Slide] = [
        医疗质量定义页(),
        医疗质量维度页(),
    ]
}

struct 医疗质量定义页: Slide, 纯文本样式 {
    let title = "医疗质量定义"
    let content = """
    医疗质量是指医疗服务在满足患者及其家属健康需求方面所达到的程度，包括医疗技术质量和服务质量。
    
    狭义：诊疗质量
    广义：技术+服务+管理+环境
    """
}

struct 医疗质量维度页: Slide, 表格样式 {
    let title = "医疗质量维度"
    let headers = ["维度", "内容"]
    let rows = [
        ["结构质量", "人员、设备、制度、环境"],
        ["过程质量", "诊疗流程、操作规范"],
        ["结果质量", "诊疗效果、患者结局"],
    ]
}

struct 第二节_质量管理体系: Slide, 带子幻灯片样式 {
    let title = "医疗质量管理体系"
    let fellowSlides: [any Slide] = [
        体系架构页(),
    ]
}

struct 体系架构页: Slide, 层次架构图样式 {
    let title = "质量管理体系架构"
    let hierarchyRoot: SlideHierarchyNode = SlideHierarchyNode(
        id: "root",
        title: "医疗质量管理体系",
        children: [
            SlideHierarchyNode(
                id: "top",
                title: "顶层设计",
                subtitle: "质量方针、质量目标、质量文化",
                children: [
                    SlideHierarchyNode(
                        id: "mid",
                        title: "中层管理",
                        subtitle: "质量组织、质量制度、质量流程",
                        children: [
                            SlideHierarchyNode(
                                id: "bottom",
                                title: "基层执行",
                                subtitle: "质量控制、质量保证、质量改进"
                            )
                        ]
                    )
                ]
            )
        ]
    )
}

struct 第三节_管理趋势: Slide, 表格样式 {
    let title = "管理发展趋势"
    let headers = ["趋势", "内容"]
    let rows = [
        ["科学化", "数据驱动、循证决策"],
        ["精细化", "精准诊疗、个体化"],
        ["信息化", "智能质控、实时监测"],
        ["患者为中心", "体验、质量、安全"],
    ]
}

// MARK: - 第二章：医疗质量管理体系

struct 第二章_医疗质量管理体系: Section {
    let title = "第二章"
    let slides: [any Slide] = [
        第二章首页(),
        第一节_体系架构(),
        第二节_组织架构与职责(),
        第三节_质量管理制度(),
    ]
}

struct 第二章首页: Slide, 章节首页样式 {
    let title = "医疗质量管理体系"
    let chapterNumber: Int? = 2
}

struct 第一节_体系架构: Slide, 带子幻灯片样式 {
    let title = "质量管理体系架构"
    let fellowSlides: [any Slide] = [
        质量管理原则页(),
        体系文件层级页(),
    ]
}

struct 质量管理原则页: Slide, 表格样式 {
    let title = "质量管理原则"
    let headers = ["原则", "说明"]
    let rows = [
        ["患者导向", "以患者安全为中心"],
        ["领导重视", "最高管理者主导"],
        ["全员参与", "质量安全，人人有责"],
        ["过程方法", "关注过程、关注结果"],
        ["持续改进", "永无止境、追求卓越"],
    ]
}

struct 体系文件层级页: Slide, 内容样式 {
    let title = "质量管理体系文件层级"
    let items = [
        "第一层：质量手册（质量方针、质量目标、体系框架）",
        "第二层：程序文件（管理制度、操作流程）",
        "第三层：作业指导书（操作规范、技术标准）",
        "第四层：质量记录（表单、报表、档案）",
    ]
}

struct 第二节_组织架构与职责: Slide, 带子幻灯片样式 {
    let title = "组织架构与职责"
    let fellowSlides: [any Slide] = [
        质量管理组织页(),
        各层级质量职责页(),
    ]
}

struct 质量管理组织页: Slide, 表格样式 {
    let title = "质量管理组织"
    let headers = ["组织", "职责"]
    let rows = [
        ["质量管理委员会", "决策、统筹"],
        ["质控部门", "日常管理"],
        ["科室质控小组", "科室落实"],
        ["全院职工", "具体执行"],
    ]
}

struct 各层级质量职责页: Slide, 内容样式 {
    let title = "各层级质量职责"
    let items = [
        "院级层面：制定方针目标、配置资源保障、考核评价监督",
        "职能部门：落实质量制度、日常监督检查、问题分析改进",
        "科室层面：执行诊疗规范、科室自查自纠、持续改进提高",
    ]
}

struct 第三节_质量管理制度: Slide, 带子幻灯片样式 {
    let title = "质量管理制度"
    let fellowSlides: [any Slide] = [
        核心制度页(),
        诊疗规范页(),
    ]
}

struct 核心制度页: Slide, 表格样式 {
    let title = "核心制度（18项医疗质量安全核心制度）"
    let headers = ["类别", "制度"]
    let rows = [
        ["首诊负责", "首诊负责制度"],
        ["三级查房", "三级查房制度"],
        ["会诊制度", "科间会诊、多学科会诊"],
        ["手术安全", "手术安全核查制度"],
        ["病历书写", "病历书写规范"],
        ["危急值", "危急值报告制度"],
    ]
}

struct 诊疗规范页: Slide, 表格样式 {
    let title = "诊疗规范"
    let headers = ["规范类型", "内容"]
    let rows = [
        ["临床路径", "标准化诊疗流程"],
        ["诊疗指南", "疾病诊疗规范"],
        ["操作常规", "技术操作标准"],
    ]
}

// MARK: - 第三章：质量管理工具与方法

struct 第三章_质量管理工具与方法: Section {
    let title = "第三章"
    let slides: [any Slide] = [
        第三章首页(),
        第一节_PDCA循环(),
        第二节_常用工具(),
        第三节_临床路径(),
    ]
}

struct 第三章首页: Slide, 章节首页样式 {
    let title = "质量管理工具与方法"
    let chapterNumber: Int? = 3
}

struct 第一节_PDCA循环: Slide, 带子幻灯片样式 {
    let title = "PDCA循环"
    let fellowSlides: [any Slide] = [
        PDCA循环图页(),
        PDCA应用页(),
    ]
}

struct PDCA循环图页: Slide, 循环流程图样式 {
    let title = "PDCA循环"
    let cycleSteps: [SlideCycleStep] = [
        SlideCycleStep(id: "P", title: "PLAN", description: "计划：分析现状、找问题、制定计划"),
        SlideCycleStep(id: "D", title: "DO", description: "执行：实施计划、落实措施"),
        SlideCycleStep(id: "C", title: "CHECK", description: "检查：检查效果、发现问题"),
        SlideCycleStep(id: "A", title: "ACTION", description: "处理：总结经验、标准化"),
    ]
}

struct PDCA应用页: Slide, 表格样式 {
    let title = "PDCA应用"
    let headers = ["阶段", "主要活动"]
    let rows = [
        ["P 计划", "分析现状、找问题、分析原因、制定计划"],
        ["D 执行", "实施计划、落实措施"],
        ["C 检查", "检查效果、发现问题"],
        ["A 处理", "总结经验、标准化、遗留问题入下轮"],
    ]
}

struct 第二节_常用工具: Slide, 带子幻灯片样式 {
    let title = "常用质量管理工具"
    let fellowSlides: [any Slide] = [
        鱼骨图页(),
        流程图页(),
        柏拉图页(),
    ]
}

struct 鱼骨图页: Slide, 表格样式 {
    let title = "鱼骨图（因果图）"
    let headers = ["用途", "分析问题原因"]
    let rows = [
        ["类别", "人、机、料、法、环、测"],
        ["应用", "质量问题根因分析"],
    ]
}

struct 流程图页: Slide, 表格样式 {
    let title = "流程图"
    let headers = ["类型", "用途"]
    let rows = [
        ["流程图", "描述过程步骤"],
        ["泳道图", "多部门流程"],
    ]
}

struct 柏拉图页: Slide, 柏拉图样式 {
    let title = "柏拉图（二八法则）"
    let paretoItems: [SlideParetoItem] = [
        SlideParetoItem(category: "核心问题", value: 80, cumulativePercent: 80),
        SlideParetoItem(category: "次要问题A", value: 12, cumulativePercent: 92),
        SlideParetoItem(category: "次要问题B", value: 5, cumulativePercent: 97),
        SlideParetoItem(category: "其他问题", value: 3, cumulativePercent: 100),
    ]
}

struct 第三节_临床路径: Slide, 带子幻灯片样式 {
    let title = "临床路径管理"
    let fellowSlides: [any Slide] = [
        临床路径概念页(),
        实施要点页(),
        效果评价页(),
    ]
}

struct 临床路径概念页: Slide, 表格样式 {
    let title = "临床路径概念"
    let headers = ["要素", "说明"]
    let rows = [
        ["定义", "标准化诊疗流程"],
        ["目标", "规范诊疗、保证质量、控制费用"],
        ["适用范围", "常见病、多发病"],
    ]
}

struct 实施要点页: Slide, 表格样式 {
    let title = "实施要点"
    let headers = ["指标", "要求"]
    let rows = [
        ["入径率", "≥70%"],
        ["完成率", "≥80%"],
        ["变异率", "≤10%"],
    ]
}

struct 效果评价页: Slide, 表格样式 {
    let title = "效果评价"
    let headers = ["评价维度", "内容"]
    let rows = [
        ["医疗质量", "诊疗规范性"],
        ["医疗效率", "平均住院日"],
        ["医疗费用", "次均费用"],
    ]
}

// MARK: - 第四章：患者安全目标与措施

struct 第四章_患者安全目标与措施: Section {
    let title = "第四章"
    let slides: [any Slide] = [
        第四章首页(),
        第一节_患者安全目标(),
        第二节_医疗安全风险(),
        第三节_不良事件管理(),
    ]
}

struct 第四章首页: Slide, 章节首页样式 {
    let title = "患者安全目标与措施"
    let chapterNumber: Int? = 4
}

struct 第一节_患者安全目标: Slide, 内容样式 {
    let title = "患者安全目标（2023版）"
    let items = [
        "1. 正确识别患者身份",
        "2. 强化手术安全核查",
        "3. 确保用药安全",
        "4. 减少医院相关性感染",
        "5. 落实患者安全不良事件报告制度",
        "6. 加强孕产妇和新生儿安全",
        "7. 预防和减少患者跌倒/坠床",
        "8. 加强医疗器械安全监管",
        "9. 提升用药安全水平",
        "10. 营造安全文化",
    ]
}

struct 第二节_医疗安全风险: Slide, 带子幻灯片样式 {
    let title = "医疗安全风险"
    let fellowSlides: [any Slide] = [
        不良事件类型页(),
        风险识别方法页(),
    ]
}

struct 不良事件类型页: Slide, 表格样式 {
    let title = "不良事件类型"
    let headers = ["类型", "例子"]
    let rows = [
        ["医源性伤害", "手术并发症、院内感染"],
        ["非医源性伤害", "患者跌倒、坠床"],
        ["系统错误", "流程缺陷、设备故障"],
    ]
}

struct 风险识别方法页: Slide, 内容样式 {
    let title = "医疗安全风险识别方法"
    let items = [
        "1. 不良事件报告（自愿报告、强制报告）",
        "2. 风险评估（事前评估、定期评估）",
        "3. 监督检查（日常巡查、专项检查）",
    ]
}

struct 第三节_不良事件管理: Slide, 带子幻灯片样式 {
    let title = "不良事件管理"
    let fellowSlides: [any Slide] = [
        报告制度页(),
        闭环管理流程页(),
    ]
}

struct 报告制度页: Slide, 表格样式 {
    let title = "报告制度"
    let headers = ["报告类型", "内容"]
    let rows = [
        ["可疑不良事件", "应当报告"],
        ["严重不良事件", "立即报告"],
        ["药品不良反应", "专门报告"],
    ]
}

struct 闭环管理流程页: Slide, 框图样式 {
    let title = "不良事件闭环管理"
    let boxes: [SlideBox] = [
        SlideBox(title: "1. 事件报告", content: ["发现事件", "填写报告", "提交系统"]),
        SlideBox(title: "2. 初步调查", content: ["收集信息", "核实情况", "初步判断"]),
        SlideBox(title: "3. 根本原因分析", content: ["鱼骨图分析", "5Why分析", "确定根因"]),
        SlideBox(title: "4. 改进措施", content: ["制定方案", "落实整改", "跟踪验证"]),
        SlideBox(title: "5. 效果评估", content: ["指标对比", "效果确认", "经验总结"]),
        SlideBox(title: "6. 标准化", content: ["制度修订", "流程优化", "培训推广"]),
    ]
    let boxLayout: SlideBoxLayout = .horizontal
}

// MARK: - 第五章：重点环节质量管理

struct 第五章_重点环节质量管理: Section {
    let title = "第五章"
    let slides: [any Slide] = [
        第五章首页(),
        第一节_核心制度落实(),
        第二节_重点环节管理(),
        第三节_护理质量管理(),
    ]
}

struct 第五章首页: Slide, 章节首页样式 {
    let title = "重点环节质量管理"
    let chapterNumber: Int? = 5
}

struct 第一节_核心制度落实: Slide, 表格样式 {
    let title = "核心制度（18项医疗质量安全核心制度）"
    let headers = ["制度", "要点"]
    let rows = [
        ["首诊负责", "首诊医师负责到底"],
        ["三级查房", "主任、主治、住院医"],
        ["会诊制度", "及时、准确"],
        ["手术安全核查", "三方核查、Time-out"],
        ["病历书写", "及时、完整、准确"],
        ["危急值", "接报即办"],
    ]
}

struct 第二节_重点环节管理: Slide, 带子幻灯片样式 {
    let title = "重点环节管理"
    let fellowSlides: [any Slide] = [
        围手术期管理页(),
        危急值管理页(),
    ]
}

struct 围手术期管理页: Slide, 内容样式 {
    let title = "围手术期安全管理"
    let items = [
        "术前：手术指征评估、手术知情同意、术前准备核查",
        "术中：手术安全核查、手术记录规范、术中应急处理",
        "术后：术后交接、术后访视、并发症防治",
    ]
}

struct 危急值管理页: Slide, 表格样式 {
    let title = "危急值管理"
    let headers = ["环节", "要求"]
    let rows = [
        ["报告", "及时、准确"],
        ["接收", "记录、复述"],
        ["处理", "立即响应"],
        ["追踪", "闭环管理"],
    ]
}

struct 第三节_护理质量管理: Slide, 内容样式 {
    let title = "护理质量管理"
    let items = [
        "护理质量指标监测",
        "护理不良事件管理",
        "护理文书质量管理",
        "护理安全管理",
    ]
}

// MARK: - 运行器

@main
struct 医管教程Runner {
    static func main() async {
        print("========================================")
        print("医院医疗质量与安全管理课程")
        print("========================================")
        print("")
        
        let presentation = 医疗质量与安全管理课程()
        
        print("📊 课程: \(presentation.title)")
        print("📁 章节数: \(presentation.sections.count)")
        
        var totalSlides = 0
        for section in presentation.sections {
            let slideCount = section.slides.count
            totalSlides += slideCount
            print("  📂 \(section.title) - \(slideCount) slides")
        }
        
        print("")
        print("📄 总幻灯片数: \(totalSlides)")
        print("📄 含嵌套幻灯片数: \(presentation.allSlides().count)")
        
        print("")
        print("📝 生成 JSON...")
        do {
            let json = try presentation.toJSON()
            
            let outputDir = "Cases/医管教程/Outputs"
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            let outputPath = "\(outputDir)/\(presentation.title).json"
            try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("✅ JSON 已保存: \(outputPath)")
            
            print("")
            print("📝 生成 PPTX...")
            let pptxPath = "\(outputDir)/\(presentation.title).pptx"
            try await presentation.generatePPTX(outputPath: pptxPath)
            print("✅ PPTX 已保存: \(pptxPath)")
        } catch {
            print("❌ 错误: \(error)")
        }
    }
}
