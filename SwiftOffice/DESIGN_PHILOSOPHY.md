# SwiftOffice 设计哲学与需求分析

## 一、问题域：我们到底在解决什么问题？

### 1.1 PowerPoint 的痛点

**场景 1：写一份 100 页的年度报告**
- 第 50 页发现第 3 页的数据错了
- 需要手动修改 47 页的图表数据
- 格式不统一，有的页面标题是 24 号字，有的是 22 号
- 老板要求把所有蓝色改成绿色
- 需要 3 天时间调整格式

**场景 2：为 10 个部门做季度汇报**
- 每个部门的 PPT 结构相同，只是数据不同
- 在 PowerPoint 里复制粘贴 10 次
- 某个部门的数据更新后，需要重新复制粘贴
- 容易遗漏，容易出错

**场景 3：团队协作**
- 两个人同时编辑一个 PPTX 文件
- 合并时冲突无法解决
- Git 里看到的是一个二进制 blob，不知道改了什么
- 无法做 code review

### 1.2 现有"代码生成 PPT"方案的痛点

**方案 A：Python + python-pptx**
- 需要学习新的语言
- 类型不安全，运行时才发现错误
- API 设计偏向命令式，不够声明式

**方案 B：JavaScript + PptxGenJS**
- 同样是动态类型
- 需要配置 Node.js 环境
- 代码和结构分离，不够直观

**方案 C：Markdown 转 PPT（如 Marp、Slidev）**
- 表达能力有限，只能做简单幻灯片
- 无法精确控制布局
- 复杂图表、动画无法实现

### 1.3 我们的目标用户

**主要用户**：
- 需要频繁制作结构化报告的知识工作者
- 数据分析师、咨询顾问、项目经理
- 有编程基础或愿意学习基础编程的业务人员
- 需要版本控制和团队协作的企业用户

**不是目标用户**：
- 偶尔做一次 PPT 的普通用户
- 完全不愿意接触代码的用户

---

## 二、核心设计哲学

### 2.1 "创作"而非"编程"

**关键洞察**：用户不是在"写程序"，而是在"用代码创作幻灯片"。

**对比**：

| 维度 | 编程 | 创作 |
|------|------|------|
| 目标 | 解决计算问题 | 表达内容和思想 |
| 关注点 | 算法、性能、逻辑 | 结构、样式、内容 |
| 迭代方式 | 调试、测试 | 预览、调整 |
| 成功标准 | 正确运行 | 美观、清晰、有说服力 |

**设计 implication**：
- 语法应该像写作一样自然
- 错误信息应该像写作指导，而不是编译器报错
- 反馈循环应该快速（改代码 → 看效果）
- 不需要理解计算机科学概念

### 2.2 "声明式"而非"命令式"

**命令式（Imperative）**：
```python
# Python-pptx 风格（命令式）
slide = prs.slides.add_slide(title_slide_layout)
title = slide.shapes.title
title.text = "医院管理总览"
subtitle = slide.placeholders[1]
subtitle.text = "2024年度报告"
# ... 还要设置字体、颜色、位置
```

**声明式（Declarative）**：
```swift
// SwiftOffice 风格（声明式）
struct 封面: 封面页, 蓝色主题 {
    let title = "医院管理总览"
    let subtitle = "2024年度报告"
}
// 字体、颜色、位置由 封面页 和 蓝色主题 协议提供默认实现
```

### 2.3 "数据与呈现分离"——无限扩展的核心

**关键洞察**：同样的数据可以用完全不同的方式呈现，Protocol 决定"怎么展示"，而不是"展示什么"。

**示例：同样的销售数据，任意呈现形式**

```swift
// 数据（内容）
let 销售数据 = [
    "年度销售额：1.2亿元",
    "同比增长率：25%",
    "目标完成率：110%",
]

// 初级用户：默认列表呈现
struct 关键指标页: Slide, 内容页 {
    let items = 销售数据
}

// 高级用户：流程图呈现
struct 关键指标页: Slide, Mermaid流程图, 超彩色主题 {
    let nodes = 销售数据
}

// 高级用户：柱状图呈现
struct 关键指标页: Slide, 柱状图, 商务风格 {
    let data = 销售数据
}

// 专家用户：自定义动画呈现
struct 关键指标页: Slide, 逐字动画, 电影级转场 {
    let sequence = 销售数据
}
```

