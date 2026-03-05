# 代码修改计划

## 计划日期
2026-03-04

## 修改原则

1. **凡是用户提供的东西，都不应该有任何硬编码**
2. **协议本身是系统定义的，用户必须使用**
3. **支持多语言 key，通过 type alias 解决语言问题**
4. **对于布局结构协议，支持多种语言的 key**
5. **如果分不清用户意图，使用默认逻辑（如 array[0] 当左）**

---

## 修改计划

### 第一阶段：修复严重错误

#### 0. 修复 Contents 类型定义

**文件**：`Slide.swift` 或 `SlideStyleProtocols.swift`

**当前问题**：
- ❌ `Contents` 类型未定义，但代码中大量使用
- ❌ 命名错误：`Contents` 用复数不合适，官方协议或结构体不会用复数命名

**说明**：
- `Contents` 应该是 `SlideContent` 的 typealias
- 命名应该用单数 `Content` 或直接使用 `SlideContent`
- 当前代码中 `Contents` 被用于 `Section` 和 `Presentation` 协议的 `contents` 属性

**修改方案**：

**方案 1：添加 typealias（推荐）**
```swift
// 在 Slide.swift 或 SlideStyleProtocols.swift 顶部添加
public typealias Content = SlideContent
```

**方案 2：直接使用 SlideContent**
- 将所有 `Contents` 替换为 `SlideContent`
- 将所有 `contents: Contents` 替换为 `contents: SlideContent`

---

#### 1. 修复 ChapterCoverStyle 协议

**文件**：`SlideStyleProtocols.swift:168-179`

**当前问题**：
- ❌ 有 `chapterNumber` 胡编属性
- ❌ `chapterSlides` 硬编码了 `fellowSlides` key

**说明**：
- 协议名称使用中文"章"而不是英文"Chapter"，是因为"章节"翻译成英文有冲突和歧义问题
- "节"不能翻译成 Section，因为 Section 是 PowerPoint 的专有名词，用于对幻灯片进行分组管理

**修改方案**：
```swift
public protocol ChapterCoverStyle: Slide {
    var chapterSlides: [any Slide] { get }
}

@available(macOS 10.15, *)
public extension ChapterCoverStyle {
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

#### 2. 修复 NodeCoverStyle 协议

**文件**：`SlideStyleProtocols.swift:184-192`

**当前问题**：
- ❌ `sectionSlides` 硬编码了 `fellowSlides` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension NodeCoverStyle {
    var nodeSlides: [any Slide] {
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

#### 3. 修复 TwoColumnStyle 协议

**文件**：`SlideStyleProtocols.swift:224-233`

**当前问题**：
- ❌ 硬编码了 `left` 和 `right` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension TwoColumnStyle {
    var leftTitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(左|left)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var rightTitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(右|right)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var leftItems: [String] {
        for (key, value) in contents.dict {
            let pattern = "^(左|left)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? [String] ?? []
            }
        }
        return []
    }
    
    var rightItems: [String] {
        for (key, value) in contents.dict {
            let pattern = "^(右|right)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? [String] ?? []
            }
        }
        return []
    }
}
```

**说明**：
- 支持多种语言的 key（中文、英文等）
- 如果分不清用户意图，使用默认逻辑

---

#### 4. 修复 CardStyle 协议

**文件**：`SlideStyleProtocols.swift:238-250`

**当前问题**：
- ❌ 硬编码了 `cards` 和 `columns` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension CardStyle {
    var cards: [SlideCard] {
        for (_, value) in contents.dict {
            if let cardArray = value as? [[String: String]] {
                return cardArray.map { SlideCard(title: $0["title"] ?? "", content: $0["content"] ?? "") }
            }
        }
        return []
    }
    
    var columns: Int {
        let cardCount = cards.count
        if cardCount <= 2 { return 1 }
        if cardCount <= 6 { return 2 }
        if cardCount <= 12 { return 3 }
        return 4
    }
}
```

---

#### 5. 修复 横框图样式 协议

**文件**：`SlideStyleProtocols.swift:632-645`

**当前问题**：
- ❌ 硬编码了 `items` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension 横框图样式 {
    var boxLayout: SlideBoxLayout { .horizontal }
    
    var boxes: [SlideBox] {
        for (_, value) in contents.dict {
            if let items = value as? [[String: any Sendable]] {
                return items.compactMap { item in
                    let dict = item as? [String: any Sendable] ?? [:]
                    let title = dict["title"] as? String
                    let content = dict["content"] as? [String] ?? []
                    return SlideBox(title: title, content: content)
                }
            }
        }
        return []
    }
}
```

