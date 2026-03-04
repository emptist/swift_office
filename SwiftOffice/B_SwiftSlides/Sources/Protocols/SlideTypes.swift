import Foundation
import BeautifulMermaid

@available(macOS 10.15, *)
public struct 封面页: Slide {
    public let id = UUID()
    public var title: String
    public var 副标题: String?
    public var 作者: String?
    public var 日期: String?
    public var 渐变: 渐变色?
    public var contents: SlideContent { 
        var dict: [String: any Sendable] = [:]
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        if let 作者 = 作者 { dict["author"] = 作者 }
        if let 日期 = 日期 { dict["date"] = 日期 }
        if let 渐变 = 渐变 { dict["gradient"] = 渐变.rawValue }
        return SlideContent(dict)
    }
    
    public var slideType: String { "封面页" }
    
    public init(
        标题: String,
        副标题: String? = nil,
        作者: String? = nil,
        日期: String? = nil,
        渐变: 渐变色? = nil
    ) {
        self.title = 标题
        self.副标题 = 副标题
        self.作者 = 作者
        self.日期 = 日期
        self.渐变 = 渐变
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title
        ]
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        if let 作者 = 作者 { dict["author"] = 作者 }
        if let 日期 = 日期 { dict["date"] = 日期 }
        if let 渐变 = 渐变 { dict["gradient"] = 渐变.rawValue }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 章节页: Slide {
    public let id = UUID()
    public var title: String
    public var 编号: String?
    public var 副标题: String?
    public var 渐变: 渐变色?
    public var contents: SlideContent { 
        var dict: [String: any Sendable] = [:]
        if let 编号 = 编号 { dict["number"] = 编号 }
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        if let 渐变 = 渐变 { dict["gradient"] = 渐变.rawValue }
        return SlideContent(dict)
    }
    
    public var slideType: String { "章节页" }
    
    public init(
        编号: String? = nil,
        标题: String,
        副标题: String? = nil,
        渐变: 渐变色? = nil
    ) {
        self.title = 标题
        self.编号 = 编号
        self.副标题 = 副标题
        self.渐变 = 渐变
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title
        ]
        if let 编号 = 编号 { dict["number"] = 编号 }
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        if let 渐变 = 渐变 { dict["gradient"] = 渐变.rawValue }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 列表页: Slide {
    public let id = UUID()
    public var title: String
    public var 项目: [String]
    public var contents: SlideContent { SlideContent(["items": 项目]) }
    
    public var slideType: String { "列表页" }
    
    public init(标题: String, 项目: [String]) {
        self.title = 标题
        self.项目 = 项目
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "items": 项目
        ]
    }
}

@available(macOS 10.15, *)
public struct 卡片页: Slide {
    public let id = UUID()
    public var title: String
    public var 卡片列表: [卡片]
    public var 列数: Int
    public var contents: SlideContent { SlideContent(["cards": 卡片列表.map { ["title": $0.标题, "content": $0.内容] }, "columns": 列数]) }
    
    public var slideType: String { "卡片页" }
    
    public init(标题: String, 卡片: [卡片], 列数: Int = 2) {
        self.title = 标题
        self.卡片列表 = 卡片
        self.列数 = 列数
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "columns": 列数,
            "cards": 卡片列表.map { ["title": $0.标题, "content": $0.内容] }
        ]
    }
}

@available(macOS 10.15, *)
public struct 卡片: Sendable, Hashable {
    public let 标题: String
    public let 内容: String
    
    public init(标题: String, 内容: String) {
        self.标题 = 标题
        self.内容 = 内容
    }
    
    public func toDict() -> [String: Any] {
        ["title": 标题, "content": 内容]
    }
}

@available(macOS 10.15, *)
public struct 表格页: Slide {
    public let id = UUID()
    public var title: String
    public var 表头: [String]
    public var 行数据: [[String]]
    public var contents: SlideContent { SlideContent(["headers": 表头, "rows": 行数据]) }
    
    public var slideType: String { "表格页" }
    
    public init(标题: String, 表头: [String], 行: [[String]]) {
        self.title = 标题
        self.表头 = 表头
        self.行数据 = 行
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "headers": 表头,
            "rows": 行数据
        ]
    }
}