**设计原则**：
- **数据是数据，呈现是呈现** - 完全分离
- **Protocol 是能力，不是限制** - 可以任意组合
- **没有固定版式** - 只有默认约定
- **初级用默认，高级用组合，专家自定义**

**为什么这样设计**：
- PowerPoint 的"版式"是固定的（标题幻灯片、标题和内容等）
- 但用户实际需要无限的可能性
- Protocol 组合让"版式"变成无限可扩展的能力集
- AI 可以根据内容自动推荐最佳呈现方式

### 2.4 "结构化"而非"自由绘制"

**PowerPoint 的问题**：
- 每个元素都可以随意拖拽
- 导致不一致、难以维护
- 像"在画布上画画"，而不是"按模板填空"

**SwiftOffice 的方式**：
- 强制使用 Protocol 定义的结构
- 但 Protocol 可以任意组合，创造无限可能
- 像"乐高积木"，标准件组合出无限创意

**不是限制，而是约束带来自由**：
- 用户不需要考虑"这个标题放哪里"
- 只需要考虑"这个标题写什么"和"用什么方式呈现"
- 样式可以一键全局更换

### 2.5 "组合"而非"继承"

**继承的问题**：
```swift
// 不好的设计
class 蓝色封面页: 封面页 { ... }
class 动画蓝色封面页: 蓝色封面页 { ... }
// 继承层次深，难以修改
```

**组合的优势**：
```swift
// 好的设计
struct 我的封面: Slide, 封面样式, 蓝色主题, 淡入动画 {
    // 组合多个协议的能力
}
// 可以随时增删协议，不影响其他代码
```

**Protocol-Oriented Programming（POP）**：
- Swift 的核心范式
- 协议定义能力，结构体组合能力
- 没有继承的耦合问题
- 完美匹配"声明式"设计和"数据与呈现分离"

### 2.6 "代码即文档"

**PowerPoint 的问题**：
- 文档是二进制格式，无法 diff
- 不知道改了什么，为什么改
- 无法做 code review

**SwiftOffice 的优势**：
- 纯文本代码，Git 友好
- 每次提交都有清晰的 diff
- 可以写注释说明设计意图
- 可以 code review 内容准确性

**更进一步**：
- 代码本身就是文档结构的描述
- 不需要额外的"文档说明文档结构"
- 自解释、自文档化

---

## 三、无限扩展的架构设计

### 3.1 三层分离架构

```
┌─────────────────────────────────────────┐
│  数据层（Data）                          │
│  - 纯数据，无呈现逻辑                     │
│  - 可以是字符串、数组、结构体              │
│  - 与呈现完全无关                         │
├─────────────────────────────────────────┤
│  结构层（Structure）                      │
│  - Presentation / Section / Slide        │
│  - 定义文档的层级结构                     │
│  - 不定义具体呈现方式                     │
├─────────────────────────────────────────┤
│  呈现层（Presentation/Protocol）          │
│  - Protocol 组合决定呈现方式              │
│  - 无限可扩展的能力集                     │
│  - 可以是简单样式或复杂图表               │
└─────────────────────────────────────────┘
```

### 3.2 Protocol 即能力

**基础 Protocol（SwiftSlides 提供）**：
```swift
// 基础结构
Slide          - 单页幻灯片
Section        - 章节
Presentation   - 演示文稿

// 基础样式
蓝色主题        - 蓝色配色方案
商务风格        - 商务字体和间距
渐变背景        - 渐变背景效果

// 基础动画
淡入动画        - 淡入效果
滑动动画        - 滑动效果
逐字动画        - 逐字显示
```

**高级 Protocol（SwiftSlides 提供）**：
```swift
// 图表
柱状图          - 柱状图呈现
折线图          - 折线图呈现
饼图            - 饼图呈现
Mermaid流程图   - 流程图（依赖 BeautifulMermaid）
组织架构图      - 组织结构图
甘特图          - 项目进度图

// 布局
两栏布局        - 左右两栏
三栏布局        - 三栏布局
网格布局        - 网格系统
全屏图片        - 全屏背景图
```

**自定义 Protocol（用户或第三方扩展）**：
```swift
// 用户自定义
电影级转场       - 复杂转场动画
3D效果          - 3D 变换效果
交互式图表      - 可交互图表
数据可视化      - 自定义可视化

// 第三方库
D3图表          - D3.js 风格图表
Three3D         - Three.js 3D 效果
Lottie动画      - Lottie 动画支持
```

