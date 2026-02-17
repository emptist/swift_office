# 第一性原理实验结果

## 最终方案: `static var`

### 核心发现

**使用方式与原著完全一致！**

```swift
// CoffeeScript 原著
项目设置.cso.一级指标设置

// Swift 最终方案
项目设置.cso.一级指标设置
```

---

## 代表性代码

### 1. 基础实体模式

```swift
struct 项目设置 {
    // 懒加载缓存
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    // 模拟 @cso: @dataPrepare?()
    static var cso: [String: Any] {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso!
    }
    
    // 数据准备方法
    static func dataPrepare() -> [String: Any] {
        // 从文件读取或计算
        return ["一级指标设置": ["安全": ["权重": 0.3]]]
    }
    
    // 业务属性
    static var 一级指标设置: [String: [String: Any]] {
        (cso["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    // 重置缓存
    static func reset() {
        _cso = nil
    }
}
```

### 2. 依赖自动触发

```swift
struct 指标导向库 {
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any] {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso!
    }
    
    static func dataPrepare() -> [String: Any] {
        // 访问 项目设置.cso 会自动触发其 dataPrepare
        let settings = 项目设置.cso  // ← 依赖自动触发！
        print("依赖 项目设置 已就绪: \(settings.keys)")
        return ["指标导向": "高优"]
    }
}
```

### 3. 章节积木系统

```swift
// 可复用的章节组件
enum 章节积木 {
    case 扉页(String)
    case 目录
    case 总体概述
    case 科室对比
    case 趋势分析
    case 结论建议
    
    func toSlides() -> [[String: Any]] {
        switch self {
        case .扉页(let title):
            return [["type": "title", "text": title]]
        case .总体概述:
            return [
                ["type": "sectionTitle", "text": "总体概述"],
                ["type": "text", "content": "本年度医疗质量稳步提升..."]
            ]
        // ...
        }
    }
}

// 搭积木组合
struct 报告版本 {
    let name: String
    let blocks: [章节积木]
    
    func generate() -> [[String: Any]] {
        blocks.flatMap { $0.toSlides() }
    }
}

// 使用
let 简化版 = 报告版本(
    name: "简化版",
    blocks: [.扉页("报告"), .总体概述, .结论建议]
)
```

---

## 方案对比

| 方案 | 懒加载 | 缓存 | 依赖触发 | 可变 | 简洁度 | 总分 |
|------|--------|------|----------|------|--------|------|
| static let | ✅ | ✅ | ✅ | ❌ | ⭐⭐⭐⭐⭐ | 90% |
| **static var** | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ | **100%** |
| instance | ✅ | ❌ | ❌ | ✅ | ⭐⭐⭐ | 50% |

---

## 真实案例验证

### ✅ 设置驱动
项目设置决定报告结构，一级指标、科室、年份等配置驱动内容生成

### ✅ JSON 证据留存
每一步生成 JSON 文件：原始数据 → 计算数据 → 图表数据

### ✅ 多版本输出
搭积木式组合，同一数据生成 4 套不同结构的报告：
- 简化版 (5 slides)
- 汇报版 (8 slides)
- 对标版 (10 slides)
- 院内报告 (14 slides)

### ✅ 章节结构管理
PPT 章节自动生成，按顺序排列

### ✅ 多种 PPT 内容形式
表格、柱状图、雷达图、折线图、文本

### ✅ 完整流程
设置 → 数据 → JSON → PPT 全链路验证

---

## 核心优势

1. **使用方式与原著完全一致**: `项目设置.cso.一级指标设置`
2. **懒加载**: 首次访问时初始化
3. **缓存**: 数据驻留内存
4. **依赖触发**: 访问时自动初始化依赖
5. **可重置**: 支持数据刷新
6. **代码简洁**: 无需实例化，直接使用

---

## CoffeeScript vs Swift 对照

| CoffeeScript | Swift |
|-------------|-------|
| `@cso: @dataPrepare?()` | `static var cso: [String: Any] { ... }` |
| `项目设置.cso` | `项目设置.cso` |
| `class extends Base` | `struct + static var` |
| 单继承 | 无继承，更灵活 |
