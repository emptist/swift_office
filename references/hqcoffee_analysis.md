# hqcoffee 项目分析报告

## 概述

hqcoffee 是一个基于 CoffeeScript 的医院量化分析工具，用于处理 Excel 数据、执行统计分析并生成 PPTX 报告。项目采用优雅的面向对象设计，具有深层次的继承体系。

---

## 关键架构洞察：Class 单侧编程模式

### 核心发现

hqcoffee 大量使用 **Class 单侧编程**（Class-Side Programming），通过命名 `Singleton` 明确暗示其设计意图：**用 CoffeeScript/JavaScript 的 class 静态侧来模拟 struct 的数据承载能力**，同时保持继承关系。

### 关键代码模式

```coffee
class 项目设置 extends NormalCaseSingleton
  @cso: @dataPrepare?()  # ← 核心：延迟初始化 + 单例缓存

  @dataPrepare: ->
    @sdb = @setDB({thisClass: this})
    项目设置.sdb.get(项目设置.name).set(项目设置.fetchSingleJSON()).save()
    @requestJSON()
```

**`@cso: @dataPrepare?()` 解析**：

| 符号 | 含义 |
|------|------|
| `@cso` | 类静态属性（Class-Side Object） |
| `:` | CoffeeScript 属性赋值 |
| `@dataPrepare` | 类静态方法 |
| `?()` | 存在则调用（安全调用操作符） |

**执行流程**：

```
第一次访问 类.cso
    │
    ├── @cso 未定义？
    │       │
    │       └── 是 → 调用 @dataPrepare?()
    │                   │
    │                   ├── 设置 @sdb（StormDB 实例）
    │                   ├── 从 JSON 文件加载数据
    │                   └── 返回结果并缓存到 @cso
    │
    └── 否 → 直接返回缓存的 @cso
```

### 统计数据

- **`@cso:` 出现次数**: 207 次（跨 6 个文件）
- **testSelf.coffee**: 51 处
- **common.coffee**: 4 处
- **jsonUtils.coffee**: 1 处（基类定义）

### 设计意图分析

#### 1. 为什么用 Class 而非 Struct？

**CoffeeScript/JavaScript 限制**：
- 无 struct 概念
- 无 protocol/protocol extension
- 继承只能通过 class

**解决方案**：
- 用 class 静态侧（`@property`）模拟 struct 的数据承载
- 用 class 继承实现代码复用
- 用 `@cso` 实现延迟初始化和缓存

#### 2. 与 Swift 的对比

| 特性 | CoffeeScript | Swift |
|------|--------------|-------|
| 数据载体 | Class 静态属性 | struct |
| 行为复用 | Class 继承 | protocol + extension |
| 延迟初始化 | `@cso: @method?()` | `lazy var` |
| 单例缓存 | 手动实现 | `static let shared` |
| 内存管理 | 无自动管理 | ARC / 值类型复制 |

#### 3. Swift 可以做得更好？

**Swift 的优势**：

```swift
// CoffeeScript 需要 class 继承链
class 项目设置 extends NormalCaseSingleton
  @cso: @dataPrepare?()
  @dataPrepare: -> ...

// Swift 可以用 protocol + struct
protocol 数据准备 {
    static var cso: Self { get }
    static func dataPrepare() -> Self
}

struct 项目设置: 数据准备 {
    static var cso: 项目设置 {
        // lazy + cached
    }
}
```

**但 Swift 缺少的关键能力**：

```coffee
# CoffeeScript 的自动串联
class PPTReport
  @sections: ->
    [
      三级指标数据统计分析      # ← 这些是 class，自动实例化
      三级指标数据前后各五名列表
      ...
    ]

  @make: ->
    for section in @sections()
      section.cso.生成幻灯片()   # ← 自动触发 @cso 初始化
```

**Swift 无法直接实现**：
- class 名称作为值传递
- 自动调用静态方法
- 跨 class 的自动调度

### 对 Swift 实现的影响

#### 方案 A：Protocol + Actor（推荐）