### 3.3 组合示例

**初级组合**：
```swift
struct 封面: Slide, 封面页, 蓝色主题 {
    let title = "医院管理总览"
}
```

**中级组合**：
```swift
struct 数据页: Slide, 柱状图, 商务风格, 淡入动画 {
    let data = ["Q1": 100, "Q2": 150, "Q3": 200]
}
```

**高级组合**：
```swift
struct 复杂页: Slide, Mermaid流程图, 超彩色主题, 
              逐字动画, 电影级转场 {
    let flow = [
        "开始": ["需求分析"],
        "需求分析": ["设计", "开发"],
        "设计": ["评审"],
        "开发": ["测试"],
        "评审": ["开发"],
        "测试": ["上线"],
    ]
}
```

**专家级自定义**：
```swift
// 自定义 Protocol
protocol 数据驱动动画 {
    associatedtype Data
    var animationData: Data { get }
    func renderAnimation() -> Animation
}

// 使用自定义 Protocol
struct 自定义页: Slide, 数据驱动动画, 3D效果 {
    let animationData = [...]
    // 完全自定义的呈现逻辑
}
```

---

## 四、用户心智模型

### 4.1 用户如何理解这个系统？

**类比 1：Markdown 写作**
- Markdown：用纯文本写格式，编译成 HTML/PDF
- SwiftOffice：用 Swift 写结构，编译成 PPTX

**类比 2：乐高积木**
- 乐高：用标准积木块组合成复杂模型
- SwiftOffice：用标准 Protocol 组合成复杂演示文稿

**类比 3：CSS + HTML**
- HTML：定义结构（Slide 定义内容）
- CSS：定义样式（Protocol 定义外观）
- SwiftOffice：结构和样式都在 Swift 代码中，但完全分离

### 4.2 用户的学习路径

**第 1 天：复制粘贴**
- 找一个示例，改标题和内容
- 运行 `swift 文件名.swift`
- 看到 PPTX 生成，有成就感

**第 1 周：理解结构**
- 学习 Presentation → Section → Slide 的层级
- 尝试添加新的 Slide
- 理解 Protocol 的作用

**第 1 个月：熟练创作**
- 能独立设计复杂演示文稿结构
- 知道如何复用和组合
- 能自定义 Protocol 满足特殊需求

**第 3 个月：高级用户**
- 创建自己的 Protocol 库
- 团队协作，代码复用
- 用 AI 辅助生成内容

### 4.3 用户的创作流程

**Step 1：构思内容和结构**
- 在纸上画出演示文稿的内容大纲
- 不需要考虑具体呈现方式

**Step 2：定义数据**
```swift
let 销售数据 = [
    "年度销售额：1.2亿元",
    "同比增长率：25%",
    "目标完成率：110%",
]
```

**Step 3：选择呈现方式**
```swift
// 尝试不同呈现方式，看哪种效果最好
struct 数据页: Slide, 内容页 { ... }      // 列表
struct 数据页: Slide, 柱状图 { ... }      // 图表
struct 数据页: Slide, Mermaid流程图 { ... } // 流程图
```

**Step 4：组合样式**
```swift
struct 数据页: Slide, 柱状图, 蓝色主题, 淡入动画 {
    // 数据 + 呈现方式 + 样式 + 动画
}
```

**Step 5：生成和迭代**
- 运行生成 PPTX
- 查看效果
- 快速修改代码，重新生成

---

## 五、设计决策的理由

### 5.1 为什么用 Swift，而不是 Python/JavaScript？

| 维度 | Swift | Python/JS |
|------|-------|-----------|
| 类型安全 | 编译期检查，减少运行时错误 | 运行时才发现错误 |
| 现代语言特性 | Protocol、泛型、Result Builder | 相对传统 |
| 性能 | 编译成机器码，运行快 | 解释执行，较慢 |
| 生态系统 | 苹果生态，适合 Mac 用户 | 跨平台，但需配置环境 |
| 声明式支持 | Result Builder 完美支持 DSL | 需要额外库支持 |
| AI 友好度 | 结构化强，AI 生成准确 | 动态类型，AI 容易出错 |
| Protocol 系统 | 强大的 POP 支持 | 相对弱 |