@available(macOS 10.15, *)
public struct 引用页: Slide {
    public let id = UUID()
    public var title: String = ""
    public var 引言: String
    public var 作者: String?
    public var contents: SlideContent { 
        var dict: [String: any Sendable] = ["quote": 引言]
        if let 作者 = 作者 { dict["author"] = 作者 }
        return SlideContent(dict)
    }
    
    public var slideType: String { "引用页" }
    
    public init(引言: String, 作者: String? = nil) {
        self.引言 = 引言
        self.作者 = 作者
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "quote": 引言
        ]
        if let 作者 = 作者 { dict["author"] = 作者 }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 对比页: Slide {
    public let id = UUID()
    public var title: String
    public var 左侧: 对比项
    public var 右侧: 对比项
    public var contents: SlideContent { 
        let left: [String: any Sendable] = 左侧.toSendableDict()
        let right: [String: any Sendable] = 右侧.toSendableDict()
        return SlideContent(["left": left, "right": right])
    }
    
    public var slideType: String { "对比页" }
    
    public init(标题: String, 左侧: 对比项, 右侧: 对比项) {
        self.title = 标题
        self.左侧 = 左侧
        self.右侧 = 右侧
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "left": ["title": 左侧.标题, "items": 左侧.项目],
            "right": ["title": 右侧.标题, "items": 右侧.项目]
        ]
    }
}

@available(macOS 10.15, *)
public struct 对比项: Sendable, Hashable {
    public let 标题: String
    public let 项目: [String]
    
    public init(标题: String, 项目: [String]) {
        self.标题 = 标题
        self.项目 = 项目
    }
    
    public func toDict() -> [String: Any] {
        ["title": 标题, "items": 项目]
    }
    
    public func toSendableDict() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [:]
        dict["title"] = 标题
        dict["items"] = 项目
        return dict
    }
}

@available(macOS 10.15, *)
public struct 时间线页: Slide {
    public let id = UUID()
    public var title: String
    public var 事件列表: [时间事件]
    public var contents: SlideContent { SlideContent(["events": 事件列表.map { ["date": $0.日期, "title": $0.标题, "description": $0.描述 ?? ""] }]) }
    
    public var slideType: String { "时间线页" }
    
    public init(标题: String, 事件: [时间事件]) {
        self.title = 标题
        self.事件列表 = 事件
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "events": 事件列表.map { ["date": $0.日期, "title": $0.标题, "description": $0.描述 ?? ""] }
        ]
    }
}

@available(macOS 10.15, *)
public struct 时间事件: Sendable, Hashable {
    public let 日期: String
    public let 标题: String
    public let 描述: String?
    
    public init(日期: String, 标题: String, 描述: String? = nil) {
        self.日期 = 日期
        self.标题 = 标题
        self.描述 = 描述
    }
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = ["date": 日期, "title": 标题]
        if let 描述 = 描述 { dict["description"] = 描述 }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 结束页: Slide {
    public let id = UUID()
    public var title: String
    public var 副标题: String?
    public var contents: SlideContent { 
        var dict: [String: any Sendable] = [:]
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        return SlideContent(dict)
    }
    
    public var slideType: String { "结束页" }
    
    public init(标题: String = "谢谢！", 副标题: String? = nil) {
        self.title = 标题
        self.副标题 = 副标题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title
        ]
        if let 副标题 = 副标题 { dict["subtitle"] = 副标题 }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 流程页: Slide {
    public let id = UUID()
    public var title: String
    public var 步骤列表: [String]
    public var 是否循环: Bool
    public var contents: SlideContent { SlideContent(["steps": 步骤列表, "isLoop": 是否循环]) }
    
    public var slideType: String { "流程页" }
    
    public init(标题: String, 步骤: [String], 循环: Bool = false) {
        self.title = 标题
        self.步骤列表 = 步骤
        self.是否循环 = 循环
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "steps": 步骤列表,
            "isLoop": 是否循环
        ]
    }
}

@available(macOS 10.15, *)
public struct 结构图页: Slide {
    public let id = UUID()
    public var title: String
    public var 层级列表: [String]
    public var contents: SlideContent { SlideContent(["levels": 层级列表]) }
    
    public var slideType: String { "结构图页" }
    
    public init(标题: String, 层级: [String]) {
        self.title = 标题
        self.层级列表 = 层级
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "levels": 层级列表
        ]
    }
}