```swift
protocol 数据准备: AnyObject {
    static var cso: Self { get async }
    static func dataPrepare() async -> Self
}

actor 单例缓存<T: 数据准备> {
    static var instances: [String: T] = [:]
    
    static func get() async -> T {
        if let cached = instances[String(describing: T.self)] {
            return cached
        }
        let instance = await T.dataPrepare()
        instances[String(describing: T.self)] = instance
        return instance
    }
}
```

#### 方案 B：保留 Class 继承链

```swift
class StormDB单例: JSON数据库 {
    static var _cso: Self?
    class var cso: Self {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso!
    }
    
    class func dataPrepare() -> Self { ... }
}
```

#### 方案 C：混合模式

```swift
// 数据层用 struct
struct 项目数据: Codable {
    var 名称: String
    var 值: [String: Double]
}

// 行为层用 protocol
protocol 数据管理 {
    associatedtype 数据类型
    static var 数据: 数据类型 { get async }
}

// 实现用 class + 单例
class 项目设置: 数据管理 {
    typealias 数据类型 = 项目数据
    static var _数据: 项目数据?
    static var 数据: 项目数据 {
        get async {
            if _数据 == nil {
                _数据 = await 加载数据()
            }
            return _数据!
        }
    }
}
```

### 关键结论

1. **hqcoffee 的 class 单侧编程是一种在 CoffeeScript 限制下的精妙设计**
2. **Swift 可以用 protocol + struct 实现更清晰的分离**
3. **但 Swift 无法完全复制 `@cso: @dataPrepare?()` 的自动调度能力**
4. **需要设计一个调度器（Scheduler）来串联各个组件的初始化**

---

## 第二个乾坤：Class 作为一等公民

### 核心发现

CoffeeScript/JavaScript 中，**Class 本身是一等公民**，可以作为值传递、存储在数组中、作为函数参数。这实现了"定义即注册"的元编程模式。

### 关键代码模式

#### 1. Class 数组作为配置

```coffee
class 院科内部分析报告 extends PPTReport
  @init: @newReport(this)  # ← 定义时立即注册

  @sections: ->
    [
      三级指标数据统计分析      # ← Class 作为数组元素
      三级指标数据前后各五名列表
      三级指标非各部全零原值排序
      二级指标数据前后各五名列表 
      二级指标单科多指雷达线图
      # ... 更多 Class
    ]
```

#### 2. 自动遍历和调用

```coffee
class PPTReport extends NormalCaseSingleton
  @newReport: (reportClass) ->
    opts = @options()
    opts.generate = (funcOpts) =>
      {pres} = funcOpts
      # ...
      for section in reportClass.sections()  # ← 遍历 Class 数组
        sectionTitle = section.name           # ← 获取 Class 名称
        pres.addSection({title: sectionTitle})
        section.slides({section, pres, sectionTitle})  # ← 调用 Class 方法
```

#### 3. `@init: @newReport(this)` 解析

| 符号 | 含义 |
|------|------|
| `@init` | 类静态属性 |
| `@newReport` | 父类静态方法 |
| `this` | 当前类本身（Class 对象） |

**执行时机**：类定义完成后立即执行

**效果**：定义即注册，无需显式调用初始化

### 与 Swift 的对比

| 特性 | CoffeeScript | Swift |
|------|--------------|-------|
| Class 作为值 | ✅ 直接支持 | ⚠️ 需用 `Any.Type` |
| Class 名称获取 | `section.name` | `String(describing: type(of:))` |
| 动态方法调用 | `section.slides()` | 需 protocol 约束 |
| 定义时执行 | `@init: @method(this)` | 无直接对应 |

### Swift 可能的实现

```swift
// 方案 A：Protocol + Type Erasure
protocol PPTSection协议: AnyObject {
    static var name: String { get }
    static func slides(_ opts: 幻灯片选项) async
}

class 院科内部分析报告: PPTReport {
    static let init_ = newReport(Self.self)  // 模拟 @init
    
    static func sections() -> [PPTSection协议.Type] {
        [
            三级指标数据统计分析.self,  // .self 获取类型本身
            三级指标数据前后各五名列表.self,
            // ...
        ]
    }
}

// 方案 B：使用 @resultBuilder（Swift 5.4+）
@resultBuilder
struct SectionsBuilder {
    static func buildBlock(_ components: PPTSection协议.Type...) -> [PPTSection协议.Type] {
        components
    }
}

class 院科内部分析报告: PPTReport {
    @SectionsBuilder
    static func sections() -> [PPTSection协议.Type] {
        三级指标数据统计分析.self
        三级指标数据前后各五名列表.self
        // ...
    }
}
```