**关键理由**：
- 类型安全对于"创作"很重要，错误应该在编译期发现
- Swift 的 Protocol 和 POP 范式完美匹配"数据与呈现分离"的设计
- Result Builder 让 DSL 语法非常自然

### 5.2 为什么用脚本模式，而不是 Swift Package？

**Swift Package 的问题**：
- 需要理解 Package.swift
- 需要理解 target、dependency 等概念
- 需要 `swift run --target xxx`
- 门槛太高，不够直接

**脚本模式的优势**：
- `swift 文件名.swift` 直接运行
- 不需要额外配置
- 符合"创作"的心智模型（像运行 Python 脚本）

**妥协**：
- 脚本模式不支持复杂的依赖管理
- 但我们可以提供单文件库，用户只需要 `import SwiftSlides`

### 5.3 为什么 Protocol 代表能力，而不是固定版式？

**固定版式的问题**：
```swift
// 不好的设计 - 固定版式
enum SlideType { 
    case 标题幻灯片
    case 标题和内容
    case 两栏内容
    // 用户被限制在这几种版式
}
```

**Protocol 能力的优势**：
```swift
// 好的设计 - 无限组合
struct 我的幻灯片: Slide, 标题样式, 左侧图片, 右侧文字, 
                  蓝色主题, 淡入动画, Mermaid流程图 {
    // 任意组合，无限可能
}
```

**关键洞察**：
- PowerPoint 的版式是固定的，用户被限制
- Protocol 组合是无限的，用户可以自由创造
- 同样的数据可以用完全不同的方式呈现
- 没有"不适合的场景"，只有"还没实现的 Protocol"

### 5.4 为什么需要两种 Presentation 结构（WithSections / WithSlides）？

**用户需求多样性**：

**场景 A：大型报告**
- 需要章节划分
- 需要章节导航
- 不同章节不同页眉
- → 需要 Section 层级

**场景 B：快速演示**
- 10 页以内
- 不需要章节
- 线性浏览
- → 不需要 Section，直接 Slide 列表即可

**不强制统一**：
- 让用户根据需求选择
- 两种结构都是合法的
- 通过不同 Protocol 约束

### 5.5 为什么顶层要有执行代码？

**理想情况**：用户只定义 struct，不需要执行代码。

**现实限制**：
- Swift 脚本需要入口点
- 不能自动知道要实例化哪个 struct
- 一个文件可能定义多个 struct

**权衡**：
- 两行执行代码是可以接受的代价
- 换来的是清晰和灵活
- 用户可以选择实例化哪个 struct
- 用户可以在实例化前做条件判断、数据准备

**未来可能**：
- Swift 宏可能可以自动生成执行代码
- 但当前版本保持简单明确

---

## 六、与 AI 的协作

### 6.1 AI 如何帮助用户？

**场景 1：从零开始**
- 用户："帮我做一个关于医院管理的 PPT"
- AI：生成完整的 Swift 代码框架
- 用户：修改细节，运行生成

**场景 2：内容填充**
- 用户："第一章写医院历史，包含古代和现代两部分"
- AI：生成 `古代医院` 和 `现代医院` 两个 Slide 的定义
- 用户：审核内容，调整细节

**场景 3：选择呈现方式**
- 用户："这组数据用什么图表展示比较好？"
- AI：推荐 `柱状图` 或 `折线图` Protocol
- 用户：确认，AI 生成代码

**场景 4：样式调整**
- 用户："把主题改成绿色"
- AI：把 `蓝色主题` 改成 `绿色主题`
- 用户：重新生成，查看效果

**场景 5：复杂可视化**
- 用户："这个流程很复杂，怎么展示？"
- AI：推荐 `Mermaid流程图` Protocol
- AI：生成流程图代码
- 用户：调整节点和连线

### 6.2 为什么 Swift 代码对 AI 更友好？

**类型安全**：
- AI 生成的代码如果类型不匹配，编译失败
- 立即反馈，AI 可以自我修正
- 动态语言可能在运行时才发现错误

**结构化**：
- Presentation → Section → Slide 的层级清晰
- AI 容易理解上下文关系
- 不像自然语言那样模糊

**Protocol 约束**：
- AI 知道哪些 Protocol 可以组合
- 不会生成无意义的组合
- 有明确的"语法规则"

**数据与呈现分离**：
- AI 可以专注于生成数据
- 呈现方式可以单独推荐
- 分离关注点，降低复杂度

