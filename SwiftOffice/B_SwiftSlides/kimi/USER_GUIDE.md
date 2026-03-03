# SwiftSlides 用户指南

## 概述

SwiftSlides 让你用 Swift 代码创建 PowerPoint 演示文稿，而不是在图形界面中手动操作。这种方式带来以下优势：

- **可复用** - 定义一次，多次使用
- **可组合** - 像搭积木一样组合幻灯片
- **可版本控制** - 用 Git 管理你的演示文稿
- **可自动化** - 从数据自动生成幻灯片

## 两种使用模式

### 模式一：Protocol Composition（推荐）

适合：想要完全控制内容和样式的用户

特点：
- 数据与呈现完全分离
- 使用 Protocol 组合定义幻灯片样式
- 代码简洁，易于理解

### 模式二：Builder DSL

适合：需要快速使用预定义幻灯片类型的用户

特点：
- 使用闭包构建器语法
- 23 种预定义幻灯片类型
- 内置主题和模板

## Protocol Composition 模式详解

### 基本结构

```swift
import SwiftSlides

// 1. 定义 Presentation（整个 PPTX 文件）
struct 我的演示: Presentation {
    var title = "演示标题"
    var sections: [any Section] = [
        // 章节列表
    ]
}

// 2. 定义 Section（章节）
struct 第一章: Section {
    var title = "章节标题"
    var slides: [any Slide] = [
        // 幻灯片列表
    ]
}

// 3. 定义 Slide（单页幻灯片）
struct 封面: Slide, 封面样式 {
    var title = "封面标题"
    var subtitle: String? = "副标题"
}
```

### 样式协议

通过 Protocol 组合，你可以给幻灯片添加不同的能力：

```swift
// 封面样式 - 用于演示文稿第一页
struct 封面: Slide, 封面样式 {
    var title = "标题"
    var subtitle: String? = "副标题"
    var author: String? = "作者"
}

// 章节样式 - 用于章节分隔页
struct 章节首页: Slide, 章节样式 {
    var title = "章节标题"
    var chapterNumber: Int? = 1
}

// 内容样式 - 用于列表内容
struct 内容页: Slide, 内容样式 {
    var title = "内容标题"
    var items = [
        "第一点",
        "第二点",
        "第三点",
    ]
}
```

### 创建新幻灯片

1. **确定用途** - 这是封面、章节页还是内容页？
2. **选择协议** - 根据用途选择对应的样式协议
3. **定义结构** - 创建 struct 并实现必要属性

示例：创建一个带图片的内容页

```swift
// 定义新的样式协议
protocol 图文样式: Slide {
    var imageURL: String { get }
    var description: String { get }
}

// 使用新协议
struct 产品介绍: Slide, 图文样式 {
    var title = "产品名称"
    var imageURL = "product.png"
    var description = "产品描述文字"
    var items = [
        "特点一",
        "特点二",
    ]
}
```

### 组织多个章节

```swift
struct 完整演示: Presentation {
    var title = "年度总结"
    var sections: [any Section] = [
        封面章节(),
        业绩章节(),
        展望章节(),
    ]
}

struct 封面章节: Section {
    var title = "封面"
    var slides: [any Slide] = [
        封面页(),
    ]
}

struct 业绩章节: Section {
    var title = "业绩回顾"
    var slides: [any Slide] = [
        章节首页(),
        销售数据(),
        增长分析(),
    ]
}
```

## 生成 PPTX

### 使用 Swift Package

```bash
# 生成 PPTX
swift run UserPresentation

# 输出位置
# outputs/演示标题.pptx
```

### 使用脚本模式

```bash
# 直接运行 Swift 脚本
swift Demo/医院管理总览.swift
```

## 最佳实践

### 1. 命名规范

- Presentation 使用演示主题命名：`年度总结报告`
- Section 使用章节内容命名：`业绩回顾`、`市场分析`
- Slide 使用具体页面命名：`封面页`、`销售数据图表`

### 2. 内容组织

```swift
// 好的做法：清晰的分层
struct 年度报告: Presentation {
    var sections: [any Section] = [
        封面部分(),
        第一部分_业绩(),
        第二部分_展望(),
        结束部分(),
    ]
}

// 避免：过于复杂的嵌套
struct 混乱的演示: Presentation {
    var sections: [any Section] = [
        // 太多内联定义，难以维护
    ]
}
```

### 3. 复用组件

```swift
// 定义可复用的章节
struct 标准封面: Section {
    var title = "封面"
    var 演示标题: String
    var 副标题: String
    
    var slides: [any Slide] {
        [
            封面页(title: 演示标题, subtitle: 副标题),
        ]
    }
}

// 在不同演示中复用
struct 演示A: Presentation {
    var sections: [any Section] = [
        标准封面(演示标题: "演示A", 副标题: "2024"),
        // ...
    ]
}

struct 演示B: Presentation {
    var sections: [any Section] = [
        标准封面(演示标题: "演示B", 副标题: "2024"),
        // ...
    ]
}
```

## 故障排除

### 构建错误

**错误**：`type 'XXX' does not conform to protocol 'Presentation'`

**解决**：确保实现了所有必需属性：
```swift
struct 我的演示: Presentation {
    var title = "标题"           // 必需
    var sections: [any Section] = []  // 必需
    var author: String? = nil    // 可选
    var theme: 主题? = nil       // 可选
}
```

### 生成失败

**错误**：PPTX 生成失败

**检查**：
1. Node.js 是否安装：`node --version`
2. 依赖是否安装：`npm install`
3. 输出目录是否存在：自动创建 `outputs/`

## 示例代码

查看 `Sources/UserPresentation/main.swift` 获取完整示例。

更多示例见 `Demo/` 目录。