---

## 第三个乾坤：隐式数据依赖图

### 核心发现

通过 `@cso` 的延迟初始化，hqcoffee 构建了一个**隐式的数据依赖图**。当访问某个 Class 的 `cso` 时，会自动触发其依赖的 Class 的初始化。

### 依赖链示例

```
三级指标数据统计分析.cso
    │
    ├── 三级指标非各部全零原值排序.cso
    │       │
    │       ├── 三级指标对应二级指标.cso
    │       │
    │       └── 院内指标资料库.dbAsArray()
    │               │
    │               └── 院内指标资料库.cso
    │                       │
    │                       └── 院内资料库.cso
    │
    ├── 项目设置.cso
    │
    └── 指标导向库.cso
```

### 代码实现

```coffee
class 三级指标数据统计分析 extends 文本页面
  @cso: @dataPrepare?()

  @dataPrepare: ->
    @sdb = @setDB({thisClass: this})
    json = 三级指标非各部全零原值排序.cso  # ← 触发依赖初始化
    judges = 项目设置.cso.三级指标设置       # ← 触发依赖初始化
    directions = 指标导向库.cso              # ← 触发依赖初始化
    # ... 处理逻辑
```

### Swift 实现挑战

**问题**：Swift 的 `lazy var` 只能延迟单个实例，无法自动触发依赖链。

**解决方案**：

```swift
// 方案 A：显式依赖声明
protocol 数据依赖 {
    static var 依赖项: [数据依赖.Type] { get }
}

class 三级指标数据统计分析: 文本页面, 数据依赖 {
    static var 依赖项: [数据依赖.Type] {
        [
            三级指标非各部全零原值排序.self,
            项目设置.self,
            指标导向库.self
        ]
    }
    
    static func dataPrepare() async -> Self {
        // 先初始化依赖
        for dep in 依赖项 {
            _ = await dep.cso
        }
        // 再处理自己的逻辑
        // ...
    }
}

// 方案 B：使用 Actor + 任务图
actor 数据依赖调度器 {
    static var 初始化状态: [String: Bool] = [:]
    
    static func 确保<T: 数据准备>(_ type: T.Type) async -> T {
        let key = String(describing: type)
        if 初始化状态[key] != true {
            // 先初始化依赖
            for dep in type.依赖项 {
                _ = await 确保(dep)
            }
            // 再初始化自己
            _ = await type.dataPrepare()
            初始化状态[key] = true
        }
        return await type.cso
    }
}
```

---

## 第四个乾坤：元类编程模式

### 核心发现

hqcoffee 利用 CoffeeScript 的元类特性，实现了**类即实例**的设计模式。每个 Class 既是类型定义，又是唯一的实例。

### 模式对比

| 传统 OOP | hqcoffee 模式 |
|----------|---------------|
| `Class` → `Instance` | `Class` = `Instance` |
| 需要显式 `new` | 无需实例化 |
| 多个实例 | 单例（类本身） |
| 实例方法 | 类静态方法 |

### 代码对比

```coffee
# 传统 OOP
report = new PPTReport()
report.generate()

# hqcoffee 模式
PPTReport.generate()  # 直接调用类方法
院科内部分析报告.init   # 类即实例
```

### Swift 的对应

```swift
// Swift 无法完全复制，但可以用 static 实现类似效果
class PPTReport {
    static func generate() { ... }
}

// 调用方式相同
PPTReport.generate()
```

---

## 关键架构总结

| 乾坤 | 核心机制 | Swift 挑战 |
|------|----------|------------|
| 第一乾坤 | `@cso: @dataPrepare?()` 延迟初始化 | 需手动实现调度器 |
| 第二乾坤 | Class 作为一等公民传递 | 需用 Protocol.Type |
| 第三乾坤 | 隐式数据依赖图 | 需显式声明依赖 |
| 第四乾坤 | 类即实例的元类模式 | 可用 static 模拟 |

## Node.js 依赖包

