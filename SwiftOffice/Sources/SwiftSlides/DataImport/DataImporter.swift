import Foundation

@available(macOS 10.15, *)
public protocol 数据导入器: Sendable {
    func 导入(路径: String) throws -> 表格数据
    func 导入(内容: String, 格式: 数据格式) throws -> 表格数据
}

@available(macOS 10.15, *)
public enum 数据格式: String, Sendable {
    case csv
    case tsv
    case json
}

@available(macOS 10.15, *)
public struct 表格数据: Sendable {
    public let 列名: [String]
    public let 行数据: [[String]]
    public let 原始数据: [[String]]
    
    public init(列名: [String], 行数据: [[String]]) {
        self.列名 = 列名
        self.行数据 = 行数据
        self.原始数据 = [列名] + 行数据
    }
    
    public var 行数: Int { 行数据.count }
    public var 列数: Int { 列名.count }
    
    public func 列(_ 名称: String) -> [String] {
        guard let index = 列名.firstIndex(of: 名称) else { return [] }
        return 行数据.map { $0[index] }
    }
    
    public func 数值列(_ 名称: String) -> [Double] {
        列(名称).compactMap { Double($0) }
    }
    
    public func toDict() -> [String: Any] {
        [
            "headers": 列名,
            "rows": 行数据
        ]
    }
}

@available(macOS 10.15, *)
public extension 表格数据 {
    func 转换为表格页(标题: String) -> 表格页 {
        表格页(标题: 标题, 表头: 列名, 行: 行数据)
    }
    
    func 转换为柱状图(标题: String, 标签列: String, 数值列: String, Y轴: String? = nil) -> 图表页? {
        let 标签 = 列(标签列)
        let 数值 = self.数值列(数值列)
        
        guard 标签.count == 数值.count, !标签.isEmpty else { return nil }
        
        return 图表页(
            标题: 标题,
            类型: .柱状图,
            标签: 标签,
            系列: [图表数据系列(名称: 数值列, 数值: 数值)],
            Y轴: Y轴
        )
    }
    
    func 转换为饼图(标题: String, 标签列: String, 数值列: String) -> 图表页? {
        let 标签 = 列(标签列)
        let 数值 = self.数值列(数值列)
        
        guard 标签.count == 数值.count, !标签.isEmpty else { return nil }
        
        return 图表页(
            标题: 标题,
            类型: .饼图,
            标签: 标签,
            系列: [图表数据系列(名称: 数值列, 数值: 数值)]
        )
    }
    
    func 转换为折线图(标题: String, 标签列: String, 数值列: String, Y轴: String? = nil) -> 图表页? {
        let 标签 = 列(标签列)
        let 数值 = self.数值列(数值列)
        
        guard 标签.count == 数值.count, !标签.isEmpty else { return nil }
        
        return 图表页(
            标题: 标题,
            类型: .折线图,
            标签: 标签,
            系列: [图表数据系列(名称: 数值列, 数值: 数值)],
            Y轴: Y轴
        )
    }
    
    func 转换为多系列柱状图(标题: String, 标签列: String, 数值列列表: [String], Y轴: String? = nil) -> 图表页? {
        let 标签 = 列(标签列)
        var 系列: [图表数据系列] = []
        
        for 列名 in 数值列列表 {
            let 数值 = 数值列(列名)
            if 数值.count == 标签.count {
                系列.append(图表数据系列(名称: 列名, 数值: 数值))
            }
        }
        
        guard !系列.isEmpty else { return nil }
        
        return 图表页(
            标题: 标题,
            类型: .柱状图,
            标签: 标签,
            系列: 系列,
            Y轴: Y轴
        )
    }
}
