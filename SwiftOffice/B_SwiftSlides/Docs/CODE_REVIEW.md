# 代码审查文档

## 审查日期
2026-03-04

## 审查范围
SwiftOffice 项目中的所有协议实现，重点关注是否符合设计需求。

## 设计需求回顾

### 核心设计理念
- **"内容是一味，呈现看协议"**
- 用户可以自由命名字典的 key，key 只是标识符，value 才是信息主体
- 协议决定如何从字典中提取数据，应该智能地从字典中找到匹配的值
- 同一个字典可以用不同协议呈现不同效果，数据和呈现完全分离

### 页面类型
1. **结构布局页面**（章首页、节首页）- 用模糊的 key，传递层级结构信息
2. **内容意念页面**（具体内容页面）- 用精确的 key，传递需要呈现在页面上的内容

### 协议实现要求
- **结构布局页面**：找第一个 `[any Slide]` 类型的值
- **内容意念页面**：找第一个匹配的内容类型（如 String、[String]、[[String]] 等）
- **不应该硬编码特定的 key 名称**

---

## 发现的问题

### 1. 章首页样式协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:168-179`

**当前实现**：
```swift
public protocol 章首页样式: Slide {
    var chapterNumber: Int? { get }
    var chapterSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension 章首页样式 {
    var chapterNumber: Int? {
        guard let str = contents["ChapterNumber"]?.asString else { return nil }
        return Int(str)
    }

    var chapterSlides: [any Slide] {
        contents["fellowSlides"]?.asSlideArray ?? []
    }
}
```

**问题**：
1. ❌ `chapterNumber` 是 AI 胡编的，应该删除
2. ❌ `chapterSlides` 硬编码了 `fellowSlides` key，不符合设计需求
3. ❌ 应该遍历字典，找到第一个 `[any Slide]` 类型的值

**正确实现**：
```swift
public protocol 章首页样式: Slide {
    var chapterSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension 章首页样式 {
    var chapterSlides: [any Slide] {
        for (_, value) in contents.dict {
            if let slides = value as? [any Slide] {
                return slides
            }
        }
        return []
    }
}
```

---

### 2. 节首页样式协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:184-192`

**当前实现**：
```swift
public protocol 节首页样式: Slide {
    var sectionSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension 节首页样式 {
    var sectionSlides: [any Slide] {
        contents["fellowSlides"]?.asSlideArray ?? []
    }
}
```

**问题**：
1. ❌ `sectionSlides` 硬编码了 `fellowSlides` key，不符合设计需求
2. ❌ 应该遍历字典，找到第一个 `[any Slide]` 类型的值

**正确实现**：
```swift
@available(macOS 10.15, *)
public extension 节首页样式 {
    var sectionSlides: [any Slide] {
        for (_, value) in contents.dict {
            if let slides = value as? [any Slide] {
                return slides
            }
        }
        return []
    }
}
```

---

### 3. CoverStyle 协议 - 中等错误

**位置**：`SlideStyleProtocols.swift:152-161`

**当前实现**：
```swift
public protocol CoverStyle: Slide {
    var subtitle: String? { get }
    var author: String? { get }
}

@available(macOS 10.15, *)
public extension CoverStyle {
    var subtitle: String? { contents["Subtitle"]?.asString }
    var author: String? { contents["Author"]?.asString }
}
```

**问题**：
1. ❌ 硬编码了 `Subtitle` 和 `Author` key
2. ⚠️ 这些是内容意念页面的属性，可能需要保留特定的 key

**需要讨论**：
- CoverStyle 是结构布局页面还是内容意念页面？
- 如果是内容意念页面，是否需要硬编码 key？

---

### 4. ContentStyle 协议 - 部分正确

**位置**：`SlideStyleProtocols.swift:197-203`

**当前实现**：
```swift
public protocol ContentStyle: Slide {
    var items: [String] { get }
}

@available(macOS 10.15, *)
public extension ContentStyle {
    var items: [String] { ContentParser.parseStringArray(contents) }
}
```

**问题**：
1. ✅ 使用了 `ContentParser.parseStringArray`，这个方法遍历字典
2. ⚠️ 但 `ContentParser.parseStringArray` 的实现有问题

**ContentParser.parseStringArray 实现**：
```swift
public static func parseStringArray(_ contents: Contents) -> [String] {
    let dict = contents.dict
    for (_, value) in dict {
        if let str = value as? String {
            return [str]
        }
    }
    return contents.asStringArray  // ❌ 这里又回退到依赖 key
}
```

