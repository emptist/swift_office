# PresentationRunner 使用指南

## 概述

`PresentationRunner` 是一个通用的演示文稿生成库，用于将任何符合 `Presentation` 协议的对象转换为 PPTX 文件。

## 五层结构

SwiftSlides 使用五层结构来组织演示文稿：

```
Presentation (演示文稿/古书) ─ 物理整体
  │
  └── Section (册) ─ 物理分组（如上册、下册）
        │
        └── Chapter (章) ─ 逻辑分组（如第一章）
              │
              └── Node (节) ─ 逻辑分组（如1.1节）
                    │
                    └── Slide (幻灯片) ─ 内容单元
```

**层级规则：**

1. **顺序固定**：层级顺序始终为 Presentation → Section → Chapter → Node → Slide
2. **不能倒序**：不能从下往上跳（例如 Slide 不能包含 Node）
3. **灵活组合**：用户可以根据需要跳过任何中间层级
4. **自动编号**：所有层级的编号都根据数组索引自动生成

### 自动编号系统

**重要**：Section、Chapter 和 Node 的编号根据它们在父级数组中的位置自动生成。用户不应手动设置任何编号，以避免硬编码。

**工作原理：**

```swift
// 用户编写：
struct MyPresentation: ChapterBasedPresentation {
    let title = "我的课程"
    let chapters: [any Chapter] = [
        Chapter1(),  // 位置 0
        Chapter2(),  // 位置 1
        Chapter3(),  // 位置 2
    ]
}

// 系统自动生成：
// Chapter 1 → "第1章"
// Chapter 2 → "第2章"
// Chapter 3 → "第3章"
```

**编号格式：**

| 层级 | 数组索引 | 自动生成的显示 |
|-------|---------|---------------|
| Section 1 | 0 | "第1册" |
| Section 2 | 1 | "第2册" |
| Chapter 1 | 0 | "第1章" |
| Chapter 2 | 1 | "第2章" |
| Node 1 | 0 | "1.1节" |
| Node 2 | 1 | "1.2节" |

**优势：**

- ✅ **无硬编码**：编号从数组结构动态生成
- ✅ **极致灵活**：可以在任何位置添加/删除项目而无需手动重新编号
- ✅ **自动更新**：数组更改时编号自动更新
- ✅ **样式控制显示**：PPTX 生成可以根据主题选择显示/隐藏编号

**实现细节：**

编号在 JSON 序列化期间生成（`toDict()` 方法）：

```swift
// 在 Presentation.swift 中
dict["chapters"] = chapters.enumerated().map { index, chapter in
    chapter.toDict(chapterIndex: index)  // 将索引传递给子级
}

// 在 Chapter.swift 中
func toDict(chapterIndex: Int? = nil) -> [String: Any] {
    var dict: [String: Any] = [...]
    
    if let chapterIndex = chapterIndex {
        dict["chapterNumber"] = chapterIndex + 1
        dict["chapterNumberDisplay"] = "第\(chapterIndex + 1)章"
    }
    
    return dict
}
```

**有效组合示例：**

```swift
// 示例 1：简单 - 跳过所有中间层级
struct SimplePresentation: Presentation {
    let title = "简单演示"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// 示例 2：使用 Section - 跳过 Chapter 和 Node
struct SectionPresentation: Presentation {
    let title = "分册演示"
    let sections: [any Section] = [Section1()]
}

struct Section1: Section {
    let title = "第一册"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// 示例 3：使用 Chapter - 跳过 Section 和 Node
struct ChapterPresentation: Presentation {
    let title = "分章演示"
    let chapters: [any Chapter] = [Chapter1()]
}

struct Chapter1: Chapter {
    let title = "第一章"
    let slides: [any Slide] = [Slide1(), Slide2()]
}

// 示例 4：完整层级 - 所有层级
struct FullPresentation: Presentation {
    let title = "完整演示"
    let sections: [any Section] = [Section1()]
}

struct Section1: Section {
    let title = "第一册"
    let chapters: [any Chapter] = [Chapter1()]
}

struct Chapter1: Chapter {
    let title = "第一章"
    let nodes: [any Node] = [Node1()]
}

struct Node1: Node {
    let title = "1.1节"
    let slides: [any Slide] = [Slide1()]
}
```

**关键点：**
- 每一层只能包含下一层或更下层的元素
- Presentation 可以包含 Section、Chapter、Node 或 Slide
- Section 可以包含 Chapter、Node 或 Slide
- Chapter 可以包含 Node 或 Slide
- Node 可以包含 Slide
- Slide 是最底层，不能再包含其他层级

## 设计理念

**"一次定义，随处复用"**

- 用户只需定义 `Presentation`、`Section` 和 `Slide` 结构
- 使用 `PresentationRunner.generate()` 统一生成 PPTX
- 无需为每个演示文稿创建单独的 runner

## 基本用法

### 1. 导入库

```swift
import SwiftSlides
import Runner
```

### 2. 定义演示文稿

```swift
struct MyPresentation: Presentation {
    let title = "我的演示文稿"
    let contents: SlideContent = SlideContent([
        "author": "作者姓名",
        "date": "2024"
    ])
    
    var author: String? {
        for (_, value) in contents.dict {
            if let str = value as? String {
                return str
            }
        }
        return nil
    }
    
    var sections: [any Section] {
        [
            MySection()
        ]
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "contents": contents.toJSONDict(),
            "sections": sections.map { $0.toDict() }
        ]
        if let author = author {
            dict["author"] = author
        }
        return dict
    }
    
    func toJSON() throws -> String {
        let dict = toDict()
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func generatePPTX(outputPath: String) async throws {
        let json = try toJSON()
        _ = try await PresentationRunner.generatePPTX(presentation: self, outputDir: "Outputs")
    }
}
```

