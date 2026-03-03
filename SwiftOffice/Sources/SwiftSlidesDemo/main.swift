import Foundation
import SwiftSlides

@main
@available(macOS 13.0, *)
struct SwiftSlidesDemo {
    static func main() async throws {
        let demo = 创建综合演示()
        let json = try demo.toJSON()
        
        let outputDir = "output"
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        let jsonPath = "\(outputDir)/demo.json"
        try json.write(toFile: jsonPath, atomically: true, encoding: String.Encoding.utf8)
        
        print("JSON saved to: \(jsonPath)")
        print("Sections: \(demo.sections.count)")
        print("Total slides: \(demo.sections.reduce(0) { $0 + $1.slides.count })")
        
        try await 创建CSV演示()
        
        try await 创建Gantt演示()
        
        print("\nGenerating PPTX files...")
        try await demo.toPPTX(outputPath: "output/demo.pptx")
        print("PPTX generated: output/demo.pptx")
    }
    
    static func 创建CSV演示() async throws {
        let csv内容 = """
        月份,销售额,成本,利润
        一月,125000,85000,40000
        二月,138000,92000,46000
        三月,142000,88000,54000
        四月,156000,95000,61000
        五月,168000,102000,66000
        六月,175000,108000,67000
        """
        
        let 数据 = try 表格数据.从CSV内容(csv内容)
        
        let presentation = 演示文稿(标题: "CSV数据导入演示", 作者: "SwiftSlides", 主题: .商务绿) {
            章节(标题: "数据导入演示") {
                封面页(标题: "CSV数据自动生成报告", 副标题: "从数据到演示文稿", 渐变: .绿色)
                
                幻灯片.表格(标题: "销售数据表", 数据: 数据)
                
                幻灯片.柱状图(标题: "月度销售额", 数据: 数据, 标签列: "月份", 数值列: "销售额", Y轴: "金额(元)")!
                
                幻灯片.折线图(标题: "利润趋势", 数据: 数据, 标签列: "月份", 数值列: "利润", Y轴: "利润(元)")!
                
                数据.转换为多系列柱状图(标题: "销售额与成本对比", 标签列: "月份", 数值列列表: ["销售额", "成本"], Y轴: "金额(元)")!
                
                结束页(标题: "谢谢！", 副标题: "数据驱动演示")
            }
        }
        
        let json = try presentation.toJSON()
        try json.write(toFile: "output/csv_demo.json", atomically: true, encoding: String.Encoding.utf8)
        print("\nCSV Demo saved to: output/csv_demo.json")
        print("CSV Demo slides: \(presentation.sections.reduce(0) { $0 + $1.slides.count })")
        
        try await 创建模板演示()
    }
    
    static func 创建模板演示() async throws {
        let csv内容 = """
        季度,收入,支出,利润
        Q1,1250000,850000,400000
        Q2,1380000,920000,460000
        Q3,1520000,980000,540000
        Q4,1680000,1050000,630000
        """
        
        let 数据 = try 表格数据.从CSV内容(csv内容)
        
        let presentation = 演示文稿(标题: "模板演示", 作者: "SwiftSlides", 主题: .专业蓝) {
            章节(标题: "模板展示") {
                封面页(标题: "模板功能演示", 副标题: "快速创建专业演示文稿", 渐变: .蓝色)
                
                幻灯片.表格(标题: "季度财务数据", 数据: 数据)
                
                幻灯片.柱状图(标题: "季度收入", 数据: 数据, 标签列: "季度", 数值列: "收入", Y轴: "金额(元)")!
                
                结束页(标题: "完成！", 副标题: "模板功能展示")
            }
        }
        
        let json = try presentation.toJSON()
        try json.write(toFile: "output/template_demo.json", atomically: true, encoding: String.Encoding.utf8)
        print("\nTemplate Demo saved to: output/template_demo.json")
        print("Template Demo slides: \(presentation.sections.reduce(0) { $0 + $1.slides.count })")
    }
    
