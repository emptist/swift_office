# Swift 集成方案详细比较

## 概述

本文档详细比较在 Swift 中实现 hqcoffee 核心功能的多种技术方案，包括 Excel 读写、PPTX 生成、JSON 数据库和统计计算。

---

## 一、Excel 读写方案比较

### 方案 A：CoreXLSX (读取) + libxlsxwriter (写入)

#### CoreXLSX (读取)
- **仓库**: https://github.com/CoreOffice/CoreXLSX
- **语言**: 纯 Swift
- **支持平台**: iOS, macOS, Linux, Windows
- **SPM 集成**: ✅ 支持
- **功能**:
  - 解析 .xlsx 格式
  - 读取工作表、单元格、共享字符串
  - 支持公式、日期、数字格式
- **限制**: 只读，不支持写入

#### libxlsxwriter (写入)
- **仓库**: https://github.com/jmcnamara/libxlsxwriter
- **语言**: C 语言（需要 Swift 桥接）
- **SPM 集成**: ⚠️ 需要 CocoaPods 或手动集成
- **功能**:
  - 创建 .xlsx 文件
  - 写入数据、格式化单元格
  - 支持图表、公式
- **限制**: 只写，不支持读取

**优点**:
- CoreXLSX 是纯 Swift，易于集成
- libxlsxwriter 功能强大，支持复杂格式

**缺点**:
- 需要两个库配合使用
- libxlsxwriter 需要 C 桥接

---

### 方案 B：纯 Swift 实现（基于 XML）

**原理**: XLSX 文件本质是 ZIP 压缩的 XML 文件集合

**实现步骤**:
1. 使用 `ZIPFoundation` 解压 .xlsx
2. 解析 `xl/worksheets/sheet*.xml`
3. 解析 `xl/sharedStrings.xml` 获取共享字符串
4. 使用 `XMLCoder` 或 `XMLParser` 解析 XML

**优点**:
- 完全控制实现
- 无第三方依赖
- 可同时支持读写

**缺点**:
- 开发工作量大
- 需要处理复杂的 Excel 格式细节

---

### 方案 C：调用 Node.js 子进程

**原理**: 在 Swift 中调用 Node.js 执行现有的 JavaScript 库

```swift
import Foundation

func convertExcelToJSON(excelPath: String) throws -> [String: Any] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/node")
    
    let script = """
    const converter = require('convert-excel-to-json');
    const result = converter({ source: '\(excelPath)' });
    console.log(JSON.stringify(result));
    """
    
    // 执行并获取结果
    // ...
}
```

**优点**:
- 直接复用现有 Node.js 库
- 功能完整，无需重新实现

**缺点**:
- 需要 Node.js 运行时环境
- 跨进程通信开销
- 部署复杂度高

---

### 方案 D：使用 SwiftExcel

- **仓库**: https://github.com/patgoley/SwiftExcel
- **语言**: Swift
- **功能**: 基本的 Excel 读写
- **状态**: ⚠️ 项目维护不活跃

---

### Excel 方案推荐

| 方案 | 读取 | 写入 | 复杂度 | 推荐度 |
|------|------|------|--------|--------|
| CoreXLSX + libxlsxwriter | ✅ | ✅ | 中 | ⭐⭐⭐⭐ |
| 纯 Swift XML | ✅ | ✅ | 高 | ⭐⭐⭐ |
| Node.js 子进程 | ✅ | ✅ | 低 | ⭐⭐ |
| SwiftExcel | ✅ | ✅ | 低 | ⭐ |

**推荐**: 方案 A (CoreXLSX + libxlsxwriter)

---

## 二、PPTX 生成方案比较

### 方案 A：纯 Swift XML 实现

**原理**: PPTX 文件是 ZIP 压缩的 XML 文件集合

**文件结构**:
```
presentation.pptx
├── [Content_Types].xml
├── _rels/.rels
├── ppt/
│   ├── presentation.xml
│   ├── slides/
│   │   ├── slide1.xml
│   │   └── slide2.xml
│   ├── slideLayouts/
│   ├── slideMasters/
│   └── theme/
└── docProps/
```

**实现步骤**:
1. 创建 XML 模板
2. 使用 `XMLCoder` 或手动构建 XML
3. 使用 `ZIPFoundation` 打包为 .pptx

**优点**:
- 完全控制
- 无外部依赖

**缺点**:
- 开发工作量大
- 需要深入理解 OOXML 格式

---

### 方案 B：调用 Python python-pptx

```swift
func generatePPTX(data: [String: Any], outputPath: String) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
    
    let script = """
    from pptx import Presentation
    from pptx.util import Inches, Pt
    
    prs = Presentation()
    slide = prs.slides.add_slide(prs.slide_layouts[0])
    # ... 添加内容
    prs.save('\(outputPath)')
    """
    
    // 执行脚本
}
```