public enum 渐变色: String, Sendable, CaseIterable {
    case 蓝色
    case 绿色
    case 紫色
    case 红色
    case 橙色
    case 灰色
}

@available(macOS 10.15, *)
public struct 定义页: Slide {
    public let id = UUID()
    public var title: String
    public var 定义内容: String
    public var contents: SlideContent { SlideContent(["definition": 定义内容]) }
    
    public var slideType: String { "定义页" }
    
    public init(标题: String, 定义: String) {
        self.title = 标题
        self.定义内容 = 定义
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "definition": 定义内容
        ]
    }
}

@available(macOS 10.15, *)
public enum 架构层: Sendable, Hashable {
    case 顶层(项目: [String])
    case 中层(项目: [String])
    case 底层(项目: [String])
    
    public func toDict() -> [String: Any] {
        switch self {
        case .顶层(let 项目): return ["level": "top", "items": 项目]
        case .中层(let 项目): return ["level": "middle", "items": 项目]
        case .底层(let 项目): return ["level": "bottom", "items": 项目]
        }
    }
    
    public func toSendableDict() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [:]
        switch self {
        case .顶层(let 项目):
            dict["level"] = "top"
            dict["items"] = 项目
        case .中层(let 项目):
            dict["level"] = "middle"
            dict["items"] = 项目
        case .底层(let 项目):
            dict["level"] = "bottom"
            dict["items"] = 项目
        }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 架构图页: Slide {
    public let id = UUID()
    public var title: String
    public var 层次结构: [架构层]
    public var contents: SlideContent { 
        let layers: [any Sendable] = 层次结构.map { $0.toSendableDict() }
        return SlideContent(["layers": layers])
    }
    
    public var slideType: String { "架构图页" }
    
    public init(标题: String, 层次: [架构层]) {
        self.title = 标题
        self.层次结构 = 层次
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "layers": 层次结构.map { $0.toDict() }
        ]
    }
}

@available(macOS 10.15, *)
public struct 流程图页: Slide {
    public let id = UUID()
    public var title: String
    public var 步骤列表: [String]
    public var 是否循环: Bool
    public var contents: SlideContent { SlideContent(["steps": 步骤列表, "isLoop": 是否循环]) }
    
    public var slideType: String { "流程图页" }
    
    public init(标题: String, 步骤: [String], 循环: Bool = false) {
        self.title = 标题
        self.步骤列表 = 步骤
        self.是否循环 = 循环
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "steps": 步骤列表,
            "isLoop": 是否循环
        ]
    }
}

@available(macOS 10.15, *)
public struct 金字塔层: Sendable, Hashable {
    public let 标签: String
    public let 占比: Int
    public let 颜色: 渐变色
    
    public init(标签: String, 占比: Int, 颜色: 渐变色 = .蓝色) {
        self.标签 = 标签
        self.占比 = 占比
        self.颜色 = 颜色
    }
    
    public func toDict() -> [String: Any] {
        ["label": 标签, "percentage": 占比, "color": 颜色.rawValue]
    }
    
    public func toSendableDict() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [:]
        dict["label"] = 标签
        dict["percentage"] = 占比
        dict["color"] = 颜色.rawValue
        return dict
    }
}

@available(macOS 10.15, *)
public struct 金字塔页: Slide {
    public let id = UUID()
    public var title: String
    public var 层级列表: [金字塔层]
    public var contents: SlideContent { 
        let layers: [any Sendable] = 层级列表.map { $0.toSendableDict() }
        return SlideContent(["layers": layers])
    }
    
    public var slideType: String { "金字塔页" }
    
    public init(标题: String, 层级: [金字塔层]) {
        self.title = 标题
        self.层级列表 = 层级
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "layers": 层级列表.map { $0.toDict() }
        ]
    }
}

@available(macOS 10.15, *)
public struct 矩阵单元格: Sendable, Hashable {
    public let 行标签: String
    public let 列标签: String
    public let 内容: String
    
    public init(行: String, 列: String, 内容: String) {
        self.行标签 = 行
        self.列标签 = 列
        self.内容 = 内容
    }
    
    public func toDict() -> [String: Any] {
        ["row": 行标签, "column": 列标签, "content": 内容]
    }
    