    static func 创建Mermaid演示() async throws {
        let 流程图 = Mermaid流程图(
            方向: .从上到下,
            节点: [
                Mermaid节点(id: "A", 标签: "开始", 形状: .圆形),
                Mermaid节点(id: "B", 标签: "数据收集", 形状: .矩形),
                Mermaid节点(id: "C", 标签: "数据分析", 形状: .矩形),
                Mermaid节点(id: "D", 标签: "生成报告", 形状: .矩形),
                Mermaid节点(id: "E", 标签: "结束", 形状: .圆形),
            ],
            连线: [
                Mermaid连线(从: "A", 到: "B"),
                Mermaid连线(从: "B", 到: "C", 标签: "数据就绪"),
                Mermaid连线(从: "C", 到: "D", 标签: "分析完成"),
                Mermaid连线(从: "D", 到: "E"),
            ],
            配置: .大字体
        )
        
        let 时序图 = Mermaid时序图(
            参与者: ["用户", "系统", "数据库"],
            消息: [
                Mermaid消息(从: "用户", 到: "系统", 内容: "登录请求"),
                Mermaid消息(从: "系统", 到: "数据库", 内容: "查询用户信息"),
                Mermaid消息(从: "数据库", 到: "系统", 内容: "返回用户数据", 类型: .虚线箭头),
                Mermaid消息(从: "系统", 到: "用户", 内容: "登录成功", 类型: .虚线箭头),
            ],
            配置: .大字体
        )
        
        let 甘特图 = Mermaid甘特图(
            标题: "项目进度计划",
            任务: [
                Mermaid任务(名称: "需求分析", 状态: .已完成, 开始: "2024-01-01", 结束: "2024-01-15"),
                Mermaid任务(名称: "系统设计", 状态: .已完成, 开始: "2024-01-16", 结束: "2024-02-15"),
                Mermaid任务(名称: "开发实现", 状态: .进行中, 开始: "2024-02-16", 结束: "2024-04-30"),
                Mermaid任务(名称: "测试验收", 状态: .待办, 开始: "2024-05-01", 结束: "2024-05-31"),
                Mermaid任务(名称: "上线部署", 状态: .关键, 开始: "2024-06-01", 结束: "2024-06-15"),
            ],
            配置: .大字体
        )
        
        let presentation = 演示文稿(标题: "Mermaid图表演示", 作者: "SwiftSlides", 主题: .科技紫) {
            章节(标题: "Mermaid图表") {
                封面页(标题: "Mermaid图表演示", 副标题: "复杂图表自动生成", 渐变: .紫色)
                
                Mermaid流程图页(标题: "业务流程图", 流程图: 流程图)
                
                Mermaid时序图页(标题: "系统交互时序图", 时序图: 时序图)
                
                Mermaid甘特图页(标题: "项目进度甘特图", 甘特图: 甘特图)
                
                结束页(标题: "谢谢！", 副标题: "Mermaid让图表更简单")
            }
        }
        
        let mermaidJson = try presentation.toJSON()
        try mermaidJson.write(toFile: "output/mermaid_demo.json", atomically: true, encoding: String.Encoding.utf8)
        print("\nMermaid Demo saved to: output/mermaid_demo.json")
        print("Mermaid Demo slides: \(presentation.sections.reduce(0) { $0 + $1.slides.count })")
        
        try await 创建Gantt演示()
    }
    
    static func 创建Gantt演示() async throws {
        let 日历 = Calendar.current
        let 今天 = Date()
        
        let gantt图表 = Gantt图表(
            标题: "项目开发计划",
            任务: [
                Gantt任务(名称: "需求分析", 开始日期: 日历.date(byAdding: .day, value: 0, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 6, to: 今天)!, 进度: 1.0),
                Gantt任务(名称: "架构设计", 开始日期: 日历.date(byAdding: .day, value: 5, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 12, to: 今天)!, 进度: 0.8),
                Gantt任务(名称: "前端开发", 开始日期: 日历.date(byAdding: .day, value: 10, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 25, to: 今天)!, 进度: 0.5),
                Gantt任务(名称: "后端开发", 开始日期: 日历.date(byAdding: .day, value: 10, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 28, to: 今天)!, 进度: 0.3),
                Gantt任务(名称: "测试验收", 开始日期: 日历.date(byAdding: .day, value: 26, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 35, to: 今天)!, 进度: 0),
                Gantt任务(名称: "部署上线", 开始日期: 日历.date(byAdding: .day, value: 34, to: 今天)!, 结束日期: 日历.date(byAdding: .day, value: 40, to: 今天)!, 进度: 0),
            ]
        )
        
        let presentation = 演示文稿(标题: "SwiftUI甘特图演示", 作者: "SwiftSlides", 主题: .科技紫) {
            章节(标题: "甘特图") {
                封面页(标题: "SwiftUI甘特图", 副标题: "原生渲染，高清输出", 渐变: .绿色)
                
                Gantt图页(标题: "项目开发进度", 甘特图: gantt图表)
                
                结束页(标题: "完成！", 副标题: "SwiftUI绘图能力展示")
            }
        }
        
        let ganttJson = try presentation.toJSON()
        try ganttJson.write(toFile: "output/gantt_demo.json", atomically: true, encoding: String.Encoding.utf8)
        print("\nGantt Demo saved to: output/gantt_demo.json")
        print("Gantt Demo slides: \(presentation.sections.reduce(0) { $0 + $1.slides.count })")
    }
    
