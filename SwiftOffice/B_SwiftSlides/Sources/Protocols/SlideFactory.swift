import Foundation

@available(macOS 10.15, *)
public enum 幻灯片 {
    public static func 封面(
        标题: String,
        副标题: String? = nil,
        作者: String? = nil,
        日期: String? = nil,
        渐变: 渐变色? = nil
    ) -> 封面页 {
        封面页(标题: 标题, 副标题: 副标题, 作者: 作者, 日期: 日期, 渐变: 渐变)
    }
    
    public static func 章节(
        编号: String? = nil,
        标题: String,
        副标题: String? = nil,
        渐变: 渐变色? = nil
    ) -> 章节页 {
        章节页(编号: 编号, 标题: 标题, 副标题: 副标题, 渐变: 渐变)
    }
    
    public static func 列表(
        标题: String,
        项目: String...
    ) -> 列表页 {
        列表页(标题: 标题, 项目: 项目)
    }
    
    public static func 列表(
        标题: String,
        项目: [String]
    ) -> 列表页 {
        列表页(标题: 标题, 项目: 项目)
    }
    
    public static func 卡片(
        标题: String,
        列数: Int = 2,
        卡片: [SwiftSlides.卡片]
    ) -> 卡片页 {
        卡片页(标题: 标题, 卡片: 卡片, 列数: 列数)
    }
    
    public static func 卡片(
        标题: String,
        列数: Int = 2,
        数据: [(标题: String, 内容: String)]
    ) -> 卡片页 {
        let 卡片列表 = 数据.map { SwiftSlides.卡片(标题: $0.标题, 内容: $0.内容) }
        return 卡片页(标题: 标题, 卡片: 卡片列表, 列数: 列数)
    }
    
    public static func 概览(
        标题: String = "概览",
        项目: [(标题: String, 内容: String)]
    ) -> 卡片页 {
        let 卡片列表 = 项目.map { SwiftSlides.卡片(标题: $0.标题, 内容: $0.内容) }
        return 卡片页(标题: 标题, 卡片: 卡片列表, 列数: 2)
    }
    
    public static func 表格(
        标题: String,
        表头: [String],
        行: [[String]]
    ) -> 表格页 {
        表格页(标题: 标题, 表头: 表头, 行: 行)
    }
    
    public static func 表格(
        标题: String,
        数据: [[String]]
    ) -> 表格页 {
        guard let 表头 = 数据.first else {
            return 表格页(标题: 标题, 表头: [], 行: [])
        }
        let 行 = Array(数据.dropFirst())
        return 表格页(标题: 标题, 表头: 表头, 行: 行)
    }
    
    public static func 表格< T: CustomStringConvertible>(
        标题: String,
        列名: [String],
        数据: [[T]]
    ) -> 表格页 {
        let 行 = 数据.map { $0.map { $0.description } }
        return 表格页(标题: 标题, 表头: 列名, 行: 行)
    }
    
    public static func 引用(
        引言: String,
        作者: String? = nil
    ) -> 引用页 {
        引用页(引言: 引言, 作者: 作者)
    }
    
    public static func 对比(
        标题: String,
        左侧: SwiftSlides.对比项,
        右侧: SwiftSlides.对比项
    ) -> 对比页 {
        对比页(标题: 标题, 左侧: 左侧, 右侧: 右侧)
    }
    
    public static func 时间线(
        标题: String,
        事件: [时间事件]
    ) -> 时间线页 {
        时间线页(标题: 标题, 事件: 事件)
    }
    
    public static func 结束(
        标题: String = "谢谢！",
        副标题: String? = nil
    ) -> 结束页 {
        结束页(标题: 标题, 副标题: 副标题)
    }
    
    public static func 流程(
        标题: String,
        步骤: String...,
        循环: Bool = false
    ) -> 流程页 {
        流程页(标题: 标题, 步骤: 步骤, 循环: 循环)
    }
    
    public static func 结构(
        标题: String,
        层级: String...
    ) -> 结构图页 {
        结构图页(标题: 标题, 层级: 层级)
    }
    
    public static func 创建对比项(标题: String, 项目: [String]) -> SwiftSlides.对比项 {
        SwiftSlides.对比项(标题: 标题, 项目: 项目)
    }
    
    public static func 创建卡片(标题: String, 内容: String) -> SwiftSlides.卡片 {
        SwiftSlides.卡片(标题: 标题, 内容: 内容)
    }
    
    public static func 创建时间事件(日期: String, 标题: String, 描述: String? = nil) -> 时间事件 {
        时间事件(日期: 日期, 标题: 标题, 描述: 描述)
    }
    
    public static func 定义(
        标题: String,
        定义: String
    ) -> 定义页 {
        定义页(标题: 标题, 定义: 定义)
    }
    
    public static func 架构图(
        标题: String,
        层次: [架构层]
    ) -> 架构图页 {
        架构图页(标题: 标题, 层次: 层次)
    }
    
    public static func 流程图(
        标题: String,
        步骤: [String],
        循环: Bool = false
    ) -> 流程图页 {
        流程图页(标题: 标题, 步骤: 步骤, 循环: 循环)
    }
    
    public static func 金字塔(
        标题: String,
        层级: [金字塔层]
    ) -> 金字塔页 {
        金字塔页(标题: 标题, 层级: 层级)
    }
    
    public static func 创建金字塔层(标签: String, 占比: Int, 颜色: 渐变色 = .蓝色) -> 金字塔层 {
        金字塔层(标签: 标签, 占比: 占比, 颜色: 颜色)
    }
    
    public static func 矩阵(
        标题: String,
        行: [String],
        列: [String],
        单元格: [矩阵单元格]
    ) -> 矩阵页 {
        矩阵页(标题: 标题, 行: 行, 列: 列, 单元格: 单元格)
    }
    