    public func toSendableDict() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [:]
        dict["row"] = 行标签
        dict["column"] = 列标签
        dict["content"] = 内容
        return dict
    }
}

@available(macOS 10.15, *)
public struct 矩阵页: Slide {
    public let id = UUID()
    public var title: String
    public var 行标签: [String]
    public var 列标签: [String]
    public var 单元格: [矩阵单元格]
    public var contents: SlideContent { 
        let cells: [any Sendable] = 单元格.map { $0.toSendableDict() }
        return SlideContent(["rows": 行标签, "columns": 列标签, "cells": cells])
    }
    
    public var slideType: String { "矩阵页" }
    
    public init(标题: String, 行: [String], 列: [String], 单元格: [矩阵单元格]) {
        self.title = 标题
        self.行标签 = 行
        self.列标签 = 列
        self.单元格 = 单元格
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "rows": 行标签,
            "columns": 列标签,
            "cells": 单元格.map { $0.toDict() }
        ]
    }
}

@available(macOS 10.15, *)
public struct 柏拉图项: Sendable, Hashable {
    public let 标签: String
    public let 数值: Double
    public let 是否核心: Bool
    
    public init(标签: String, 数值: Double, 核心问题: Bool = false) {
        self.标签 = 标签
        self.数值 = 数值
        self.是否核心 = 核心问题
    }
    
    public func toDict() -> [String: Any] {
        ["label": 标签, "value": 数值, "isCore": 是否核心]
    }
}

@available(macOS 10.15, *)
public struct 柏拉图页: Slide {
    public let id = UUID()
    public var title: String
    public var 项目列表: [柏拉图项]
    public var 累计占比阈值: Double
    public var contents: SlideContent { 
        let items: [any Sendable] = 项目列表.map { item -> [String: any Sendable] in
            var dict: [String: any Sendable] = [:]
            dict["label"] = item.标签
            dict["value"] = item.数值
            dict["isCore"] = item.是否核心
            return dict
        }
        return SlideContent(["items": items, "threshold": 累计占比阈值])
    }
    
    public var slideType: String { "柏拉图页" }
    
    public init(标题: String, 项目: [柏拉图项], 阈值: Double = 80.0) {
        self.title = 标题
        self.项目列表 = 项目
        self.累计占比阈值 = 阈值
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "items": 项目列表.map { $0.toDict() },
            "threshold": 累计占比阈值
        ]
    }
}

@available(macOS 10.15, *)
public struct 图片页: Slide {
    public let id = UUID()
    public var title: String
    public var 图片路径: String
    public var 说明: String?
    public var contents: SlideContent { 
        var dict: [String: any Sendable] = ["imagePath": 图片路径]
        if let 说明 = 说明 { dict["caption"] = 说明 }
        return SlideContent(dict)
    }
    
    public var slideType: String { "图片页" }
    
    public init(标题: String, 图片: String, 说明: String? = nil) {
        self.title = 标题
        self.图片路径 = 图片
        self.说明 = 说明
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "imagePath": 图片路径
        ]
        if let 说明 = 说明 { dict["caption"] = 说明 }
        return dict
    }
}

@available(macOS 10.15, *)
public struct 双栏页: Slide {
    public let id = UUID()
    public var title: String
    public var 左栏标题: String?
    public var 左栏内容: [String]
    public var 右栏标题: String?
    public var 右栏内容: [String]
    public var contents: SlideContent { 
        let left: [String: any Sendable] = ["标题": 左栏标题 ?? "", "内容": 左栏内容]
        let right: [String: any Sendable] = ["标题": 右栏标题 ?? "", "内容": 右栏内容]
        return SlideContent(["左": left, "右": right])
    }
    
    public var slideType: String { "双栏页" }
    
    public init(
        标题: String,
        左栏标题: String? = nil,
        左栏内容: [String],
        右栏标题: String? = nil,
        右栏内容: [String]
    ) {
        self.title = 标题
        self.左栏标题 = 左栏标题
        self.左栏内容 = 左栏内容
        self.右栏标题 = 右栏标题
        self.右栏内容 = 右栏内容
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "leftContent": 左栏内容,
            "rightContent": 右栏内容
        ]
        if let 左栏标题 = 左栏标题 { dict["leftTitle"] = 左栏标题 }
        if let 右栏标题 = 右栏标题 { dict["rightTitle"] = 右栏标题 }
        return dict
    }
}