**问题**：
- `contents.asStringArray` 的实现可能硬编码了 `items` key

**SlideContent.asStringArray 实现**：
```swift
public var asStringArray: [String] {
    if let arr = dict["items"] as? [String] { return arr }
    if let arr = dict.first?.value as? [String] { return arr }
    return []
}
```

**问题**：
- 虽然有 fallback 到 `dict.first?.value`，但优先硬编码了 `items` key

**建议**：
- 应该完全遍历字典，找到第一个 `[String]` 类型的值

---

### 5. TextStyle 协议 - 部分正确

**位置**：`SlideStyleProtocols.swift:208-214`

**当前实现**：
```swift
public protocol TextStyle: Slide {
    var content: String { get }
}

@available(macOS 10.15, *)
public extension TextStyle {
    var content: String { ContentParser.parseString(contents) }
}
```

**ContentParser.parseString 实现**：
```swift
public static func parseString(_ contents: Contents) -> String {
    for (_, value) in contents.dict {
        if let str = value as? String {
            return str
        }
    }
    return contents.asString  // ❌ 这里又回退到依赖 key
}
```

**问题**：
- `contents.asString` 的实现可能硬编码了 `content` key

**SlideContent.asString 实现**：
```swift
public var asString: String {
    if let str = dict["content"] as? String { return str }
    if let str = dict.first?.value as? String { return str }
    return ""
}
```

**问题**：
- 虽然有 fallback 到 `dict.first?.value`，但优先硬编码了 `content` key

---

### 6. TwoColumnStyle 协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:224-233`

**当前实现**：
```swift
public protocol TwoColumnStyle: Slide {
    var leftTitle: String? { get }
    var leftItems: [String] { get }
    var rightTitle: String? { get }
    var rightItems: [String] { get }
}

@available(macOS 10.15, *)
public extension TwoColumnStyle {
    var leftTitle: String? { nil }
    var rightTitle: String? { nil }
    var leftItems: [String] { contents.dict["left"] as? [String] ?? [] }
    var rightItems: [String] { contents.dict["right"] as? [String] ?? [] }
}
```

**问题**：
1. ❌ 硬编码了 `left` 和 `right` key
2. ❌ 这不符合设计需求

**需要讨论**：
- TwoColumnStyle 的布局结构是否需要特定的 key？
- 如果需要，是否应该在文档中明确说明？

---

### 7. CardStyle 协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:238-250`

**当前实现**：
```swift
public protocol CardStyle: Slide {
    var cards: [SlideCard] { get }
    var columns: Int { get }
}

@available(macOS 10.15, *)
public extension CardStyle {
    var cards: [SlideCard] {
        (contents.dict["cards"] as? [[String: String]])?.map { SlideCard(title: $0["title"] ?? "", content: $0["content"] ?? "") } ?? []
    }
    var columns: Int { contents.dict["columns"] as? Int ?? 2 }
}
```

**问题**：
1. ❌ 硬编码了 `cards` 和 `columns` key
2. ❌ 这不符合设计需求

**需要讨论**：
- CardStyle 的布局结构是否需要特定的 key？
- 如果需要，是否应该在文档中明确说明？

---

### 8. TableSlideStyle 协议 - 部分正确

**位置**：`SlideStyleProtocols.swift:265-273`

**当前实现**：
```swift
public protocol TableSlideStyle: Slide {
    var headers: [String] { get }
    var rows: [[String]] { get }
}

@available(macOS 10.15, *)
public extension TableSlideStyle {
    var headers: [String] {
        let (h, _) = ContentParser.parseTable(contents)
        return h
    }
    var rows: [[String]] {
        let (_, r) = ContentParser.parseTable(contents)
        return r
    }
}
```