    @SectionBuilder
    static var sections: [any Section] {
        章节(标题: "第一部分：数据展示风格") {
            封面页(标题: "医院管理数据分析报告", 副标题: "基于goodhospital2021案例", 渐变: .蓝色)
            
            卡片页(标题: "项目概览", 卡片: [
                SwiftSlides.卡片(标题: "参评机构", 内容: "14家医疗机构"),
                SwiftSlides.卡片(标题: "参评学科", 内容: "76个部门"),
                SwiftSlides.卡片(标题: "评价周期", 内容: "2021年12月-2022年6月"),
                SwiftSlides.卡片(标题: "数据质量", 内容: "全部校验通过"),
            ], 列数: 2)
            
            表格页(标题: "学科分组结果",
                表头: ["分组", "学科数量", "说明"],
                行: [
                    ["A组", "15", "综合评分前20%"],
                    ["B组", "30", "综合评分中段"],
                    ["C组", "31", "综合评分后段"],
                ])
        }
        
        章节(标题: "第二部分：文字图表风格") {
            章节页(编号: "第二部分", 标题: "文字图表风格", 副标题: "基于md_sources教案")
            
            定义页(标题: "医疗质量概念", 定义: """
                医疗质量是指医疗服务在满足患者及其家属健康需求方面所达到的程度，包括医疗技术质量和服务质量。
                
                狭义：诊疗质量
                广义：技术+服务+管理+环境
                """)
            
            架构图页(标题: "医疗质量管理体系架构", 层次: [
                .顶层(项目: ["质量方针", "质量目标", "质量文化"]),
                .中层(项目: ["质量组织", "质量制度", "质量流程"]),
                .底层(项目: ["质量控制", "质量保证", "质量改进"]),
            ])
            
            流程图页(标题: "PDCA循环", 步骤: ["计划", "执行", "检查", "处理"], 循环: true)
        }
        
        章节(标题: "总结") {
            引用页(引言: "医院管理者的使命，是在变革中把握方向，在挑战中创造价值。", 作者: "课程寄语")
            结束页(标题: "谢谢！", 副标题: "SwiftSlides 框架演示")
        }
    }
    
    static func 创建综合演示() -> 演示文稿 {
        演示文稿(标题: "综合演示报告", 作者: "SwiftSlides 框架演示", 主题: .医疗蓝) {
            章节(标题: "第一部分：数据展示风格") {
                封面页(标题: "医院管理数据分析报告", 副标题: "基于goodhospital2021案例", 渐变: .蓝色)
                
                幻灯片.概览(项目: [
                    ("参评机构", "14家医疗机构"),
                    ("参评学科", "76个部门"),
                    ("评价周期", "2021年12月-2022年6月"),
                    ("数据质量", "全部校验通过"),
                ])
                
                幻灯片.表格(
                    标题: "学科分组结果",
                    数据: [
                        ["分组", "学科数量", "说明"],
                        ["A组", "15", "综合评分前20%"],
                        ["B组", "30", "综合评分中段"],
                        ["C组", "31", "综合评分后段"],
                    ]
                )
            }
            
            章节(标题: "第二部分：文字图表风格") {
                章节页(编号: "第二部分", 标题: "文字图表风格", 副标题: "基于md_sources教案")
                
                定义页(标题: "医疗质量概念", 定义: """
                    医疗质量是指医疗服务在满足患者及其家属健康需求方面所达到的程度，包括医疗技术质量和服务质量。
                    
                    狭义：诊疗质量
                    广义：技术+服务+管理+环境
                    """)
                
                架构图页(标题: "医疗质量管理体系架构", 层次: [
                    .顶层(项目: ["质量方针", "质量目标", "质量文化"]),
                    .中层(项目: ["质量组织", "质量制度", "质量流程"]),
                    .底层(项目: ["质量控制", "质量保证", "质量改进"]),
                ])
                
                流程图页(标题: "PDCA循环", 步骤: ["计划", "执行", "检查", "处理"], 循环: true)
                
                幻灯片.柱状图(
                    标题: "学科评分分布",
                    标签: ["A组", "B组", "C组"],
                    系列: [
                        幻灯片.数据系列("平均分", 92.5, 85.3, 78.6),
                        幻灯片.数据系列("最高分", 98.2, 94.1, 89.5),
                    ],
                    Y轴: "分数"
                )
                
                幻灯片.饼图(
                    标题: "学科分布",
                    标签: ["内科", "外科", "妇产", "儿科"],
                    数值: [35, 28, 20, 17]
                )
                
                幻灯片.柱状图(
                    标题: "月度趋势",
                    数据: [
                        ("一月", 85), ("二月", 92), ("三月", 88),
                        ("四月", 95), ("五月", 91), ("六月", 97)
                    ],
                    Y轴: "评分"
                )
            }
            
            章节(标题: "总结") {
                引用页(引言: "医院管理者的使命，是在变革中把握方向，在挑战中创造价值。", 作者: "课程寄语")
                结束页(标题: "谢谢！", 副标题: "SwiftSlides 框架演示")
            }
        }
    }
}
