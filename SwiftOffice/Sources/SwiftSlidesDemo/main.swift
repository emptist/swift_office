import Foundation
import SwiftSlides

@main
@available(macOS 10.15, *)
struct SwiftSlidesDemo {
    static func main() throws {
        print("=== SwiftSlides 综合演示 ===\n")
        
        let demo = 创建综合演示()
        
        print("标题: \(demo.title)")
        print("作者: \(demo.author ?? "未知")")
        print("章节数: \(demo.sections.count)")
        
        var totalSlides = 0
        for section in demo.sections {
            totalSlides += section.slides.count
            print("  - \(section.title): \(section.slides.count) 张幻灯片")
        }
        print("总幻灯片数: \(totalSlides)\n")
        
        print("=== JSON 输出预览 ===\n")
        let json = try demo.toJSON()
        print(String(json.prefix(2000)))
        print("\n... (共 \(json.count) 字符)")
    }
    
    static func 创建综合演示() -> 演示文稿 {
        演示文稿(
            标题: "综合演示报告",
            作者: "SwiftSlides 框架演示",
            sections: [
                章节(标题: "第一部分：数据展示风格", slides: [
                    封面页(标题: "医院管理数据分析报告", 副标题: "基于goodhospital2021案例", 渐变: .蓝色),
                    
                    卡片页(标题: "项目概览", 卡片: [
                        SwiftSlides.卡片(标题: "参评机构", 内容: "14家医疗机构"),
                        SwiftSlides.卡片(标题: "参评学科", 内容: "76个部门"),
                        SwiftSlides.卡片(标题: "评价周期", 内容: "2021年12月-2022年6月"),
                        SwiftSlides.卡片(标题: "数据质量", 内容: "全部校验通过"),
                    ], 列数: 2),
                    
                    表格页(标题: "学科分组结果",
                        表头: ["分组", "学科数量", "说明"],
                        行: [
                            ["A组", "15", "综合评分前20%"],
                            ["B组", "30", "综合评分中段"],
                            ["C组", "31", "综合评分后段"],
                        ]),
                ]),
                
                章节(标题: "第二部分：文字图表风格", slides: [
                    章节页(编号: "第二部分", 标题: "文字图表风格", 副标题: "基于md_sources教案"),
                    
                    定义页(标题: "医疗质量概念", 定义: """
                        医疗质量是指医疗服务在满足患者及其家属健康需求方面所达到的程度，包括医疗技术质量和服务质量。
                        
                        狭义：诊疗质量
                        广义：技术+服务+管理+环境
                        """),
                    
                    架构图页(标题: "医疗质量管理体系架构", 层次: [
                        .顶层(项目: ["质量方针", "质量目标", "质量文化"]),
                        .中层(项目: ["质量组织", "质量制度", "质量流程"]),
                        .底层(项目: ["质量控制", "质量保证", "质量改进"]),
                    ]),
                    
                    流程图页(标题: "PDCA循环", 步骤: [
                        "计划",
                        "执行",
                        "检查",
                        "处理",
                    ], 循环: true),
                ]),
                
                章节(标题: "总结", slides: [
                    引用页(引言: "医院管理者的使命，是在变革中把握方向，在挑战中创造价值。", 作者: "课程寄语"),
                    
                    结束页(标题: "谢谢！", 副标题: "SwiftSlides 框架演示"),
                ]),
            ]
        )
    }
}