**ContentParser.parseTable 实现**：
```swift
public static func parseTable(_ contents: Contents) -> (headers: [String], rows: [[String]]) {
    // Format 1: Column-oriented (spreadsheet style)
    // ["Category": ["A", "B"], "Value": ["1", "2"]]
    let dict = contents.dict
    let columnKeys = dict.keys.filter { key in
        if let arr = dict[key] as? [String] { return !arr.isEmpty }
        return false
    }
    if !columnKeys.isEmpty {
        let headers = Array(columnKeys)
        guard let firstColumn = dict[headers[0]] as? [String] else { return ([], []) }
        let rowCount = firstColumn.count
        var rows: [[String]] = []
        for i in 0..<rowCount {
            var row: [String] = []
            for header in headers {
                if let column = dict[header] as? [String], i < column.count {
                    row.append(column[i])
                }
            }
            rows.append(row)
        }
        return (headers, rows)
    }

    // 格式2: 按行组织（传统格式）
    let headers = contents["headers"]?.asStringArray ?? []  // ❌ 硬编码
    let rows = contents["rows"]?.asStringTable ?? []        // ❌ 硬编码
    if !headers.isEmpty || !rows.isEmpty {
        return (headers, rows)
    }
    let arr = contents.asStringTable
    if arr.count > 1 {
        return (arr[0], Array(arr[1...]))
    }
    return ([], [])
}
```

**问题**：
1. ✅ 第一种格式（列导向）是正确的，遍历字典找到所有 `[String]` 类型的值
2. ❌ 第二种格式硬编码了 `headers` 和 `rows` key

**建议**：
- 只保留第一种格式，删除第二种格式
- 或者明确说明第二种格式是可选的，用于特殊场景

---

### 9. 横框图样式和竖框图样式协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:632-660`

**当前实现**：
```swift
@available(macOS 10.15, *)
public extension 横框图样式 {
    var boxLayout: SlideBoxLayout { .horizontal }

    var boxes: [SlideBox] {
        let items = contents["items"]?.asContentsArray ?? []  // ❌ 硬编码
        return items.compactMap { item in
            guard let title = item["title"]?.asString else {
                return nil
            }
            let content = item["content"]?.asStringArray ?? []
            return SlideBox(title: title, content: content)
        }
    }
}

@available(macOS 10.15, *)
public extension 竖框图样式 {
    var boxLayout: SlideBoxLayout { .vertical }

    var boxes: [SlideBox] {
        let items = contents["items"]?.asContentsArray ?? []  // ❌ 硬编码
        return items.compactMap { item in
            guard let title = item["title"]?.asString else {
                return nil
            }
            let content = item["content"]?.asStringArray ?? []
            return SlideBox(title: title, content: content)
        }
    }
}
```

**问题**：
1. ❌ 硬编码了 `items` key
2. ❌ 这不符合设计需求

---

### 10. 层次架构图样式协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:888-897`

**当前实现**：
```swift
@available(macOS 10.15, *)
public extension 层次架构图样式 {
    var direction: String { "topDown" }
}
```

**缺少实现**：
- 协议定义了 `levels: [[String]]` 属性，但没有默认实现
- 需要检查是否有其他地方实现了这个属性

**需要进一步检查**

---

### 11. HierarchyStyle 协议 - 严重错误

**位置**：`SlideStyleProtocols.swift:901-914`

**当前实现**：
```swift
@available(macOS 10.15, *)
public protocol HierarchyStyle: Slide {
    var hierarchyLevels: [[String]] { get }
}

@available(macOS 10.15, *)
public extension HierarchyStyle {
    var hierarchyLevels: [[String]] {
        if let levels = contents["levels"]?.asStringArray {  // ❌ 硬编码
            return [levels]
        }
        if let levels = contents["levels"]?.asStringTable {  // ❌ 硬编码
            return levels
        }
        return []
    }
}
```

**问题**：
1. ❌ 硬编码了 `levels` key
2. ❌ 这不符合设计需求

---

### 12. SlideContent 的辅助方法 - 部分问题

**位置**：`Slide.swift:60-100`

**当前实现**：
```swift
public var asStringArray: [String] {
    if let arr = dict["items"] as? [String] { return arr }
    if let arr = dict.first?.value as? [String] { return arr }
    return []
}

public var asStringTable: [[String]] {
    if let arr = dict["rows"] as? [[String]] { return arr }
    if let arr = dict.first?.value as? [[String]] { return arr }
    return []
}

public var asDictArray: [[String: any Sendable]] {
    if let arr = dict["items"] as? [[String: any Sendable]] { return arr }
    if let arr = dict.first?.value as? [[String: any Sendable]] { return arr }
    return []
}

public var asContentsArray: [SlideContent] {
    if let arr = dict["items"] as? [[String: any Sendable]] {
        return arr.map { SlideContent($0) }
    }
    if let arr = dict.first?.value as? [[String: any Sendable]] {
        return arr.map { SlideContent($0) }
    }
    return []
}

public var asSectionArray: [any Section] {
    if let arr = dict["sections"] as? [any Section] {
        return arr
    }
    if let arr = dict["Sections"] as? [any Section] {
        return arr
    }
    return []
}

public var asSlideArray: [any Slide] {
    if let arr = dict["slides"] as? [any Slide] {
        return arr
    }
    if let arr = dict["Slides"] as? [any Slide] {
        return arr
    }
    return []
}
```