| 包名 | 版本 | 用途 |
|------|------|------|
| convert-excel-to-json | ^1.7.0 | 读取 Excel 文件转 JSON |
| json-as-xlsx | ^2.3.10 | 将 JSON 写入 Excel 文件 |
| pptxgenjs | ^3.8.0 | 生成 PowerPoint 演示文稿 |
| simple-statistics | ^7.7.3 | 统计计算（均值、中位数等） |
| stormdb | ^0.5.2 | 基于 JSON 的数据库，支持文件持久化 |
| coffeescript | ^2.6.1 | 语言转译器（开发依赖） |

---

## 跨文件夹依赖关系

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           文件夹依赖关系图                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   cases/*/self.coffee                                                       │
│        │                                                                    │
│        ├── require ──► analyze/prepare.coffee (DataManager)                │
│        ├── require ──► analyze/fix.coffee (fix, existNumber)               │
│        ├── require ──► analyze/singletons.coffee (StormDBSingleton)        │
│        ├── require ──► usepptxgen/pptxgenUtils.coffee (MakePPTReport)      │
│        └── require ──► common/common.coffee (别名库, 名字ID库, 自制别名库)   │
│                                                                             │
│   common/common.coffee                                                      │
│        │                                                                    │
│        └── require ──► analyze/singletons.coffee (StormDBSingleton)        │
│                                                                             │
│   analyze/singletons.coffee                                                 │
│        │                                                                    │
│        └── require ──► analyze/jsonUtils.coffee (JSONDatabase)             │
│                                                                             │
│   usepptxgen/pptxgenUtils.coffee                                            │
│        │                                                                    │
│        └── require ──► analyze/jsonUtils.coffee (JSONDatabase)             │
│                                                                             │
│   analyze/jsonUtils.coffee                                                  │
│        │                                                                    │
│        ├── require ──► convert-excel-to-json (npm)                         │
│        ├── require ──► json-as-xlsx (npm)                                  │
│        ├── require ──► stormdb (npm)                                       │
│        └── require ──► analyze/fix.coffee (existNumber)                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 完整类继承体系

### 统计信息

- **总共 102 个 class**
- common: 6 个
- indicatorDef: 4 个
- jsonUtils: 3 个
- officegenUtils: 1 个
- pptxgenUtils: 2 个
- prepare: 3 个
- singletons: 1 个
- testSelf: 82 个

---

### 一、核心基础设施层 (analyze/)

#### 1.1 jsonUtils.coffee - JSON 处理基类

```
JSONSimple [jsonUtils.coffee:9] (无父类)
    │
    └── JSONDatabase [jsonUtils.coffee:259]
            │
            ├── JSONUtils [jsonUtils.coffee:363]
            │
            └── StormDBSingleton [singletons.coffee:8]
```

**职责说明：**
- `JSONSimple`: 最底层基类，负责 JSON 文件 I/O 操作（读取/写入 Excel 和 JSON）
- `JSONDatabase`: 添加 StormDB 集成，提供持久化 JSON 存储
- `JSONUtils`: JSON 操作的实用工具扩展
- `StormDBSingleton`: 单例模式，为数据库实例提供统一接口

#### 1.2 singletons.coffee - 单例基类

```
JSONDatabase
    │
    └── StormDBSingleton [singletons.coffee:8]
            │
            ├── AnyGlobalSingleton [common.coffee:7]
            │
            └── AnyCaseSingleton [testSelf.coffee:62]
```

**职责说明：**
- `StormDBSingleton`: 抽象基类，将从 Excel 转换而来的 JSON 辅助文件统一处理

---

### 二、全局通用层 (common/)

```
StormDBSingleton
    │
    └── AnyGlobalSingleton [common.coffee:7]
            │
            ├── 名字ID库 [common.coffee:30]
            │
            ├── 简称库 [common.coffee:40]
            │
            └── Alias [common.coffee:53]
                    │
                    ├── 别名库 [common.coffee:161]
                    │
                    └── 自制别名库 [common.coffee:172]
```

**职责说明：**
- `AnyGlobalSingleton`: 全局单例基类，跨所有项目共享
- `名字ID库`: 名字与ID的映射
- `简称库`: 简称映射
- `Alias`: 别名基类，提供名称规范化和别名管理
- `别名库`: 标准别名库
- `自制别名库`: 自定义别名库

---

### 三、案例专用层 (cases/*/self.coffee)