### 3. 定义章节

```swift
struct MySection: Section {
    let title = "我的章节"
    let contents: SlideContent = SlideContent([
        "slides": [
            MySlide(),
            AnotherSlide()
        ] as [any Sendable]
    ])
    
    var slides: [any Slide] {
        contents.asSlideArray
    }
    
    func toDict() -> [String: Any] {
        [
            "title": title,
            "contents": contents.toJSONDict(),
            "slides": slides.map { $0.toDict() }
        ]
    }
}
```

### 4. 定义幻灯片

```swift
struct MySlide: Slide, ContentStyle {
    let title = "我的幻灯片"
    let contents: SlideContent = SlideContent([
        "items": [
            "第一项内容",
            "第二项内容",
            "第三项内容"
        ] as [any Sendable]
    ])
}

struct AnotherSlide: Slide, TextStyle {
    let title = "另一张幻灯片"
    let contents: SlideContent = SlideContent([
        "content": "这是一段文本内容"
    ])
}
```

### 5. 生成演示文稿

```swift
@main
struct MyPresentationApp {
    static func main() async {
        let presentation = MyPresentation()
        
        do {
            try await PresentationRunner.generate(presentation)
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
```

## API 参考

### PresentationRunner.generate()

```swift
public static func generate(
    _ presentation: any Presentation,
    outputDir: String = "Outputs",
    saveJSON: Bool = false
) async throws
```

**参数说明：**

- `presentation`: 符合 `Presentation` 协议的演示文稿对象
- `outputDir`: 输出目录，默认为 "Outputs"
- `saveJSON`: 是否保存 JSON 文件，默认为 `false`（仅用于调试）

**输出：**

- 自动生成 PPTX 文件到指定目录
- 如果 `saveJSON` 为 `true`，同时保存 JSON 文件
- 在控制台打印演示文稿结构和生成进度

## 完整示例

```swift
import Foundation
import SwiftSlides
import Runner

@main
struct CoursePresentation {
    static func main() async {
        let presentation = CoursePresentation.createPresentation()
        
        do {
            try await PresentationRunner.generate(presentation, saveJSON: true)
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    static func createPresentation() -> any Presentation {
        struct CourseSection: Section {
            let title = "课程概述"
            let contents: SlideContent = SlideContent([
                "slides": [
                    TitleSlide(),
                    ContentSlide()
                ] as [any Sendable]
            ])
            
            var slides: [any Slide] {
                contents.asSlideArray
            }
            
            func toDict() -> [String: Any] {
                [
                    "title": title,
                    "contents": contents.toJSONDict(),
                    "slides": slides.map { $0.toDict() }
                ]
            }
        }
        
        struct TitleSlide: Slide, CoverStyle {
            let title = "课程标题"
            let contents: SlideContent = SlideContent([
                "subtitle": "副标题",
                "author": "讲师姓名"
            ])
        }
        
        struct ContentSlide: Slide, ContentStyle {
            let title = "课程内容"
            let contents: SlideContent = SlideContent([
                "items": [
                    "第一点：课程目标",
                    "第二点：主要内容",
                    "第三点：实践环节"
                ] as [any Sendable]
            ])
        }
        
        struct CoursePresentation: Presentation {
            let title = "培训课程"
            let contents: SlideContent = SlideContent([
                "author": "培训中心",
                "date": "2024"
            ])
            
            var author: String? {
                for (_, value) in contents.dict {
                    if let str = value as? String {
                        return str
                    }
                }
                return nil
            }
            
            var sections: [any Section] {
                [
                    CourseSection()
                ]
            }
            
            func toDict() -> [String: Any] {
                var dict: [String: Any] = [
                    "title": title,
                    "contents": contents.toJSONDict(),
                    "sections": sections.map { $0.toDict() }
                ]
                if let author = author {
                    dict["author"] = author
                }
                return dict
            }
            
            func toJSON() throws -> String {
                let dict = toDict()
                let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
                return String(data: data, encoding: .utf8) ?? ""
            }
            
            func generatePPTX(outputPath: String) async throws {
                let json = try toJSON()
                _ = try await PresentationRunner.generatePPTX(presentation: self, outputDir: "Outputs")
            }
        }
        
        return CoursePresentation()
    }
}
```

## 调试技巧

### 保存 JSON 文件

如果需要调试数据结构，可以设置 `saveJSON: true`：

```swift
try await PresentationRunner.generate(presentation, saveJSON: true)
```

生成的 JSON 文件可以用于：
- 验证数据结构是否正确
- 排查 PPTX 生成问题
- 作为数据处理的证据

### 查看演示文稿结构

`PresentationRunner.generate()` 会自动打印演示文稿的树形结构：

```
========================================
SwiftSlides - 我的演示文稿
========================================

📊 Presentation: 我的演示文稿
👤 Author: 作者姓名
📁 Sections: 1

📂 我的章节
  └─📄 我的幻灯片
  └─📄 另一张幻灯片

📄 Total slides: 2

🔄 Generating PPTX...
✅ PPTX saved: Outputs/我的演示文稿.pptx
```

## 注意事项

1. **协议一致性**：确保你的结构符合 `Presentation`、`Section` 和 `Slide` 协议
2. **内容类型**：使用 `SlideContent` 而不是旧的 `SlideContent` 类型
3. **字典键**：协议会自动从字典中提取数据，无需硬编码键名
4. **多语言支持**：字典键可以使用任何语言（中文、英文等）

## 相关文档

- [设计需求文档](DESIGN_REQUIREMENTS.md)
- [代码审查文档](CODE_REVIEW.md)
- [修改计划文档](MODIFICATION_PLAN.md)