---

#### 6. 修复 竖框图样式 协议

**文件**：`SlideStyleProtocols.swift:647-660`

**当前问题**：
- ❌ 硬编码了 `items` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension 竖框图样式 {
    var boxLayout: SlideBoxLayout { .vertical }
    
    var boxes: [SlideBox] {
        for (_, value) in contents.dict {
            if let items = value as? [[String: any Sendable]] {
                return items.compactMap { item in
                    let dict = item as? [String: any Sendable] ?? [:]
                    let title = dict["title"] as? String
                    let content = dict["content"] as? [String] ?? []
                    return SlideBox(title: title, content: content)
                }
            }
        }
        return []
    }
}
```

---

#### 7. 修复 HierarchyStyle 协议

**文件**：`SlideStyleProtocols.swift:901-914`

**当前问题**：
- ❌ 硬编码了 `levels` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension HierarchyStyle {
    var hierarchyLevels: [[String]] {
        for (_, value) in contents.dict {
            if let levels = value as? [String] {
                return [levels]
            }
            if let levels = value as? [[String]] {
                return levels
            }
        }
        return []
    }
}
```

---

### 第二阶段：修复中等错误

#### 8. 修复 CoverStyle 协议

**文件**：`SlideStyleProtocols.swift:152-161`

**当前问题**：
- ❌ 硬编码了 `Subtitle` 和 `Author` key

**修改方案**：
```swift
@available(macOS 10.15, *)
public extension CoverStyle {
    var subtitle: String? {
        for (key, value) in contents.dict {
            let pattern = "^(副标题|subtitle)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
    
    var author: String? {
        for (key, value) in contents.dict {
            let pattern = "^(作者|author)$"
            if key.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil {
                return value as? String
            }
        }
        return nil
    }
}
```

---

#### 9. 修复 TableSlideStyle 协议

**文件**：`SlideStyleProtocols.swift:265-273`

**当前问题**：
- ❌ 第二种格式硬编码了 `headers` 和 `rows` key