#### 3.1 基础案例单例

```
StormDBSingleton
    │
    └── AnyCaseSingleton [testSelf.coffee:62]
            │
            ├── CaseSingleton [testSelf.coffee:95]
            │       │
            │       ├── NormalCaseSingleton [testSelf.coffee:118]
            │       │
            │       └── 生成器 [testSelf.coffee:2534] ⚠️ 待删除
            │
            └── (被 AnyGlobalSingleton 继承)
```

**职责说明：**
- `AnyCaseSingleton`: 案例专用单例基类，处理项目路径
- `CaseSingleton`: 添加 years/units 数据访问方法
- `NormalCaseSingleton`: 为 Excel/JSON 操作提供标准配置
- `生成器`: ⚠️ 用户指示应删除，不参与核心功能

#### 3.2 日志系统

```
NormalCaseSingleton
    │
    └── LogSystem [testSelf.coffee:142]
            │
            ├── MistakeChasingLog [testSelf.coffee:153]
            │
            ├── MissingDataFuncLog [testSelf.coffee:160]
            │
            └── MissingDataRegister [testSelf.coffee:167]
```

**职责说明：** 错误追踪和缺失数据日志记录

#### 3.3 设置与指标体系

```
NormalCaseSingleton
    │
    ├── 项目设置 [testSelf.coffee:176]
    │
    └── 指标体系 [testSelf.coffee:247]
            │
            ├── 指标导向库 [testSelf.coffee:250]
            │
            ├── 三级指标局限权重 [testSelf.coffee:276]
            │
            ├── 二级指标终极权重 [testSelf.coffee:287]
            │
            ├── 三级指标对应二级指标 [testSelf.coffee:468]
            │
            ├── 二级指标对应三级指标 [testSelf.coffee:489]
            │
            ├── 二级指标对应一级指标 [testSelf.coffee:500]
            │
            ├── 一级指标对应二级指标 [testSelf.coffee:516]
            │
            ├── 三级指标对应一级指标 [testSelf.coffee:527]
            │
            ├── 一级指标对应三级指标 [testSelf.coffee:543]
            │
            └── 项目指标填报表 [testSelf.coffee:554]
```

**职责说明：** 医院指标的层级结构和权重管理

#### 3.4 PPT 报告章节系统

