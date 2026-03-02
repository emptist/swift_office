import Foundation

@available(macOS 10.15, *)
public protocol 演示文稿模板: Sendable {
    var 模板名称: String { get }
    var 模板描述: String { get }
    var 默认主题: 主题 { get }
    
    func 生成(配置: 模板配置) -> any Presentation
}

@available(macOS 10.15, *)
public struct 模板配置: Sendable {
    public var 标题: String
    public var 副标题: String?
    public var 作者: String?
    public var 主题: 主题?
    public var 章节列表: [章节配置]
    public var 数据源: 表格数据?
    
    public init(
        标题: String,
        副标题: String? = nil,
        作者: String? = nil,
        主题: 主题? = nil,
        章节: [章节配置] = [],
        数据: 表格数据? = nil
    ) {
        self.标题 = 标题
        self.副标题 = 副标题
        self.作者 = 作者
        self.主题 = 主题
        self.章节列表 = 章节
        self.数据源 = 数据
    }
}

@available(macOS 10.15, *)
public struct 章节配置: Sendable {
    public var 标题: String
    public var 幻灯片列表: [幻灯片配置]
    
    public init(标题: String, 幻灯片: [幻灯片配置] = []) {
        self.标题 = 标题
        self.幻灯片列表 = 幻灯片
    }
}

@available(macOS 10.15, *)
public enum 幻灯片配置: Sendable {
    case 封面(副标题: String? = nil)
    case 章节(编号: String? = nil, 副标题: String? = nil)
    case 概览(项目: [(String, String)])
    case 列表(标题: String, 项目: [String])
    case 表格(标题: String)
    case 图表(标题: String, 类型: 图表类型, 标签列: String, 数值列: String)
    case 定义(标题: String, 内容: String)
    case 架构(标题: String, 层次: [架构层])
    case 流程(标题: String, 步骤: [String], 循环: Bool = false)
    case 引用(引言: String, 作者: String? = nil)
    case 结束(副标题: String? = nil)
    case 自定义(any Slide)
}

@available(macOS 10.15, *)
public extension 演示文稿模板 {
    var 默认主题: 主题 { .专业蓝 }
    
    func 创建幻灯片(_ 配置: 幻灯片配置, 上下文: 模板配置) -> any Slide {
        switch 配置 {
        case .封面(let 副标题):
            return 封面页(标题: 上下文.标题, 副标题: 副标题 ?? 上下文.副标题, 渐变: .蓝色)
            
        case .章节(let 编号, let 副标题):
            return 章节页(编号: 编号, 标题: 上下文.标题, 副标题: 副标题)
            
        case .概览(let 项目):
            let 卡片 = 项目.map { SwiftSlides.卡片(标题: $0.0, 内容: $0.1) }
            return 卡片页(标题: "概览", 卡片: 卡片, 列数: 2)
            
        case .列表(let 标题, let 项目):
            return 列表页(标题: 标题, 项目: 项目)
            
        case .表格(let 标题):
            if let 数据 = 上下文.数据源 {
                return 数据.转换为表格页(标题: 标题)
            }
            return 表格页(标题: 标题, 表头: [], 行: [])
            
        case .图表(let 标题, let 类型, let 标签列, let 数值列):
            if let 数据 = 上下文.数据源 {
                return 图表页(标题: 标题, 类型: 类型, 标签: 数据.列(标签列), 系列: [图表数据系列(名称: 数值列, 数值: 数据.数值列(数值列))])
            }
            return 图表页(标题: 标题, 类型: 类型, 标签: [], 系列: [])
            
        case .定义(let 标题, let 内容):
            return 定义页(标题: 标题, 定义: 内容)
            
        case .架构(let 标题, let 层次):
            return 架构图页(标题: 标题, 层次: 层次)
            
        case .流程(let 标题, let 步骤, let 循环):
            return 流程图页(标题: 标题, 步骤: 步骤, 循环: 循环)
            
        case .引用(let 引言, let 作者):
            return 引用页(引言: 引言, 作者: 作者)
            
        case .结束(let 副标题):
            return 结束页(标题: "谢谢！", 副标题: 副标题)
            
        case .自定义(let slide):
            return slide
        }
    }
}
