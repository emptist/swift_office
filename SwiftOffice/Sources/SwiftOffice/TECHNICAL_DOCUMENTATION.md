# SwiftOffice 技术文档

## CoffeeScript 到 Swift 的翻译经验总结

### 目录

1. [背景与目标](#背景与目标)
2. [原著架构分析](#原著架构分析)
3. [翻译策略演进](#翻译策略演进)
4. [Protocol + Struct 方案详解](#protocol--struct-方案详解)
5. [关键发现](#关键发现)
6. [代码对比示例](#代码对比示例)
7. [最佳实践](#最佳实践)
8. [局限性](#局限性)

---

## 背景与目标

### 原著项目

原著是一个用 CoffeeScript 编写的医院数据分析报告生成系统，具有以下特点：

- **200+ 业务类**：覆盖数据采集、处理、分析、报告生成全流程
- **深层继承链**：最长达 6 层继承
- **Class-Side 编程**：大量使用静态属性和方法
- **懒加载机制**：`@cso: @dataPrepare?()` 模式
- **统一命名系统**：中文命名贯穿 PPT 章节、JSON 文件、类名、Excel 字段

### 翻译目标

1. 保持业务逻辑等价
2. 利用 Swift 6.2 新特性
3. 提高代码可维护性
4. 支持 Swift-Node.js 混合架构

---

## 原著架构分析

### 五大乾坤

原著作者巧妙利用 CoffeeScript/JavaScript 语言特性，实现了五个设计乾坤：

#### 1. Class-Side 编程

```coffeescript
class 项目设置
  @cso: @dataPrepare?()  # 静态属性，懒加载
  
  @dataPrepare: ->
    @sdb = @setDB({thisClass: this})
    @requestJSON()
```

**本质**：用 class-side 模拟 struct 的无状态数据承载

#### 2. Class 作为一等公民

```coffeescript
class 项目设置
  @dataPrepare: ->
    @sdb = @setDB({thisClass: this})  # this 指向类本身
```

**本质**：类既是类型定义，也是单例实例

#### 3. 隐式依赖图

```coffeescript
class 指标导向库 extends 指标名称和体系
  @dataPrepare: ->
    for key, obj of 项目设置.cso.三级指标设置  # 访问时自动初始化
      @sdb.get(@name).set(key, obj.指标导向)
```

**本质**：通过 `@cso` 访问自动触发依赖类的初始化

#### 4. 元类编程

```coffeescript
class AnyCaseSingleton extends StormDBSingleton
  @dbfilenm: (classname) -> 
    path.join __dirname, "#{classname}.json"
```

**本质**：类方法操作类本身，实现元编程

#### 5. 统一命名系统

```
PPT章节名称 ←→ JSON文件名 ←→ 类名 ←→ Excel表字段名 ←→ 指标名
```

**本质**：命名即文档，减少映射配置

### 继承链分析

```
StormDBSingleton (0层)
      ↓
AnyCaseSingleton (1层)
      ↓
CaseSingleton (2层)
      ↓
NormalCaseSingleton (3层)
      ↓
指标名称和体系 (4层)
      ↓
三级指标对应二级指标基础 (5层)
      ↓
三级科级指标对应二级指标 (6层)
```

**问题**：继承链过长，中间类只为传递能力

---

## 翻译策略演进

### 第一阶段：仿写 (v1-class-side)

**策略**：直接翻译 class-side 为 static 属性

```swift
class 项目设置 {
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
    
    static func dataPrepare() -> [String: Any]? {
        // ...
    }
}
```

**问题**：
1. Swift 并发安全要求 `nonisolated(unsafe)`
2. 继承链中 override 静态方法困难
3. 无法实现原著的隐式依赖图

### 第二阶段：重写 (v2-pop)

**策略**：Protocol-Oriented Programming

```swift
protocol JSONSimpleProtocol {
    var dirname: String? { get }
    var basename: String { get }
    func readFromJSON() -> [String: Any]?
}

struct 项目设置: JSONSimpleProtocol {
    let dirname: String?
    let basename: String = "项目设置"
}
```

**问题**：
1. Protocol 继承层次不够清晰
2. 缺少懒加载机制
3. 业务属性实现分散

### 第三阶段：完善 (v3-refined)

**策略**：混合优化

```swift
actor 项目设置 {
    let dirname: String?
    let basename: String = "项目设置"
    
    private var _cachedData: [String: Any]?
    
    var cso: [String: Any]? {
        get async {
            if _cachedData == nil {
                _cachedData = await readFromJSON()
            }
            return _cachedData
        }
    }
}
```

**问题**：
1. Actor 增加了异步复杂度
2. 与 Node.js 桥接不兼容

### 第四阶段：Protocol + Struct (v4-protocol-struct) ✅

**策略**：能力型 Protocol + Struct 组合

```swift
// 能力型 Protocol
protocol DatabaseCapable {
    var dirname: String? { get }
    var basename: String { get }
    func setDB() -> [String: Any]
    func requestJSON() -> [String: Any]?
}

protocol CacheCapable {
    var cachedData: [String: Any]? { get set }
    mutating func clearCache()
}

// 业务实体：组合多种能力
struct 项目设置V4Full: DatabaseCapable, CacheCapable, YearCapable, 
                        UnitCapable, AliasCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "项目设置"
    var cachedData: [String: Any]?
    
    // computed var 模拟 @cso
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
}
```

**优势**：
1. 扁平化，无深层继承
2. 能力自由组合
3. 特化通过属性实现
4. 类型安全

---

## Protocol + Struct 方案详解

### 能力型 Protocol 设计

将原著的继承能力拆分为独立的 Protocol：

```swift
// 数据库能力
protocol DatabaseCapable {
    var dirname: String? { get }
    var basename: String { get }
    func setDB() -> [String: Any]
    func requestJSON() -> [String: Any]?
}

// 缓存能力
protocol CacheCapable {
    var cachedData: [String: Any]? { get set }
    mutating func clearCache()
}

// 年份处理能力
protocol YearCapable {
    func years() -> [String]
}

// 单位处理能力
protocol UnitCapable {
    func localUnits() -> [String]
    func focusUnits() -> [String]
}

// 别名处理能力
protocol AliasCapable {
    func adjustedName(_ name: String) -> String
}

// 指标处理能力
protocol IndicatorCapable {
    func 二级指标表(full: Bool) -> [String]
    func shortIndicatorName(_ name: String) -> String
}

// 日志能力
protocol LogCapable {
    func log(_ message: String)
    func error(_ message: String)
}

// 图表生成能力
protocol ChartGeneratable {
    func generateChartData() -> [String: Any]
}

// 排序能力
protocol Sortable {
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]]
}

// PPT 章节能力
protocol PPTSectionCapable {
    func slides(pres: inout [[String: Any]], sectionTitle: String)
    func sectionData() -> [String: Any]?
}

// Excel 写入能力
protocol ExcelWritable {
    func write2Excel(_ opts: [String: Any])
    func saveExcel(opts: [String: Any])
}
```

### 默认实现

```swift
extension CacheCapable {
    mutating func clearCache() {
        cachedData = nil
    }
}

extension YearCapable {
    func years() -> [String] {
        ["Y2021", "Y2020", "Y2019"]
    }
}

extension AliasCapable {
    func adjustedName(_ name: String) -> String {
        name.replacingOccurrences(
            of: "[*↑↓()（、）/▲\\s]", 
            with: "", 
            options: .regularExpression
        )
    }
}
```

### 业务实体组合

```swift
// 组合 6 种能力
struct CaseSingletonV4: DatabaseCapable, CacheCapable, YearCapable, 
                        UnitCapable, AliasCapable, IndicatorCapable {
    let dirname: String?
    let basename: String
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
}

// 项目设置：业务属性扩展
struct 项目设置V4Full: DatabaseCapable, CacheCapable, YearCapable, 
                       UnitCapable, AliasCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "项目设置"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    // 模拟 @cso
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 业务属性
    var 一级指标设置: [String: [String: Any]] {
        (cso?["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    var 二级指标设置: [String: [String: Any]] {
        (cso?["二级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
}
```

### 特化实现

```swift
// 原值排序报告
struct 原值排序报告V4Full: PPTSectionCapable, DatabaseCapable, 
                          CacheCapable, ChartGeneratable, Sortable {
    let dirname: String?
    let basename: String
    let showValue: Bool = true  // 默认显示值
    var cachedData: [String: Any]?
    
    // ...
}

// 内部原值排序报告：特化 showValue = false
struct 内部原值排序报告V4Full: PPTSectionCapable, DatabaseCapable, 
                              CacheCapable, ChartGeneratable, Sortable {
    let dirname: String?
    let basename: String
    let showValue: Bool = false  // 特化：不显示值
    var cachedData: [String: Any]?
    
    // ...
}
```

---

## 关键发现

### 1. Computed Var 的编译器优化

**发现**：Swift 编译器对 computed var 有 lazy init 优化

```swift
struct 项目设置V4 {
    var cso: [String: Any]? {
        cachedData ?? requestJSON()  // 编译器优化，类似懒加载
    }
}
```

**意义**：更接近原著 `@cso: @dataPrepare?()` 的懒加载效果

### 2. Struct Instance-Side 模拟 Class-Side

**原著 CoffeeScript**：
```coffeescript
class 项目设置
  @cso: @dataPrepare?()  # class-side
```

**Swift Struct**：
```swift
struct 项目设置V4 {
    var cso: [String: Any]? { ... }  // instance-side
}

// 使用方式类似
let 项目设置 = 项目设置V4()  // 简洁，类似 class-side
let data = 项目设置.cso
```

**意义**：Struct 的默认 init 让 instance-side 使用起来像 class-side

### 3. 多重 Protocol 组合优势

**原著 CoffeeScript 单继承**：
```coffeescript
class 多科雷达图报告 extends 雷达图报告
  # 只能继承一个父类
```

**Swift 多重 Protocol**：
```swift
struct 多科雷达图报告V4Full: PPTSectionCapable, DatabaseCapable, 
                              CacheCapable, ChartGeneratable, AliasCapable {
    // 可以组合 5 种能力
    func compareIndicators(_ ind1: String, _ ind2: String) -> [String: Any] {
        // 额外方法
    }
}
```

**意义**：不受单继承限制，可以自由组合能力

### 4. 特化通过属性实现

**原著 CoffeeScript**：
```coffeescript
class 内部原值排序报告 extends 原值排序报告
  @showValue: false  # override 静态属性
```

**Swift Struct**：
```swift
struct 内部原值排序报告V4Full: ... {
    let showValue: Bool = false  // 属性默认值
}
```

**意义**：不需要子类，通过属性默认值实现特化

---

## 代码对比示例

### 示例 1：深层继承链

**原著 CoffeeScript (6 层)**：
```coffeescript
class StormDBSingleton
class AnyCaseSingleton extends StormDBSingleton
class CaseSingleton extends AnyCaseSingleton
class NormalCaseSingleton extends CaseSingleton
class 指标名称和体系 extends NormalCaseSingleton
class 三级指标对应二级指标基础 extends 指标名称和体系
class 三级科级指标对应二级指标 extends 三级指标对应二级指标基础
```

**Swift Protocol + Struct (0 层)**：
```swift
struct 三级科级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable {
    let scope: String = "科级"  // 特化
}
```

### 示例 2：PPT 章节多态

**原著 CoffeeScript**：
```coffeescript
class ChartPPTSection
class 排序报告 extends ChartPPTSection
class 雷达图报告 extends ChartPPTSection

# 统一处理
sections = [new 排序报告(), new 雷达图报告()]
for section in sections
  section.slides(pres)
```

**Swift Protocol**：
```swift
let sections: [any PPTSectionCapable] = [
    排序报告V4Full(basename: "排序"),
    雷达图报告V4Full(basename: "雷达图")
]

for section in sections {
    section.slides(pres: &pres, sectionTitle: "测试")
}
```

### 示例 3：能力组合

**原著 CoffeeScript**：
```coffeescript
# 无法组合，只能继承
class 多科雷达图报告 extends 雷达图报告
  # 如果想要排序能力，需要重新设计继承链
```

**Swift Protocol**：
```swift
// 直接组合排序能力
struct 多科雷达图报告V4Full: PPTSectionCapable, ChartGeneratable, Sortable, AliasCapable {
    // 同时拥有 4 种能力
}
```

---

## 最佳实践

### 1. Protocol 命名

使用 `*Capable` 或 `*Protocol` 后缀：

```swift
protocol DatabaseCapable { ... }
protocol PPTSectionCapable { ... }
protocol FileIOProtocol { ... }
```

### 2. 能力拆分原则

- 单一职责
- 可独立使用
- 可自由组合

### 3. 默认实现

在 Protocol Extension 中提供默认实现：

```swift
extension AliasCapable {
    func adjustedName(_ name: String) -> String {
        name.replacingOccurrences(of: "[*↑↓]", with: "", options: .regularExpression)
    }
}
```

### 4. 业务实体设计

```swift
struct 业务实体V4: 能力1, 能力2, 能力3 {
    // 1. 存储属性
    let dirname: String?
    let basename: String
    var cachedData: [String: Any]?
    
    // 2. computed var 模拟 @cso
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 3. 业务属性
    var 业务属性: Type {
        cso?[key] as? Type ?? defaultValue
    }
    
    // 4. Protocol 要求的方法
    func setDB() -> [String: Any] { ... }
}
```

### 5. 特化实现

```swift
// 基础版本
struct 原值排序报告V4: ... {
    let showValue: Bool = true
}

// 特化版本
struct 内部原值排序报告V4: ... {
    let showValue: Bool = false  // 只改这一个属性
}
```

---

## 局限性

### 1. 无法实现自动调度

原著通过 `@cso` 访问自动触发依赖初始化：

```coffeescript
# 原著
class 指标导向库
  @dataPrepare: ->
    for key, obj of 项目设置.cso.三级指标设置  # 访问时自动初始化 项目设置
      ...
```

Swift 需要显式调用：

```swift
// Swift
struct 指标导向库V4 {
    func dataPrepare() {
        let settings = 项目设置V4()  // 需要显式创建
        let data = settings.cso  // 需要显式访问
    }
}
```

### 2. 无状态缓存

原著 class-side 属性自动缓存：

```coffeescript
# 原著
项目设置.cso  # 第一次访问执行 dataPrepare
项目设置.cso  # 后续访问返回缓存
```

Swift struct 每次创建新实例：

```swift
// Swift
let s1 = 项目设置V4()
s1.cso  // 读取文件
let s2 = 项目设置V4()
s2.cso  // 再次读取文件

// 解决方案：使用类级缓存或 Actor
```

### 3. Protocol 重复定义

多个文件定义相同 Protocol 会导致冲突：

```swift
// File1.swift
protocol AliasCapable { ... }

// File2.swift
protocol AliasCapable { ... }  // 错误：重复定义
```

解决方案：统一在核心文件定义，其他文件引用

---

## 总结

### Swift 相比 CoffeeScript 的优势

| 特性 | CoffeeScript | Swift |
|------|-------------|-------|
| 继承 | 单继承 | 多重 Protocol |
| 组合 | 需要中间类 | 直接组合 |
| 类型安全 | 动态类型 | 静态类型 |
| 并发 | 无原生支持 | Actor 模型 |
| 特化 | 子类 override | 属性默认值 |

### 翻译建议

1. **放弃自动调度**：Swift 需要显式调用
2. **使用 Protocol 组合**：替代深层继承
3. **computed var 模拟 @cso**：利用编译器优化
4. **属性默认值实现特化**：避免创建子类
5. **统一命名 Protocol**：避免重复定义

---

## 附录

### 测试覆盖

- [x] Protocol 默认实现
- [x] 多重 Protocol 组合
- [x] Protocol 多态
- [x] 特化实现
- [x] 业务属性访问

### 文件结构

```
SwiftOffice/
├── Sources/
│   └── SwiftOffice/
│       ├── V4ProtocolStruct.swift      # 核心 Protocol 定义
│       ├── FullTranslation.swift       # 完整翻译示例
│       ├── MoreEntities.swift          # 更多业务实体
│       └── MultiProtocolAdvantage.swift # 优势展示
└── Tests/
    └── SwiftOfficeTests/
        ├── V4ProtocolStructTests.swift
        ├── FullTranslationTests.swift
        ├── MoreEntitiesTests.swift
        └── MultiProtocolAdvantageTests.swift
```

### 版本历史

- **v1-class-side**: Class 继承仿写
- **v2-pop**: Protocol 初步尝试
- **v3-refined**: 混合优化
- **v4-protocol-struct**: Protocol + Struct 深度实现 ✅

---

*文档版本: 1.0*
*最后更新: 2026-02-18*