```
NormalCaseSingleton
    │
    └── PPTSection [testSelf.coffee:621]
            │
            ├── 文本页面 [testSelf.coffee:644]
            │       │
            │       ├── 三级指标数据统计分析 [testSelf.coffee:1440]
            │       │
            │       └── 临床专科BCG矩阵四象限 [testSelf.coffee:1874]
            │
            ├── 表格页面 [testSelf.coffee:671]
            │       │
            │       ├── 科室逐项指标排名表 [testSelf.coffee:681]
            │       │       │
            │       │       ├── 三级指标数据前后各五名列表 [testSelf.coffee:1488]
            │       │       │
            │       │       └── 二级指标数据前后各五名列表 [testSelf.coffee:1734]
            │       │
            │       └── 学科梯队列表共通法类 [testSelf.coffee:2100]
            │               │
            │               ├── 学科梯队排序表含大科及合并对标科室 [testSelf.coffee:2202]
            │               │
            │               ├── 学科梯队排序表含大科 [testSelf.coffee:2211]
            │               │
            │               └── 学科梯队排序表 [testSelf.coffee:2220]
            │
            ├── 散点图报告 [testSelf.coffee:754]
            │       │
            │       ├── BCG矩阵报告 [testSelf.coffee:845]
            │       │       │
            │       │       ├── 临床专科医服收入BCG矩阵分析含大科及合并对标科室 [testSelf.coffee:1808]
            │       │       │
            │       │       ├── 临床专科医服收入BCG矩阵分析 [testSelf.coffee:1829]
            │       │       │
            │       │       ├── 临床专科医服收入BCG矩阵分析限高比重科室 [testSelf.coffee:1881]
            │       │       │
            │       │       ├── 临床专科人均床均自定义收入分析 [testSelf.coffee:1909]
            │       │       │
            │       │       ├── 临床专科有效收入BCG矩阵分析含大科及合并对标科室 [testSelf.coffee:1953]
            │       │       │
            │       │       ├── 临床专科有效收入BCG矩阵分析 [testSelf.coffee:1983]
            │       │       │
            │       │       └── 临床专科有效收入BCG矩阵分析限高比重科室 [testSelf.coffee:2033]
            │       │
            │       ├── 二级指标轮比散点图 [testSelf.coffee:1784]
            │       │
            │       └── 院内单科多维评分散点图 [testSelf.coffee:1798]
            │
            ├── 排序报告 [testSelf.coffee:971]
            │       │
            │       ├── 原值排序报告 [testSelf.coffee:1047]
            │       │       │
            │       │       ├── 三级指标非各部全零原值排序 [testSelf.coffee:1413]
            │       │       │
            │       │       └── 三级指标分科对标非各部全零原值排序 [testSelf.coffee:2284]
            │       │
            │       └── 评分排序报告 [testSelf.coffee:1050]
            │               │
            │               ├── 三级指标非各部全零评分排序 [testSelf.coffee:1567]
            │               │
            │               └── 三级指标分科对标评分排序 [testSelf.coffee:2307]
            │
            └── 雷达图报告 [testSelf.coffee:1055]
                    │
                    ├── 多科雷达图报告 [testSelf.coffee:1060]
                    │       │
                    │       ├── 三级指标各科轮比分析 [testSelf.coffee:1588]
                    │       │
                    │       └── 二级指标多科双指轮比雷达线图 [testSelf.coffee:1773]
                    │
                    └── 单科雷达图报告 [testSelf.coffee:1121]
                            │
                            ├── 各科三级指标评分汇总分析 [testSelf.coffee:1598]
                            │
                            ├── 二级指标单科多指雷达线图 [testSelf.coffee:1750]
                            │
                            └── 单科对比雷达图报告 [testSelf.coffee:1171]
                                    │
                                    ├── 三级指标分科对标评分单科多指雷达线图 [testSelf.coffee:2357]
                                    │
                                    └── 二级指标分科对标评分单科多指雷达线图 [testSelf.coffee:2416]
```

#### 3.5 资料库系统

```
NormalCaseSingleton
    │
    └── 资料库 [testSelf.coffee:1223]
            │
            ├── 综合资料库 [testSelf.coffee:1228]
            │       │
            │       └── 非手术科室名单 [testSelf.coffee:1331]
            │               │
            │               ├── 设定非手术科室名单 [testSelf.coffee:1338]
            │               │
            │               └── 推断非手术科室名单 [testSelf.coffee:1343]
            │
            ├── 指标资料库 [testSelf.coffee:1231]
            │       │
            │       ├── 院内指标资料库 [testSelf.coffee:1361]
            │       │
            │       ├── 三级指标所有原值排序库 [testSelf.coffee:1392]
            │       │
            │       ├── 三级指标评分排序共通法类 [testSelf.coffee:1503]
            │       │
            │       ├── 三级指标所有评分排序库 [testSelf.coffee:1550]
            │       │
            │       ├── 二级指标汇补各科三级指标评分 [testSelf.coffee:1611]
            │       │
            │       ├── 二级指标各科数据全集 [testSelf.coffee:1673]
            │       │
            │       ├── 二级指标各科数据排序 [testSelf.coffee:1708]
            │       │
            │       ├── 学科梯队二级指标综合评分 [testSelf.coffee:2071]
            │       │
            │       └── 对标指标资料库 [testSelf.coffee:2234]
            │
            └── 原始资料库 [testSelf.coffee:1233]
                    │
                    ├── 对标资料库 [testSelf.coffee:1291]
                    │
                    └── 院内资料库 [testSelf.coffee:1299]
```

#### 3.6 PPT 报告系统

```
NormalCaseSingleton
    │
    └── PPTReport [testSelf.coffee:2426]
            │
            ├── 院科混合分析报告 [testSelf.coffee:2473]
            │
            ├── 院科内部分析报告 [testSelf.coffee:2475]
            │
            └── 院科外部对标报告 [testSelf.coffee:2516]
```