### 6.3 AI 生成代码的示例

**用户输入**：
```
帮我做一个销售汇报 PPT，包含：
1. 封面：2024年销售总结
2. 第一章：年度概览，包含销售额、增长率、目标完成情况
   - 这些数据用柱状图展示
3. 第二章：区域分析，华东、华北、华南三个区域
   - 用流程图展示区域间协作
4. 结束页：谢谢
主题用蓝色，有淡入动画
```

**AI 生成**：
```swift
import SwiftSlides

// 数据定义
let 销售数据 = [
    ("年度销售额", "1.2亿元"),
    ("同比增长率", "25%"),
    ("目标完成率", "110%"),
]

let 区域数据 = [
    "华东": 5000,
    "华北": 4000,
    "华南": 3000,
]

// Presentation 定义
struct 销售汇报: PresentationWithSections, 蓝色主题 {
    let title = "2024年销售总结"
    
    let sections: [Section] = [
        封面章节(),
        年度概览章节(),
        区域分析章节(),
        结束章节(),
    ]
}

// 章节定义
struct 封面章节: Section {
    let title = "封面"
    let slides: [Slide] = [
        封面页(title: "2024年销售总结", subtitle: "年度业绩汇报")
    ]
}

struct 年度概览章节: Section {
    let title = "年度概览"
    let slides: [Slide] = [
        章节首页(title: "年度概览", number: 1),
        关键指标页(),
    ]
}

// Slide 定义 - 数据与呈现分离
struct 关键指标页: Slide, 柱状图, 蓝色主题, 淡入动画 {
    let data = 销售数据
}

struct 区域分析章节: Section {
    let title = "区域分析"
    let slides: [Slide] = [
        章节首页(title: "区域分析", number: 2),
        区域协作页(),
    ]
}

struct 区域协作页: Slide, Mermaid流程图, 蓝色主题, 淡入动画 {
    let flow = [
        "华东": ["华北", "华南"],
        "华北": ["华南"],
        "华南": [],
    ]
}

struct 结束章节: Section {
    let title = "结束"
    let slides: [Slide] = [
        结束页(title: "谢谢", subtitle: "Questions?")
    ]
}

// 执行
let p = 销售汇报()
try await p.generatePPTX()
```

---

## 七、边界和限制

### 7.1 实际上没有不适合的场景

**之前的误解**：认为复杂图形设计不适合。

**正确的理解**：只要实现了对应的 Protocol，任何呈现都是可能的。

```swift
// 复杂图形设计 - 完全可能
struct 艺术页: Slide, 自定义矢量图, 3D变换, 粒子动画 {
    let vectorData = [...]
    let transform3D = [...]
}

// 精细动画控制 - 完全可能
struct 动画页: Slide, 时间轴动画, 关键帧控制 {
    let timeline = [
        (0.0, "淡入"),
        (0.5, "移动"),
        (1.0, "缩放"),
    ]
}
```

**唯一的限制**：
- 我们是否实现了对应的 Protocol
- 是否有足够的想象力设计 Protocol

### 7.2 技术实现细节对用户透明

**用户不需要关心**：
- 是否依赖 Node.js
- 如何生成 PPTX 文件
- 如何渲染图表
- 如何处理字体

**用户只需要关心**：
- 定义数据
- 选择 Protocol 组合
- 运行生成命令

**技术细节自动处理**：
- SwiftSlides 内部处理所有技术细节
- 自动检测依赖，自动安装
- 自动选择最佳渲染方式
- 自动处理错误和重试

### 7.3 学习曲线

**需要学习的内容**：
- Swift 基础语法（如果不会的话）
- Presentation/Section/Slide 的层级关系
- 常用 Protocol 的作用
- 数据与呈现分离的思维模式

**降低门槛的措施**：
- 提供大量示例
- AI 辅助生成
- 文档详细说明
- 错误信息友好
- 渐进式学习路径

---

## 八、成功标准

### 8.1 用户体验标准

- [ ] 新用户可以在 5 分钟内生成第一个 PPTX
- [ ] 不需要理解 Swift 高级特性（泛型、关联类型等）
- [ ] 修改代码后，10 秒内可以看到新的 PPTX
- [ ] 错误信息告诉用户"怎么改"，而不是"什么错了"
- [ ] 用户可以在 30 分钟内学会使用新的 Protocol

### 8.2 功能标准

