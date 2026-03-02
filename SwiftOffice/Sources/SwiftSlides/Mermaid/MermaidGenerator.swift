import Foundation

@available(macOS 10.15, *)
public enum Mermaid方向: String, Sendable {
    case 从上到下 = "TB"
    case 从下到上 = "BT"
    case 从左到右 = "LR"
    case 从右到左 = "RL"
}

@available(macOS 10.15, *)
public struct Mermaid配置: Sendable {
    public let 主题: String
    public let 字体大小: Int
    public let 宽度: Int?
    public let 高度: Int?
    
    public init(主题: String = "default", 字体大小: Int = 18, 宽度: Int? = nil, 高度: Int? = nil) {
        self.主题 = 主题
        self.字体大小 = 字体大小
        self.宽度 = 宽度
        self.高度 = 高度
    }
    
    public static let 默认 = Mermaid配置()
    public static let 大字体 = Mermaid配置(字体大小: 24)
    public static let 紧凑 = Mermaid配置(字体大小: 14)
    
    public func 生成初始化代码() -> String {
        var config: [String: Any] = [
            "theme": 主题,
            "flowchart": [
                "curve": "basis",
                "padding": 20
            ],
            "sequence": [
                "actorMargin": 50,
                "boxMargin": 10,
                "noteMargin": 10,
                "messageMargin": 35,
                "mirrorActors": false
            ],
            "gantt": [
                "leftPadding": 75,
                "gridLineStartPadding": 35,
                "barHeight": 20,
                "barGap": 4,
                "topPadding": 50
            ]
        ]
        
        if let 宽度 = 宽度 {
            config["flowchart"] = (config["flowchart"] as? [String: Any] ?? [:]).merging(["useMaxWidth": false, "diagramPadding": 宽度]) { $1 }
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: config, options: [])
        let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? "{}"
        
        return "%%{init: \(jsonString)}%%"
    }
}

@available(macOS 10.15, *)
public enum Mermaid节点形状: Sendable {
    case 矩形
    case 圆角矩形
    case 圆形
    case 菱形
    case 六边形
    case 平行四边形
    case 子程序
    
    var 开始符号: String {
        switch self {
        case .矩形: return "["
        case .圆角矩形: return "("
        case .圆形: return "(("
        case .菱形: return "{"
        case .六边形: return "{{"
        case .平行四边形: return "[/"
        case .子程序: return "[["
        }
    }
    
    var 结束符号: String {
        switch self {
        case .矩形: return "]"
        case .圆角矩形: return ")"
        case .圆形: return "))"
        case .菱形: return "}"
        case .六边形: return "}}"
        case .平行四边形: return "/]"
        case .子程序: return "]]"
        }
    }
}

@available(macOS 10.15, *)
public enum Mermaid连线类型: String, Sendable {
    case 实线箭头 = "-->"
    case 实线无箭头 = "---"
    case 虚线箭头 = "-.->"
    case 虚线无箭头 = "-.-"
    case 粗线箭头 = "==>"
    case 粗线无箭头 = "==="
}

@available(macOS 10.15, *)
public struct Mermaid节点: Sendable {
    public let id: String
    public let 标签: String
    public let 形状: Mermaid节点形状
    
    public init(id: String, 标签: String, 形状: Mermaid节点形状 = .矩形) {
        self.id = id
        self.标签 = 标签
        self.形状 = 形状
    }
    
    public func 生成语法() -> String {
        "\(id)\(形状.开始符号)\"\(标签)\"\(形状.结束符号)"
    }
}

@available(macOS 10.15, *)
public struct Mermaid连线: Sendable {
    public let 源节点: String
    public let 目标节点: String
    public let 类型: Mermaid连线类型
    public let 标签: String?
    
    public init(从: String, 到: String, 类型: Mermaid连线类型 = .实线箭头, 标签: String? = nil) {
        self.源节点 = 从
        self.目标节点 = 到
        self.类型 = 类型
        self.标签 = 标签
    }
    
    public func 生成语法() -> String {
        if let 标签 = 标签 {
            return "\(源节点) \(类型.rawValue)|\(标签)| \(目标节点)"
        }
        return "\(源节点) \(类型.rawValue) \(目标节点)"
    }
}

@available(macOS 10.15, *)
public struct Mermaid流程图: Sendable {
    public let 方向: Mermaid方向
    public let 节点列表: [Mermaid节点]
    public let 连线列表: [Mermaid连线]
    public let 子图列表: [Mermaid子图]
    public let 配置: Mermaid配置?
    
    public init(
        方向: Mermaid方向 = .从上到下,
        节点: [Mermaid节点] = [],
        连线: [Mermaid连线] = [],
        子图: [Mermaid子图] = [],
        配置: Mermaid配置? = nil
    ) {
        self.方向 = 方向
        self.节点列表 = 节点
        self.连线列表 = 连线
        self.子图列表 = 子图
        self.配置 = 配置
    }
    