**优点**:
- python-pptx 功能完善
- 支持图表、表格、图片

**缺点**:
- 需要 Python 环境
- 跨进程通信

---

### 方案 C：调用 Node.js pptxgenjs

```swift
func generatePPTX(json: [String: Any], outputPath: String) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/node")
    
    // 执行 pptxgenjs 脚本
}
```

**优点**:
- 直接复用 hqcoffee 的 pptxgenjs 逻辑
- 图表支持完善

**缺点**:
- 需要 Node.js 环境

---

### 方案 D：使用 AppKit PDF 导出 + 转换

**原理**: 使用 SwiftUI/AppKit 创建演示内容，导出为 PDF，再转换为 PPTX

**优点**:
- 利用原生 UI 框架
- 可视化预览

**缺点**:
- 转换过程复杂
- 可能丢失格式

---

### PPTX 方案推荐

| 方案 | 图表支持 | 复杂度 | 部署依赖 | 推荐度 |
|------|----------|--------|----------|--------|
| 纯 Swift XML | 需实现 | 高 | 无 | ⭐⭐⭐ |
| Python python-pptx | ✅ | 中 | Python | ⭐⭐⭐⭐ |
| Node.js pptxgenjs | ✅ | 低 | Node.js | ⭐⭐⭐⭐⭐ |
| PDF 转换 | ❌ | 高 | 无 | ⭐⭐ |

**推荐**: 方案 C (Node.js pptxgenjs) 或 方案 B (Python python-pptx)

---

## 三、JSON 数据库方案比较

### 方案 A：纯 Swift 文件持久化

```swift
class JSONDatabase<T: Codable> {
    private let fileURL: URL
    private var data: [String: T]
    
    init(filename: String) {
        self.fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(filename).json")
        self.data = [:]
        load()
    }
    
    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: T].self, from: data) else { return }
        self.data = decoded
    }
    
    func save() {
        let encoded = try? JSONEncoder().encode(data)
        try? encoded?.write(to: fileURL)
    }
    
    subscript(key: String) -> T? {
        get { data[key] }
        set { data[key] = newValue; save() }
    }
}
```

**优点**:
- 完全控制
- 无外部依赖
- 类型安全

**缺点**:
- 大文件性能问题
- 无查询优化

---

### 方案 B：SQLite + JSON 扩展

**使用 GRDB.swift**:
```swift
import GRDB

class JSONRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var json: String  // JSON 字符串
}

// 查询 JSON 内容
let records = try dbQueue.read { db in
    try JSONRecord.fetchAll(db)
}
```

**优点**:
- 成熟的数据库引擎
- 支持事务、索引
- 查询性能好

**缺点**:
- 需要额外的序列化/反序列化
- 不如纯 JSON 直观

---

### 方案 C：Realm

```swift
import RealmSwift

class DataItem: Object {
    @objc dynamic var key: String = ""
    @objc dynamic var value: String = ""  // JSON 字符串
}
```

**优点**:
- 对象数据库，使用直观
- 性能优秀
- 支持加密

**缺点**:
- 需要定义模型类
- 模式迁移复杂

---

### 方案 D：Core Data

**优点**:
- Apple 官方框架
- 与 SwiftUI 集成好

**缺点**:
- 学习曲线陡峭
- 不适合动态 JSON 结构

---

### JSON 数据库方案推荐

| 方案 | 性能 | 易用性 | 类型安全 | 推荐度 |
|------|------|--------|----------|--------|
| 纯 Swift 文件 | 低 | 高 | ✅ | ⭐⭐⭐⭐ |
| GRDB + JSON | 高 | 中 | ✅ | ⭐⭐⭐ |
| Realm | 高 | 中 | ⚠️ | ⭐⭐⭐ |
| Core Data | 高 | 低 | ✅ | ⭐⭐ |

**推荐**: 方案 A (纯 Swift 文件持久化) - 与 hqcoffee 的 StormDB 设计理念一致

---

## 四、统计计算方案比较

### 方案 A：纯 Swift 实现

```swift
enum 统计 {
    static func 均值<T: BinaryFloatingPoint>(_ values: [T]) -> T? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / T(values.count)
    }
    
    static func 中位数<T: BinaryFloatingPoint>(_ values: [T]) -> T? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 0 {
            return (sorted[mid - 1] + sorted[mid]) / 2
        } else {
            return sorted[mid]
        }
    }
    
    static func 标准差<T: BinaryFloatingPoint>(_ values: [T]) -> T? {
        guard let mean = 均值(values) else { return nil }
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / T(values.count)
        return sqrt(variance)
    }
}
```