- [ ] 支持无限扩展的 Protocol 系统
- [ ] 支持数据与呈现完全分离
- [ ] 支持从简单列表到复杂图表的任意呈现
- [ ] 支持多文件组织和复用
- [ ] 生成 PPTX 可以在 PowerPoint/Keynote 中正常打开
- [ ] 支持 BeautifulMermaid 等外部图表库

### 8.3 代码质量标准

- [ ] 用户代码比 PowerPoint 操作更快（对于复杂文档）
- [ ] 代码结构清晰，易于维护
- [ ] Git diff 可以清晰看到修改内容
- [ ] AI 可以根据自然语言描述生成合理的 Swift 代码
- [ ] 专家用户可以自定义任意复杂的 Protocol

---

## 九、总结

### 9.1 核心设计原则

1. **创作而非编程** - 降低门槛，专注于内容
2. **声明式而非命令式** - 描述想要什么，而不是怎么做
3. **数据与呈现分离** - 无限扩展的核心，同样的数据任意呈现
4. **Protocol 即能力** - 不是限制，是无限组合的能力集
5. **组合而非继承** - Protocol-Oriented Programming
6. **代码即文档** - Git 友好，可版本控制

### 9.2 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 语言 | Swift | 类型安全、现代特性、POP 范式、AI 友好 |
| 执行模式 | 脚本模式 | 简单直接，无需配置 |
| 功能表示 | Protocol 能力 | 无限组合，无限制 |
| 架构 | 数据-结构-呈现三层分离 | 无限扩展，分离关注点 |
| 结构 | 两种 Presentation | 满足不同复杂度需求 |
| AI 协作 | 原生支持 | 结构化代码，数据与呈现分离 |

### 9.3 愿景

**短期**：让有编程基础的用户高效创建结构化 PPTX

**中期**：成为数据分析师、咨询顾问的标准工具

**长期**：
- 重新定义"演示文稿创作"，从 GUI 转向代码
- 开启 AI 辅助创作的新时代
- 实现"任何内容都可以用任意方式呈现"的无限可能
- 成为 Office 文档生成的标准基础设施

---

## 十、附录：Protocol 设计示例

### 10.1 基础 Protocol

```swift
// 结构协议
protocol Slide {
    var id: UUID { get }
}

protocol Section {
    var title: String { get }
    var slides: [Slide] { get }
}

protocol Presentation {
    var title: String { get }
}

// 样式协议
protocol 蓝色主题 {
    var primaryColor: String { "#0066CC" }
    var secondaryColor: String { "#E6F2FF" }
}

protocol 商务风格 {
    var fontFamily: String { "微软雅黑" }
    var fontSize: CGFloat { 18 }
}

// 动画协议
protocol 淡入动画 {
    var animationDuration: TimeInterval { 0.5 }
    var animationDelay: TimeInterval { 0 }
}
```

### 10.2 高级 Protocol

```swift
// 图表协议
protocol 柱状图 {
    associatedtype Data
    var data: Data { get }
    var xAxisLabel: String { get }
    var yAxisLabel: String { get }
}

protocol Mermaid流程图 {
    var flow: [String: [String]] { get }
    var direction: MermaidDirection { .从上到下 }
}

// 布局协议
protocol 两栏布局 {
    var leftWidth: CGFloat { 0.5 }
    var rightWidth: CGFloat { 0.5 }
}

protocol 全屏图片 {
    var imageURL: URL { get }
    var overlayOpacity: CGFloat { 0.3 }
}
```

### 10.3 自定义 Protocol 示例

```swift
// 用户自定义 Protocol
protocol 数据驱动动画 {
    associatedtype Data
    var animationData: Data { get }
    func renderAnimation() -> Animation
}

protocol 3D效果 {
    var rotationX: CGFloat { get }
    var rotationY: CGFloat { get }
    var rotationZ: CGFloat { get }
    var perspective: CGFloat { get }
}

protocol 粒子系统 {
    var particleCount: Int { get }
    var particleSize: CGFloat { get }
    var particleColor: String { get }
    var particleBehavior: ParticleBehavior { get }
}

// 使用自定义 Protocol
struct 自定义页: Slide, 数据驱动动画, 3D效果, 粒子系统 {
    // 实现自定义呈现
}
```

---

*文档版本：2.0*
*最后更新：2026-03-03*
*核心更新：数据与呈现分离的无限扩展架构*