    public static func 创建矩阵单元(行: String, 列: String, 内容: String) -> 矩阵单元格 {
        矩阵单元格(行: 行, 列: 列, 内容: 内容)
    }
    
    public static func 柏拉图(
        标题: String,
        项目: [柏拉图项],
        阈值: Double = 80.0
    ) -> 柏拉图页 {
        柏拉图页(标题: 标题, 项目: 项目, 阈值: 阈值)
    }
    
    public static func 创建柏拉图项(标签: String, 数值: Double, 核心问题: Bool = false) -> 柏拉图项 {
        柏拉图项(标签: 标签, 数值: 数值, 核心问题: 核心问题)
    }
    
    public static func 图片(
        标题: String,
        图片: String,
        说明: String? = nil
    ) -> 图片页 {
        图片页(标题: 标题, 图片: 图片, 说明: 说明)
    }
    
    public static func 双栏(
        标题: String,
        左栏标题: String? = nil,
        左栏内容: [String],
        右栏标题: String? = nil,
        右栏内容: [String]
    ) -> 双栏页 {
        双栏页(标题: 标题, 左栏标题: 左栏标题, 左栏内容: 左栏内容, 右栏标题: 右栏标题, 右栏内容: 右栏内容)
    }
    
    public static func 图表(
        标题: String,
        类型: 图表类型,
        标签: [String],
        系列: [图表数据系列],
        X轴: String? = nil,
        Y轴: String? = nil,
        图例: Bool = true
    ) -> 图表页 {
        图表页(标题: 标题, 类型: 类型, 标签: 标签, 系列: 系列, X轴: X轴, Y轴: Y轴, 图例: 图例)
    }
    
    public static func 柱状图(
        标题: String,
        标签: [String],
        系列: [图表数据系列],
        Y轴: String? = nil
    ) -> 图表页 {
        图表页(标题: 标题, 类型: .柱状图, 标签: 标签, 系列: 系列, Y轴: Y轴)
    }
    
    public static func 折线图(
        标题: String,
        标签: [String],
        系列: [图表数据系列],
        Y轴: String? = nil
    ) -> 图表页 {
        图表页(标题: 标题, 类型: .折线图, 标签: 标签, 系列: 系列, Y轴: Y轴)
    }
    
    public static func 饼图(
        标题: String,
        标签: [String],
        数值: [Double]
    ) -> 图表页 {
        图表页(标题: 标题, 类型: .饼图, 标签: 标签, 系列: [图表数据系列(名称: "数值", 数值: 数值)], 图例: true)
    }
    
    public static func 雷达图(
        标题: String,
        标签: [String],
        系列: [图表数据系列]
    ) -> 图表页 {
        图表页(标题: 标题, 类型: .雷达图, 标签: 标签, 系列: 系列, 图例: true)
    }
    
    public static func 创建数据系列(名称: String, 数值: [Double]) -> 图表数据系列 {
        图表数据系列(名称: 名称, 数值: 数值)
    }
    
    public static func 数据系列(_ 名称: String, _ 数值: Double...) -> 图表数据系列 {
        图表数据系列(名称: 名称, 数值: 数值)
    }
    
    public static func 柱状图(
        标题: String,
        数据: [(标签: String, 数值: Double)],
        Y轴: String? = nil
    ) -> 图表页 {
        let 标签 = 数据.map { $0.标签 }
        let 数值 = 数据.map { $0.数值 }
        return 图表页(标题: 标题, 类型: .柱状图, 标签: 标签, 系列: [图表数据系列(名称: "数值", 数值: 数值)], Y轴: Y轴)
    }
    
    public static func 饼图(
        标题: String,
        数据: [(标签: String, 数值: Double)]
    ) -> 图表页 {
        let 标签 = 数据.map { $0.标签 }
        let 数值 = 数据.map { $0.数值 }
        return 图表页(标题: 标题, 类型: .饼图, 标签: 标签, 系列: [图表数据系列(名称: "数值", 数值: 数值)], 图例: true)
    }
    
    public static func 折线图(
        标题: String,
        数据: [(标签: String, 数值: Double)],
        Y轴: String? = nil
    ) -> 图表页 {
        let 标签 = 数据.map { $0.标签 }
        let 数值 = 数据.map { $0.数值 }
        return 图表页(标题: 标题, 类型: .折线图, 标签: 标签, 系列: [图表数据系列(名称: "数值", 数值: 数值)], Y轴: Y轴)
    }
    
    public static func 从CSV(路径: String) throws -> 表格数据 {
        try 表格数据.从CSV(路径: 路径)
    }
    
    public static func 从CSV内容(_ 内容: String) throws -> 表格数据 {
        try 表格数据.从CSV内容(内容)
    }
    
    public static func 表格(标题: String, 数据: 表格数据) -> 表格页 {
        数据.转换为表格页(标题: 标题)
    }
    
    public static func 柱状图(标题: String, 数据: 表格数据, 标签列: String, 数值列: String, Y轴: String? = nil) -> 图表页? {
        数据.转换为柱状图(标题: 标题, 标签列: 标签列, 数值列: 数值列, Y轴: Y轴)
    }
    
    public static func 饼图(标题: String, 数据: 表格数据, 标签列: String, 数值列: String) -> 图表页? {
        数据.转换为饼图(标题: 标题, 标签列: 标签列, 数值列: 数值列)
    }
    
    public static func 折线图(标题: String, 数据: 表格数据, 标签列: String, 数值列: String, Y轴: String? = nil) -> 图表页? {
        数据.转换为折线图(标题: 标题, 标签列: 标签列, 数值列: 数值列, Y轴: Y轴)
    }
}