**优点**:
- 无外部依赖
- 完全控制

**缺点**:
- 需要自己实现所有统计函数

---

### 方案 B：使用 Accelerate 框架

```swift
import Accelerate

func 均值(_ values: [Double]) -> Double {
    var result = 0.0
    vDSP_meanvD(values, 1, &result, vDSP_Length(values.count))
    return result
}
```

**优点**:
- Apple 官方框架
- 高性能（SIMD 优化）

**缺点**:
- API 较底层
- 部分统计函数需自己组合

---

### 方案 C：使用 SigmaStatistics

- **仓库**: https://github.com/evgenyneu/SigmaSwiftStatistics
- **功能**: 均值、中位数、标准差、方差、相关系数等

**优点**:
- 功能完整
- API 友好

**缺点**:
- 第三方依赖

---

### 统计方案推荐

| 方案 | 功能完整度 | 性能 | 依赖 | 推荐度 |
|------|------------|------|------|--------|
| 纯 Swift | 按需实现 | 中 | 无 | ⭐⭐⭐ |
| Accelerate | 基础函数 | 高 | 系统框架 | ⭐⭐⭐⭐ |
| SigmaStatistics | ✅ 完整 | 中 | 第三方 | ⭐⭐⭐⭐ |

**推荐**: 方案 B (Accelerate) 或 方案 C (SigmaStatistics)

---

## 五、综合架构方案

### 方案 A：纯 Swift 实现

```
SwiftOffice/
├── Sources/
│   ├── 核心层/
│   │   ├── JSON基类.swift
│   │   ├── JSON数据库.swift
│   │   └── 单例基类.swift
│   ├── Excel层/
│   │   ├── Excel读取器.swift      (CoreXLSX)
│   │   └── Excel写入器.swift      (libxlsxwriter)
│   ├── PPTX层/
│   │   ├── PPTX生成器.swift       (纯 Swift XML)
│   │   └── 图表构建器.swift
│   ├── 数据库层/
│   │   └── JSON数据库.swift
│   └── 统计层/
│       └── 统计函数.swift
└── Package.swift
```

**优点**:
- 单一语言栈
- 部署简单

**缺点**:
- 开发周期长
- PPTX 图表实现复杂

---

### 方案 B：Swift + Node.js 混合

```
SwiftOffice/
├── Sources/
│   ├── 核心层/
│   ├── Excel层/          (CoreXLSX + libxlsxwriter)
│   ├── 数据库层/
│   └── 统计层/
├── Scripts/
│   └── pptx-generator.js  (pptxgenjs)
└── Package.swift
```

**优点**:
- 复用成熟的 Node.js 库
- 开发效率高

**缺点**:
- 需要 Node.js 运行时
- 部署复杂

---

### 方案 C：Swift + Python 混合

```
SwiftOffice/
├── Sources/
│   ├── 核心层/
│   ├── Excel层/
│   ├── 数据库层/
│   └── 统计层/
├── Scripts/
│   └── pptx_generator.py  (python-pptx)
└── Package.swift
```

**优点**:
- Python 生态丰富
- python-pptx 功能完善

**缺点**:
- 需要 Python 环境

---

## 六、最终推荐方案

### 推荐组合

| 功能模块 | 推荐方案 | 理由 |
|----------|----------|------|
| Excel 读取 | CoreXLSX | 纯 Swift，SPM 支持 |
| Excel 写入 | libxlsxwriter | 功能强大，社区成熟 |
| PPTX 生成 | Node.js pptxgenjs | 直接复用 hqcoffee 逻辑 |
| JSON 数据库 | 纯 Swift 文件 | 与 StormDB 设计一致 |
| 统计计算 | Accelerate + 自定义 | 高性能，无第三方依赖 |

### 实施优先级

1. **第一阶段**: 核心基础设施
   - JSON基类
   - JSON数据库
   - 单例模式

2. **第二阶段**: Excel 读写
   - CoreXLSX 集成
   - libxlsxwriter 集成

3. **第三阶段**: 统计功能
   - 基础统计函数
   - Accelerate 集成

4. **第四阶段**: PPTX 生成
   - Node.js 子进程调用
   - 或纯 Swift XML 实现

5. **第五阶段**: 示例应用
   - 医院分析报告生成器

---

## 七、风险与缓解措施

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| libxlsxwriter C 桥接复杂 | 中 | 使用 Swift Package 封装 |
| PPTX 图表实现困难 | 高 | 优先使用 Node.js 方案 |
| 大文件性能问题 | 中 | 分块处理，延迟加载 |
| Node.js 环境依赖 | 低 | 提供安装脚本，或打包为独立可执行文件 |
