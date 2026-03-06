import Foundation

@available(macOS 10.15, *)
public struct 项目报告模板: 演示文稿模板 {
    public var 模板名称: String { "项目报告" }
    public var 模板描述: String { "适用于项目进展、成果汇报等场景" }
    public var 默认主题: 主题 { .专业蓝 }
    
    public init() {}
    
    public func 生成(配置: 模板配置) -> any Presentation {
        let 主题 = 配置.主题 ?? 默认主题
        
        var sections: [any Section] = []
        
        sections.append(册(标题: "项目概述", slides: [
            封面页(标题: 配置.标题, 副标题: 配置.副标题, 渐变: .蓝色),
        ]))
        
        if let 数据 = 配置.数据源 {
            sections.append(册(标题: "数据分析", slides: [
                数据.转换为表格页(标题: "数据概览"),
            ].compactMap { $0 as? any Slide }))
        }
        
        for 章节配置 in 配置.章节列表 {
            let slides = 章节配置.幻灯片列表.map { 创建幻灯片($0, 上下文: 配置) }
            sections.append(册(标题: 章节配置.标题, slides: slides))
        }
        
        sections.append(册(标题: "总结", slides: [
            结束页(标题: "谢谢！", 副标题: 配置.作者),
        ]))
        
        return SectionPresentation(标题: 配置.标题, 作者: 配置.作者, 主题: 主题, sections: sections)
    }
}

@available(macOS 10.15, *)
public struct 培训课程模板: 演示文稿模板 {
    public var 模板名称: String { "培训课程" }
    public var 模板描述: String { "适用于培训教学、知识分享等场景" }
    public var 默认主题: 主题 { .教育青 }
    
    public init() {}
    
    public func 生成(配置: 模板配置) -> any Presentation {
        let 主题 = 配置.主题 ?? 默认主题
        
        var sections: [any Section] = []
        
        sections.append(册(标题: "课程导言", slides: [
            封面页(标题: 配置.标题, 副标题: 配置.副标题, 渐变: .绿色),
        ]))
        
        for 章节配置 in 配置.章节列表 {
            var slides: [any Slide] = []
            
            slides.append(章节页(编号: nil, 标题: 章节配置.标题, 副标题: nil))
            
            for 幻灯片配置 in 章节配置.幻灯片列表 {
                slides.append(创建幻灯片(幻灯片配置, 上下文: 配置))
            }
            
            sections.append(册(标题: 章节配置.标题, slides: slides))
        }
        
        sections.append(册(标题: "课程结束", slides: [
            引用页(引言: "学习是一个持续的过程", 作者: 配置.作者),
            结束页(标题: "谢谢！", 副标题: "期待下次再见"),
        ]))
        
        return SectionPresentation(标题: 配置.标题, 作者: 配置.作者, 主题: 主题, sections: sections)
    }
}

@available(macOS 10.15, *)
public struct 年度总结模板: 演示文稿模板 {
    public var 模板名称: String { "年度总结" }
    public var 模板描述: String { "适用于年度工作总结、业绩汇报等场景" }
    public var 默认主题: 主题 { .商务绿 }
    
    public init() {}
    
    public func 生成(配置: 模板配置) -> any Presentation {
        let 主题 = 配置.主题 ?? 默认主题
        
        var sections: [any Section] = []
        
        sections.append(册(标题: "年度概览", slides: [
            封面页(标题: 配置.标题, 副标题: 配置.副标题, 渐变: .绿色),
        ]))
        
        if let 数据 = 配置.数据源 {
            var 数据幻灯片: [any Slide] = []
            
            数据幻灯片.append(数据.转换为表格页(标题: "年度数据汇总"))
            
            if let 图表 = 数据.转换为柱状图(标题: "数据趋势", 标签列: 数据.列名.first ?? "", 数值列: 数据.列名.last ?? "") {
                数据幻灯片.append(图表)
            }
            
            sections.append(册(标题: "数据分析", slides: 数据幻灯片))
        }
        
        for 章节配置 in 配置.章节列表 {
            let slides = 章节配置.幻灯片列表.map { 创建幻灯片($0, 上下文: 配置) }
            sections.append(册(标题: 章节配置.标题, slides: slides))
        }
        
        sections.append(册(标题: "展望未来", slides: [
            结束页(标题: "谢谢！", 副标题: 配置.作者),
        ]))
        
        return SectionPresentation(标题: 配置.标题, 作者: 配置.作者, 主题: 主题, sections: sections)
    }
}

@available(macOS 10.15, *)
public struct 数据分析报告模板: 演示文稿模板 {
    public var 模板名称: String { "数据分析报告" }
    public var 模板描述: String { "适用于数据分析、调研报告等场景" }
    public var 默认主题: 主题 { .科技紫 }
    
    public init() {}
    
    public func 生成(配置: 模板配置) -> any Presentation {
        let 主题 = 配置.主题 ?? 默认主题
        
        var sections: [any Section] = []
        
        sections.append(册(标题: "报告概述", slides: [
            封面页(标题: 配置.标题, 副标题: 配置.副标题, 渐变: .紫色),
        ]))
        
        if let 数据 = 配置.数据源 {
            var 数据幻灯片: [any Slide] = []
            
            数据幻灯片.append(数据.转换为表格页(标题: "原始数据"))
            
            let 数值列 = 数据.列名.filter { !$0.isEmpty && 数据.数值列($0).count > 0 }
            
            if 数值列.count >= 2 {
                if let 图表 = 数据.转换为柱状图(标题: "\(数值列[1])分析", 标签列: 数据.列名[0], 数值列: 数值列[1]) {
                    数据幻灯片.append(图表)
                }
                
                if let 图表 = 数据.转换为折线图(标题: "\(数值列[1])趋势", 标签列: 数据.列名[0], 数值列: 数值列[1]) {
                    数据幻灯片.append(图表)
                }
            }
            
            sections.append(册(标题: "数据分析", slides: 数据幻灯片))
        }
        
        for 章节配置 in 配置.章节列表 {
            let slides = 章节配置.幻灯片列表.map { 创建幻灯片($0, 上下文: 配置) }
            sections.append(册(标题: 章节配置.标题, slides: slides))
        }
        
        sections.append(册(标题: "结论", slides: [
            结束页(标题: "谢谢！", 副标题: 配置.作者),
        ]))
        
        return SectionPresentation(标题: 配置.标题, 作者: 配置.作者, 主题: 主题, sections: sections)
    }
}

@available(macOS 10.15, *)
public enum 模板库 {
    public static let 项目报告 = 项目报告模板()
    public static let 培训课程 = 培训课程模板()
    public static let 年度总结 = 年度总结模板()
    public static let 数据分析 = 数据分析报告模板()
    
    public static func 所有模板() -> [any 演示文稿模板] {
        [项目报告, 培训课程, 年度总结, 数据分析]
    }
}