---

### 四、PPT 生成层 (usepptxgen/)

```
PPTXGenUtils [pptxgenUtils.coffee:44] (无父类，独立工具类)

MakePPTReport [pptxgenUtils.coffee:75] (无父类，独立工具类)
```

---

### 五、指标定义层 (analyze/indicatorDef.coffee)

```
IndicatorDefCategory [indicatorDef.coffee:8] (无父类)

IndicatorDefVersion [indicatorDef.coffee:23] (无父类)

IndicatorDefInfoByVersion [indicatorDef.coffee:41] (无父类)

IndicatorDef [indicatorDef.coffee:73] (无父类)
```

---

### 六、数据管理层 (analyze/prepare.coffee)

```
DataManagerBase [prepare.coffee:4]
    │
    ├── DataManager [prepare.coffee:190]
    │
    └── DataManagerDemo [prepare.coffee:1257]
```

---

### 七、OfficeGen 层 (useofficegen/) - 已弃用

```
OfficeGenUtils [officegenUtils.coffee:13] (无父类，存在 bug，未使用)
```

---

## 完整继承链一览（按深度排序）

### 深度 1（无父类）
```
JSONSimple
DataManagerBase
IndicatorDefCategory
IndicatorDefVersion
IndicatorDefInfoByVersion
IndicatorDef
PPTXGenUtils
MakePPTReport
OfficeGenUtils
```

### 深度 2
```
JSONSimple -> JSONDatabase
DataManagerBase -> DataManager
DataManagerBase -> DataManagerDemo
```

### 深度 3
```
JSONSimple -> JSONDatabase -> JSONUtils
JSONSimple -> JSONDatabase -> StormDBSingleton
```

### 深度 4
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton
```

### 深度 5
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton -> Alias
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton -> 名字ID库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton -> 简称库
```

### 深度 6
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> 生成器
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton -> Alias -> 别名库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyGlobalSingleton -> Alias -> 自制别名库
```

### 深度 7
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> LogSystem
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTReport
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 项目设置
```

### 深度 8
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> LogSystem -> MissingDataFuncLog
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> LogSystem -> MissingDataRegister
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> LogSystem -> MistakeChasingLog
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTReport -> 院科内部分析报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTReport -> 院科外部对标报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTReport -> 院科混合分析报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 文本页面
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 指标导向库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 三级指标局限权重
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 二级指标终极权重
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 三级指标对应二级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 二级指标对应三级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 二级指标对应一级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 一级指标对应二级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 三级指标对应一级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 一级指标对应三级指标
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 指标体系 -> 项目指标填报表
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 综合资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 原始资料库
```

### 深度 9
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 原值排序报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 评分排序报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> 二级指标轮比散点图
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> 院内单科多维评分散点图
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 文本页面 -> 三级指标数据统计分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 文本页面 -> 临床专科BCG矩阵四象限
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 科室逐项指标排名表
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 学科梯队列表共通法类
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 多科雷达图报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 综合资料库 -> 非手术科室名单
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 院内指标资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 三级指标所有原值排序库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 三级指标评分排序共通法类
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 三级指标所有评分排序库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 二级指标汇补各科三级指标评分
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 二级指标各科数据全集
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 二级指标各科数据排序
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 学科梯队二级指标综合评分
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 指标资料库 -> 对标指标资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 原始资料库 -> 对标资料库
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 原始资料库 -> 院内资料库
```