    public func 生成语法() -> String {
        var lines: [String] = []
        
        if let 配置 = 配置 {
            lines.append(配置.生成初始化代码())
        }
        
        lines.append("flowchart \(方向.rawValue)")
        
        for 节点 in 节点列表 {
            lines.append("    \(节点.生成语法())")
        }
        
        for 连线 in 连线列表 {
            lines.append("    \(连线.生成语法())")
        }
        
        for 子图 in 子图列表 {
            lines.append(子图.生成语法())
        }
        
        return lines.joined(separator: "\n")
    }
}

@available(macOS 10.15, *)
public struct Mermaid子图: Sendable {
    public let id: String
    public let 标题: String
    public let 节点列表: [Mermaid节点]
    public let 连线列表: [Mermaid连线]
    
    public init(id: String, 标题: String, 节点: [Mermaid节点] = [], 连线: [Mermaid连线] = []) {
        self.id = id
        self.标题 = 标题
        self.节点列表 = 节点
        self.连线列表 = 连线
    }
    
    public func 生成语法() -> String {
        var lines: [String] = []
        lines.append("    subgraph \(id) [\"\(标题)\"]")
        
        for 节点 in 节点列表 {
            lines.append("        \(节点.生成语法())")
        }
        
        for 连线 in 连线列表 {
            lines.append("        \(连线.生成语法())")
        }
        
        lines.append("    end")
        return lines.joined(separator: "\n")
    }
}

@available(macOS 10.15, *)
public struct Mermaid时序图: Sendable {
    public let 参与者列表: [String]
    public let 消息列表: [Mermaid消息]
    public let 配置: Mermaid配置?
    
    public init(参与者: [String], 消息: [Mermaid消息] = [], 配置: Mermaid配置? = nil) {
        self.参与者列表 = 参与者
        self.消息列表 = 消息
        self.配置 = 配置
    }
    
    public func 生成语法() -> String {
        var lines: [String] = []
        
        if let 配置 = 配置 {
            lines.append(配置.生成初始化代码())
        }
        
        lines.append("sequenceDiagram")
        
        for 参与者 in 参与者列表 {
            lines.append("    participant \(参与者)")
        }
        
        for 消息 in 消息列表 {
            lines.append("    \(消息.生成语法())")
        }
        
        return lines.joined(separator: "\n")
    }
}

@available(macOS 10.15, *)
public struct Mermaid消息: Sendable {
    public let 发送者: String
    public let 接收者: String
    public let 内容: String
    public let 类型: Mermaid消息类型
    
    public init(从: String, 到: String, 内容: String, 类型: Mermaid消息类型 = .实线箭头) {
        self.发送者 = 从
        self.接收者 = 到
        self.内容 = 内容
        self.类型 = 类型
    }
    
    public func 生成语法() -> String {
        "\(发送者) \(类型.语法) \(接收者): \(内容)"
    }
}

@available(macOS 10.15, *)
public enum Mermaid消息类型: Sendable {
    case 实线箭头
    case 实线无箭头
    case 虚线箭头
    case 虚线无箭头
    
    var 语法: String {
        switch self {
        case .实线箭头: return "->>"
        case .实线无箭头: return "->"
        case .虚线箭头: return "-->>"
        case .虚线无箭头: return "-->"
        }
    }
}

@available(macOS 10.15, *)
public struct Mermaid甘特图: Sendable {
    public let 标题: String
    public let 任务列表: [Mermaid任务]
    public let 日期格式: String
    public let 配置: Mermaid配置?
    
    public init(标题: String, 任务: [Mermaid任务], 日期格式: String = "YYYY-MM-DD", 配置: Mermaid配置? = nil) {
        self.标题 = 标题
        self.任务列表 = 任务
        self.日期格式 = 日期格式
        self.配置 = 配置
    }
    
    public func 生成语法() -> String {
        var lines: [String] = []
        
        if let 配置 = 配置 {
            lines.append(配置.生成初始化代码())
        }
        
        lines.append("gantt")
        lines.append("    title \(标题)")
        lines.append("    dateFormat \(日期格式)")
        
        for 任务 in 任务列表 {
            lines.append("    \(任务.生成语法())")
        }
        
        return lines.joined(separator: "\n")
    }
}

@available(macOS 10.15, *)
public struct Mermaid任务: Sendable {
    public let 名称: String
    public let 状态: Mermaid任务状态
    public let 开始: String
    public let 结束: String
    
    public init(名称: String, 状态: Mermaid任务状态 = .待办, 开始: String, 结束: String) {
        self.名称 = 名称
        self.状态 = 状态
        self.开始 = 开始
        self.结束 = 结束
    }
    
    public func 生成语法() -> String {
        "\(名称) : \(状态.语法) \(名称) : \(开始), \(结束)"
    }
}

@available(macOS 10.15, *)
public enum Mermaid任务状态: Sendable {
    case 待办
    case 进行中
    case 已完成
    case 关键
    
    var 语法: String {
        switch self {
        case .待办: return ""
        case .进行中: return "active,"
        case .已完成: return "done,"
        case .关键: return "crit,"
        }
    }
}