@available(macOS 10.15, *)
public enum 图表类型: String, Sendable {
    case 柱状图 = "bar"
    case 折线图 = "line"
    case 饼图 = "pie"
    case 环形图 = "doughnut"
    case 雷达图 = "radar"
    case 散点图 = "scatter"
}

@available(macOS 10.15, *)
public struct 图表数据系列: Sendable {
    public let 名称: String
    public let 数值: [Double]
    
    public init(名称: String, 数值: [Double]) {
        self.名称 = 名称
        self.数值 = 数值
    }
    
    public func toDict() -> [String: Any] {
        ["name": 名称, "values": 数值]
    }
    
    public func toSendableDict() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [:]
        dict["name"] = 名称
        dict["values"] = 数值
        return dict
    }
}

@available(macOS 10.15, *)
public struct 图表页: Slide {
    public let id = UUID()
    public var title: String
    public var 图表类型值: 图表类型
    public var 标签列表: [String]
    public var 数据系列: [图表数据系列]
    public var X轴标题: String?
    public var Y轴标题: String?
    public var 显示图例: Bool
    public var contents: SlideContent { 
        let series: [any Sendable] = 数据系列.map { $0.toSendableDict() }
        return SlideContent(["chartType": 图表类型值.rawValue, "labels": 标签列表, "series": series])
    }
    
    public var slideType: String { "图表页" }
    
    public init(
        标题: String,
        类型: 图表类型,
        标签: [String],
        系列: [图表数据系列],
        X轴: String? = nil,
        Y轴: String? = nil,
        图例: Bool = true
    ) {
        self.title = 标题
        self.图表类型值 = 类型
        self.标签列表 = 标签
        self.数据系列 = 系列
        self.X轴标题 = X轴
        self.Y轴标题 = Y轴
        self.显示图例 = 图例
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "chartType": 图表类型值.rawValue,
            "labels": 标签列表,
            "series": 数据系列.map { $0.toDict() },
            "showLegend": 显示图例
        ]
        if let X轴标题 = X轴标题 { dict["xAxisTitle"] = X轴标题 }
        if let Y轴标题 = Y轴标题 { dict["yAxisTitle"] = Y轴标题 }
        return dict
    }
}

@available(macOS 12.0, *)
public struct Mermaid流程图页: Slide {
    public let id = UUID()
    public var title: String
    public var 流程图: Mermaid流程图
    public var 主题: DiagramTheme
    public var contents: SlideContent { SlideContent(["mermaidCode": 流程图.生成语法()]) }
    
    public var slideType: String { "Mermaid流程图页" }
    
    public init(标题: String, 流程图: Mermaid流程图, 主题: DiagramTheme = .default) {
        self.title = 标题
        self.流程图 = 流程图
        self.主题 = 主题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": 流程图.生成语法(),
            "diagramType": "flowchart"
        ]
        
        if let result = try? Mermaid渲染器.渲染流程图带尺寸(流程图, 主题: 主题) {
            dict["imageData"] = result.data.base64EncodedString()
            dict["imageWidth"] = result.width
            dict["imageHeight"] = result.height
        }
        
        return dict
    }
}

@available(macOS 12.0, *)
public struct Mermaid时序图页: Slide {
    public let id = UUID()
    public var title: String
    public var 时序图: Mermaid时序图
    public var 主题: DiagramTheme
    public var contents: SlideContent { SlideContent(["mermaidCode": 时序图.生成语法()]) }
    
    public var slideType: String { "Mermaid时序图页" }
    
    public init(标题: String, 时序图: Mermaid时序图, 主题: DiagramTheme = .default) {
        self.title = 标题
        self.时序图 = 时序图
        self.主题 = 主题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": 时序图.生成语法(),
            "diagramType": "sequence"
        ]
        
        if let result = try? Mermaid渲染器.渲染时序图带尺寸(时序图, 主题: 主题) {
            dict["imageData"] = result.data.base64EncodedString()
            dict["imageWidth"] = result.width
            dict["imageHeight"] = result.height
        }
        
        return dict
    }
}

@available(macOS 10.15, *)
public struct Mermaid甘特图页: Slide {
    public let id = UUID()
    public var title: String
    public var 甘特图: Mermaid甘特图
    public var contents: SlideContent { SlideContent(["mermaidCode": 甘特图.生成语法()]) }
    