**修改方案**：
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
    
    // Format 2: Row-oriented (traditional format) - 支持多语言
    var headers: [String] = []
    var rows: [[String]] = []
    
    for (key, value) in dict {
        if ["表头", "headers", "header", "标题", "titles"].contains(key.lowercased()) {
            headers = value as? [String] ?? []
        }
        if ["行", "rows", "row", "数据", "data"].contains(key.lowercased()) {
            rows = value as? [[String]] ?? []
        }
    }
    
    if !headers.isEmpty || !rows.isEmpty {
        return (headers, rows)
    }
    
    // Fallback: try to parse as string table
    let arr = contents.asStringTable
    if arr.count > 1 {
        return (arr[0], Array(arr[1...]))
    }
    return ([], [])
}
```

---

#### 10. 修复 ContentParser.parseStringArray

**文件**：`SlideStyleProtocols.swift:24-33`

**当前问题**：
- ⚠️ 回退到依赖 `items` key

**修改方案**：
```swift
public static func parseStringArray(_ contents: Contents) -> [String] {
    let dict = contents.dict
    for (_, value) in dict {
        if let str = value as? String {
            return [str]
        }
        if let arr = value as? [String] {
            return arr
        }
    }
    return []
}
```

---

#### 11. 修复 ContentParser.parseString

**文件**：`SlideStyleProtocols.swift:35-41`

**当前问题**：
- ⚠️ 回退到依赖 `content` key

**修改方案**：
```swift
public static func parseString(_ contents: Contents) -> String {
    for (_, value) in contents.dict {
        if let str = value as? String {
            return str
        }
    }
    return ""
}
```

---

#### 12. 修复 SlideContent.asStringArray

**文件**：`Slide.swift:68-72`

**当前问题**：
- ⚠️ 优先硬编码 `items` key

**修改方案**：
```swift
public var asStringArray: [String] {
    for (_, value) in dict {
        if let arr = value as? [String] {
            return arr
        }
    }
    return []
}
```

---

#### 13. 修复 SlideContent.asString

**文件**：`Slide.swift:60-65`

**当前问题**：
- ⚠️ 优先硬编码 `content` key

**修改方案**：
```swift
public var asString: String {
    for (_, value) in dict {
        if let str = value as? String {
            return str
        }
    }
    return ""
}
```

---

#### 14. 修复 SlideContent.asStringTable

**文件**：`Slide.swift:74-78`

**当前问题**：
- ⚠️ 优先硬编码 `rows` key

**修改方案**：
```swift
public var asStringTable: [[String]] {
    for (_, value) in dict {
        if let arr = value as? [[String]] {
            return arr
        }
    }
    return []
}
```

---

#### 15. 修复 SlideContent.asDictArray

**文件**：`Slide.swift:80-84`

**当前问题**：
- ⚠️ 优先硬编码 `items` key

**修改方案**：
```swift
public var asDictArray: [[String: any Sendable]] {
    for (_, value) in dict {
        if let arr = value as? [[String: any Sendable]] {
            return arr
        }
    }
    return []
}
```

---

#### 16. 修复 SlideContent.asContentsArray

**文件**：`Slide.swift:86-95`

**当前问题**：
- ⚠️ 优先硬编码 `items` key

**修改方案**：
```swift
public var asContentsArray: [SlideContent] {
    for (_, value) in dict {
        if let arr = value as? [[String: any Sendable]] {
            return arr.map { SlideContent($0) }
        }
    }
    return []
}
```

---

### 第三阶段：讨论是否需要修改

#### 17. 讨论 Presentation 协议

**文件**：`Presentation.swift:30`

**当前问题**：
- ❌ 硬编码了 `Author` key

**修改方案**：
```swift
var author: String? {
    for (key, value) in contents.dict {
        if ["作者", "author", "Author", "著者", "作成者"].contains(key.lowercased()) {
            return value as? String
        }
    }
    return nil
}
```

---

#### 18. 讨论 Section 协议

**文件**：`Section.swift:27`

**当前问题**：
- ⚠️ 依赖于 `asSlideArray`，而 `asSlideArray` 硬编码了 `slides`/`Slides` key

**修改方案**：
```swift
var slides: [any Slide] {
    for (_, value) in contents.dict {
        if let slides = value as? [any Slide] {
            return slides
        }
    }
    return []
}
```

---

#### 19. 讨论 SlideContent.asSectionArray

**文件**：`Slide.swift:97-103`

**当前问题**：
- ⚠️ 硬编码了 `sections`/`Sections` key

**修改方案**：
```swift
public var asSectionArray: [any Section] {
    for (_, value) in dict {
        if let sections = value as? [any Section] {
            return sections
        }
    }
    return []
}
```

---

#### 20. 讨论 SlideContent.asSlideArray

**文件**：`Slide.swift:105-111`

**当前问题**：
- ⚠️ 硬编码了 `slides`/`Slides` key

**修改方案**：
```swift
public var asSlideArray: [any Slide] {
    for (_, value) in dict {
        if let slides = value as? [any Slide] {
            return slides
        }
    }
    return []
}
```

---

## 修改优先级

### 高优先级（必须修复）
1. ChapterCoverStyle 协议
2. NodeCoverStyle 协议
3. TwoColumnStyle 协议
4. CardStyle 协议
5. 横框图样式 协议
6. 竖框图样式 协议
7. HierarchyStyle 协议

### 中优先级（建议修复）
8. CoverStyle 协议
9. TableSlideStyle 协议
10. ContentParser.parseStringArray
11. ContentParser.parseString
12. SlideContent.asStringArray
13. SlideContent.asString
14. SlideContent.asStringTable
15. SlideContent.asDictArray
16. SlideContent.asContentsArray

### 低优先级（需要讨论）
17. Presentation 协议
18. Section 协议
19. SlideContent.asSectionArray
20. SlideContent.asSlideArray

---

## 待讨论问题

1. **高优先级修改是否正确？**
   - 多语言 key 的支持是否合理？
   - 是否有遗漏的语言？

2. **中优先级修改是否正确？**
   - 是否所有辅助方法都需要修改？
   - 是否有其他需要修改的地方？

3. **低优先级修改是否需要？**
   - Presentation 和 Section 是否需要特殊处理？
   - 这些是否是结构布局页面，需要保留硬编码？

4. **修改顺序是否合理？**
   - 是否应该先修改高优先级，测试通过后再修改中优先级？
   - 是否应该一次性修改所有？

---

## 测试计划

修改完成后，需要进行以下测试：

1. **单元测试**：确保所有协议的默认实现正确
2. **集成测试**：确保整个演示文稿生成流程正确
3. **多语言测试**：测试不同语言的 key 是否都能正确识别
4. **边界测试**：测试空字典、缺失 key 等边界情况

---

## 总结

本计划共包含 20 个修改项，分为三个优先级：
- 高优先级：7 个
- 中优先级：9 个
- 低优先级：4 个

所有修改都遵循"凡是用户提供的东西，都不应该有任何硬编码"的原则，支持多语言 key，通过类型匹配和语义推断来提取数据。