**问题**：
1. ⚠️ `asSectionArray` 和 `asSlideArray` 硬编码了 `sections`/`Sections` 和 `slides`/`Slides` key
2. ⚠️ 这些方法可能用于 Presentation 和 Section 的实现，需要特殊处理

**需要讨论**：
- Presentation 和 Section 是否需要特定的 key？
- 如果需要，是否应该在文档中明确说明？

---

### 13. Presentation 协议 - 需要讨论

**位置**：`Presentation.swift:30`

**当前实现**：
```swift
var author: String? { contents["Author"]?.asString }
```

**问题**：
1. ❌ 硬编码了 `Author` key

**需要讨论**：
- Presentation 是否需要特定的 key？
- 如果需要，是否应该在文档中明确说明？

---

### 14. Section 协议 - 需要讨论

**位置**：`Section.swift:27`

**当前实现**：
```swift
var slides: [any Slide] {
    contents.asSlideArray
}
```

**问题**：
1. ⚠️ 依赖于 `asSlideArray`，而 `asSlideArray` 硬编码了 `slides`/`Slides` key

**需要讨论**：
- Section 是否需要特定的 key？
- 如果需要，是否应该在文档中明确说明？

---

## 总结

### 严重错误（必须修复）

1. ❌ `章首页样式` 协议 - 硬编码 `fellowSlides`，有 `chapterNumber` 胡编属性
2. ❌ `节首页样式` 协议 - 硬编码 `fellowSlides`
3. ❌ `TwoColumnStyle` 协议 - 硬编码 `left` 和 `right`
4. ❌ `CardStyle` 协议 - 硬编码 `cards` 和 `columns`
5. ❌ `横框图样式` 协议 - 硬编码 `items`
6. ❌ `竖框图样式` 协议 - 硬编码 `items`
7. ❌ `HierarchyStyle` 协议 - 硬编码 `levels`

### 中等错误（需要讨论）

1. ⚠️ `CoverStyle` 协议 - 硬编码 `Subtitle` 和 `Author`
2. ⚠️ `TableSlideStyle` 协议 - 第二种格式硬编码 `headers` 和 `rows`
3. ⚠️ `ContentParser.parseStringArray` - 回退到依赖 `items` key
4. ⚠️ `ContentParser.parseString` - 回退到依赖 `content` key
5. ⚠️ `SlideContent.asStringArray` - 优先硬编码 `items` key
6. ⚠️ `SlideContent.asString` - 优先硬编码 `content` key

### 需要讨论的设计问题

1. **Presentation 和 Section 是否需要特定的 key？**
   - `asSectionArray` 和 `asSlideArray` 硬编码了 `sections`/`Sections` 和 `slides`/`Slides` key
   - 如果需要，是否应该在文档中明确说明？

2. **布局结构协议是否需要特定的 key？**
   - `TwoColumnStyle`、`CardStyle` 等布局结构协议硬编码了特定的 key
   - 这些 key 是否是布局结构的一部分，需要硬编码？

3. **内容意念页面是否可以硬编码 key？**
   - `CoverStyle` 硬编码了 `Subtitle` 和 `Author`
   - 这些是内容意念页面的属性，是否可以硬编码？

---

## 建议的修复顺序

1. **第一阶段**：修复严重错误
   - 修复 `章首页样式` 和 `节首页样式` 协议
   - 删除 `chapterNumber` 胡编属性

2. **第二阶段**：讨论设计问题
   - 讨论哪些协议需要硬编码 key
   - 更新设计需求文档，明确说明特殊情况

3. **第三阶段**：修复中等错误
   - 修复 `ContentParser` 和 `SlideContent` 的辅助方法
   - 修复其他协议的实现

---

## 待讨论问题

1. Presentation 和 Section 是否需要特定的 key？
2. 布局结构协议（如 `TwoColumnStyle`、`CardStyle`）是否需要特定的 key？
3. 内容意念页面（如 `CoverStyle`）是否可以硬编码 key？
4. `TableSlideStyle` 的第二种格式是否需要保留？
