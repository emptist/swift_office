import Foundation

public struct Gantt任务: Sendable {
    public let 名称: String
    public let 开始日期: Date
    public let 结束日期: Date
    public let 颜色: String?
    public let 进度: Double?
    
    public init(名称: String, 开始日期: Date, 结束日期: Date, 颜色: String? = nil, 进度: Double? = nil) {
        self.名称 = 名称
        self.开始日期 = 开始日期
        self.结束日期 = 结束日期
        self.颜色 = 颜色
        self.进度 = 进度
    }
    
    public var 持续天数: Int {
        Calendar.current.dateComponents([.day], from: 开始日期, to: 结束日期).day ?? 0 + 1
    }
}

public struct Gantt图表: Sendable {
    public let 标题: String
    public let 任务列表: [Gantt任务]
    public let 显示日期: Bool
    
    public init(标题: String = "", 任务: [Gantt任务] = [], 显示日期: Bool = true) {
        self.标题 = 标题
        self.任务列表 = 任务
        self.显示日期 = 显示日期
    }
    
    public var 最早开始: Date? {
        任务列表.map(\.开始日期).min()
    }
    
    public var 最晚结束: Date? {
        任务列表.map(\.结束日期).max()
    }
    
    public var 总天数: Int {
        guard let 开始 = 最早开始, let 结束 = 最晚结束 else { return 0 }
        return Calendar.current.dateComponents([.day], from: 开始, to: 结束).day ?? 0 + 1
    }
}