### 深度 10
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 原值排序报告 -> 三级指标非各部全零原值排序
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 原值排序报告 -> 三级指标分科对标非各部全零原值排序
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 评分排序报告 -> 三级指标非各部全零评分排序
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 排序报告 -> 评分排序报告 -> 三级指标分科对标评分排序
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科医服收入BCG矩阵分析含大科及合并对标科室
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科医服收入BCG矩阵分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科医服收入BCG矩阵分析限高比重科室
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科人均床均自定义收入分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科有效收入BCG矩阵分析含大科及合并对标科室
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科有效收入BCG矩阵分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 散点图报告 -> BCG矩阵报告 -> 临床专科有效收入BCG矩阵分析限高比重科室
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 科室逐项指标排名表 -> 三级指标数据前后各五名列表
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 科室逐项指标排名表 -> 二级指标数据前后各五名列表
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 学科梯队列表共通法类 -> 学科梯队排序表含大科及合并对标科室
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 学科梯队列表共通法类 -> 学科梯队排序表含大科
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 表格页面 -> 学科梯队列表共通法类 -> 学科梯队排序表
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 多科雷达图报告 -> 三级指标各科轮比分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 多科雷达图报告 -> 二级指标多科双指轮比雷达线图
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告 -> 各科三级指标评分汇总分析
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告 -> 二级指标单科多指雷达线图
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告 -> 单科对比雷达图报告
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 综合资料库 -> 非手术科室名单 -> 设定非手术科室名单
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> 资料库 -> 综合资料库 -> 非手术科室名单 -> 推断非手术科室名单
```

### 深度 11
```
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告 -> 单科对比雷达图报告 -> 三级指标分科对标评分单科多指雷达线图
JSONSimple -> JSONDatabase -> StormDBSingleton -> AnyCaseSingleton -> CaseSingleton -> NormalCaseSingleton -> PPTSection -> 雷达图报告 -> 单科雷达图报告 -> 单科对比雷达图报告 -> 二级指标分科对标评分单科多指雷达线图
```

---

## 关键设计模式

### 1. 单例模式 + StormDB
所有数据类继承自 `StormDBSingleton`，提供：
- 通过 StormDB 实现持久化 JSON 存储
- 使用 `@cso: @dataPrepare?()` 实现延迟初始化
- 基于文件的数据库，自动保存

### 2. 模板方法模式
`PPTSection` 定义结构，子类实现：
- `@sectionData(sectionClass)` - 数据获取
- `@slides(funcOpts)` - 幻灯片生成

### 3. 策略模式
不同的报告类型（排序报告、雷达图报告、散点图报告）实现不同的可视化策略，共享相同的数据管道。

### 4. 装饰器模式
`NormalCaseSingleton` 为 `CaseSingleton` 添加标准的 Excel/JSON 配置。

---

## 数据流架构

```
Excel 文件 (项目设置.xlsx, 院内资料库.xlsx, 对标资料库.xlsx)
        │
        ▼
    JSONSimple.getJSON() ──► JSON 文件 (.json)
        │
        ▼
    StormDBSingleton.setDB() ──► StormDB (内存 + 文件持久化)
        │
        ▼
    指标体系 / 资料库 classes ──► 处理后的指标数据
        │
        ▼
    PPTSection 子类 ──► 图表/表格数据准备
        │
        ▼
    MakePPTReport.newReport() ──► PPTX 文件输出
```

---

## Swift 翻译需求

### 核心功能实现：

1. **Excel I/O**
   - 读取 Excel 到结构化数据（类似 `convert-excel-to-json`）
   - 将结构化数据写入 Excel（类似 `json-as-xlsx`）

2. **JSON 数据库**
   - 基于文件的持久化（类似 `stormdb`）
   - 内存操作 + 保存/加载

3. **PPTX 生成**
   - 创建带图表的幻灯片（柱状图、雷达图、散点图）
   - 添加文本、表格、章节

4. **统计功能**
   - 均值、中位数、标准差（类似 `simple-statistics`）

### Swift 包结构建议：

```
SwiftOffice/
├── Sources/
│   ├── 核心层/           # 基础类、协议
│   ├── Excel层/          # Excel 读写
│   ├── PPTX层/           # PowerPoint 生成
│   ├── 数据库层/         # JSON 数据库
│   └── 统计层/           # 统计工具
├── Tests/
│   └── SwiftOfficeTests/
├── Examples/
│   └── 医院分析/         # 示例用例
└── Package.swift
```

---

## 注意事项

### ⚠️ 待删除的类
- `生成器` [testSelf.coffee:2534] - 用户指示应删除

### ⚠️ 已弃用的类
- `OfficeGenUtils` [officegenUtils.coffee:13] - 存在 bug，未使用

### ⚠️ 多版本文件
- `prepare.coffee` / `prepare.origin.coffee` / `prepare.yn.coffee` - 存在多个版本，需确认使用哪个