    public var slideType: String { "Mermaid甘特图页" }
    
    public init(标题: String, 甘特图: Mermaid甘特图) {
        self.title = 标题
        self.甘特图 = 甘特图
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": 甘特图.生成语法(),
            "diagramType": "gantt"
        ]
    }
}

@available(macOS 12.0, *)
public struct Mermaid状态图页: Slide {
    public let id = UUID()
    public var title: String
    public var 状态代码: String
    public var 主题: DiagramTheme
    public var contents: SlideContent { SlideContent(["mermaidCode": 状态代码]) }
    
    public var slideType: String { "Mermaid状态图页" }
    
    public init(标题: String, 代码: String, 主题: DiagramTheme = .default) {
        self.title = 标题
        self.状态代码 = 代码
        self.主题 = 主题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": 状态代码,
            "diagramType": "state"
        ]
        
        if let imageData = try? Mermaid渲染器.渲染图片(mermaid代码: 状态代码, 主题: 主题) {
            dict["imageData"] = imageData.base64EncodedString()
        }
        
        return dict
    }
}

@available(macOS 12.0, *)
public struct Mermaid类图页: Slide {
    public let id = UUID()
    public var title: String
    public var 类代码: String
    public var 主题: DiagramTheme
    public var contents: SlideContent { SlideContent(["mermaidCode": 类代码]) }
    
    public var slideType: String { "Mermaid类图页" }
    
    public init(标题: String, 代码: String, 主题: DiagramTheme = .default) {
        self.title = 标题
        self.类代码 = 代码
        self.主题 = 主题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": 类代码,
            "diagramType": "class"
        ]
        
        if let imageData = try? Mermaid渲染器.渲染图片(mermaid代码: 类代码, 主题: 主题) {
            dict["imageData"] = imageData.base64EncodedString()
        }
        
        return dict
    }
}

@available(macOS 12.0, *)
public struct MermaidER图页: Slide {
    public let id = UUID()
    public var title: String
    public var ER代码: String
    public var 主题: DiagramTheme
    public var contents: SlideContent { SlideContent(["mermaidCode": ER代码]) }
    
    public var slideType: String { "MermaidER图页" }
    
    public init(标题: String, 代码: String, 主题: DiagramTheme = .default) {
        self.title = 标题
        self.ER代码 = 代码
        self.主题 = 主题
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "mermaidCode": ER代码,
            "diagramType": "er"
        ]
        
        if let imageData = try? Mermaid渲染器.渲染图片(mermaid代码: ER代码, 主题: 主题) {
            dict["imageData"] = imageData.base64EncodedString()
        }
        
        return dict
    }
}

@available(macOS 13.0, *)
public struct Gantt图页: Slide {
    public let id = UUID()
    public var title: String
    public let 甘特图: Gantt图表
    public var contents: SlideContent { 
        let dict = 甘特图.toDict()
        var sendableDict: [String: any Sendable] = [:]
        for (key, value) in dict {
            if let sendableValue = value as? String {
                sendableDict[key] = sendableValue
            } else if let sendableValue = value as? Bool {
                sendableDict[key] = sendableValue
            } else if let sendableValue = value as? Double {
                sendableDict[key] = sendableValue
            } else if let sendableValue = value as? [String] {
                sendableDict[key] = sendableValue
            } else if let sendableValue = value as? [[String: any Sendable]] {
                sendableDict[key] = sendableValue
            } else {
                sendableDict[key] = String(describing: value)
            }
        }
        return SlideContent(sendableDict)
    }
    
    public var slideType: String { "Gantt图页" }
    
    public init(标题: String, 甘特图: Gantt图表) {
        self.title = 标题
        self.甘特图 = 甘特图
    }
    
    public var notes: String? = nil
    public var hidden: Bool = false
    
    public func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "type": slideType,
            "id": id.uuidString,
            "title": title,
            "diagramType": "gantt"
        ]
        
        let result = Gantt渲染器.同步渲染(甘特图)
        if let result = result {
            dict["imageData"] = result.data.base64EncodedString()
            dict["imageWidth"] = result.width
            dict["imageHeight"] = result.height
        }
        
        return dict
    }
}
