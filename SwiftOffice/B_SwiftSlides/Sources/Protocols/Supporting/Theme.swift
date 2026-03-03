import Foundation

@available(macOS 10.15, *)
public struct 主题: Sendable {
    public let 名称: String
    public let 主色: String
    public let 辅色: String
    public let 强调色: String
    public let 文字色: String
    public let 浅文字色: String
    public let 背景色: String
    
    public init(名称: String, 主色: String, 辅色: String, 强调色: String, 文字色: String = "333333", 浅文字色: String = "666666", 背景色: String = "FFFFFF") {
        self.名称 = 名称
        self.主色 = 主色
        self.辅色 = 辅色
        self.强调色 = 强调色
        self.文字色 = 文字色
        self.浅文字色 = 浅文字色
        self.背景色 = 背景色
    }
    
    public func toDict() -> [String: Any] {
        [
            "name": 名称,
            "primary": 主色,
            "secondary": 辅色,
            "accent": 强调色,
            "text": 文字色,
            "lightText": 浅文字色,
            "background": 背景色
        ]
    }
}

@available(macOS 10.15, *)
public extension 主题 {
    static let 专业蓝 = 主题(
        名称: "专业蓝",
        主色: "1F4E79",
        辅色: "2E75B6",
        强调色: "5B9BD5"
    )
    
    static let 商务绿 = 主题(
        名称: "商务绿",
        主色: "2E7D32",
        辅色: "388E3C",
        强调色: "66BB6A"
    )
    
    static let 科技紫 = 主题(
        名称: "科技紫",
        主色: "6A1B9A",
        辅色: "8E24AA",
        强调色: "AB47BC"
    )
    
    static let 活力橙 = 主题(
        名称: "活力橙",
        主色: "E65100",
        辅色: "F57C00",
        强调色: "FF9800"
    )
    
    static let 经典红 = 主题(
        名称: "经典红",
        主色: "C62828",
        辅色: "D32F2F",
        强调色: "EF5350"
    )
    
    static let 医疗蓝 = 主题(
        名称: "医疗蓝",
        主色: "0D47A1",
        辅色: "1565C0",
        强调色: "42A5F5"
    )
    
    static let 教育青 = 主题(
        名称: "教育青",
        主色: "00695C",
        辅色: "00897B",
        强调色: "4DB6AC"
    )
    
    static let 金融金 = 主题(
        名称: "金融金",
        主色: "F9A825",
        辅色: "FBC02D",
        强调色: "FFEB3B",
        文字色: "333333"
    )
}
