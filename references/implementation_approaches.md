# SwiftOffice 实现方案比较

## 项目定位

**目标**：创建一个 Swift 库，利用 Swift 6.2 的最新特性，结合 Node.js 生态，实现与 hqcoffee 相媲美的 Office 数据处理能力。

**核心原则**：
- Office 操作（Excel/PPTX）→ Node.js 库
- 数据库/统计/核心逻辑 → Swift 原生
- 架构风格 → Protocol-Oriented Programming (POP)

---

## 一、Swift + Node.js 混合架构方案

### 方案 A：子进程调用（推荐）

**原理**：Swift 通过 `Process` 调用 Node.js 脚本，通过 stdin/stdout 或临时文件交换数据。

```
┌─────────────────────────────────────────────────────────────┐
│                     Swift 应用层                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  数据模型   │  │  业务逻辑   │  │  统计计算   │         │
│  │  (struct)   │  │ (protocol)  │  │ (Accelerate)│         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                          │                                   │
│                          ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Node.js 桥接层                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │   │
│  │  │ Excel读取   │  │ Excel写入   │  │ PPTX生成    │  │   │
│  │  │(convert-    │  │(json-as-    │  │(pptxgenjs)  │  │   │
│  │  │excel-to-    │  │xlsx)        │  │             │  │   │
│  │  │json)        │  │             │  │             │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**实现示例**：

```swift
// Swift 侧
actor NodeJS桥接器 {
    private let nodePath = "/usr/local/bin/node"
    private let scriptsPath: URL
    
    init(scriptsPath: URL) {
        self.scriptsPath = scriptsPath
    }
    
    func 执行脚本(_ name: String, 参数: [String: Any]) async throws -> [String: Any] {
        let scriptURL = scriptsPath.appendingPathComponent("\(name).js")
        let inputJSON = try JSONSerialization.data(withJSONObject: 参数)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: nodePath)
        process.arguments = [scriptURL.path]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardInput = Pipe()
        
        // 写入输入
        (process.standardInput as? Pipe)?.fileHandleForWriting.write(inputJSON)
        
        try process.run()
        process.waitUntilExit()
        
        // 读取输出
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        return try JSONSerialization.jsonObject(with: outputData) as! [String: Any]
    }
}

// 使用
let 桥接器 = NodeJS桥接器(scriptsPath: URL(fileURLWithPath: "./scripts"))
let excel数据 = try await 桥接器.执行脚本("readExcel", 参数: [
    "path": "/data/input.xlsx",
    "sheet": "Sheet1"
])
```

```javascript
// Node.js 侧 (scripts/readExcel.js)
const converter = require('convert-excel-to-json');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const params = JSON.parse(input);
    const result = converter({
        source: params.path,
        sheetStubs: true
    });
    console.log(JSON.stringify(result));
});
```

**优点**：
- 实现简单，无需额外依赖
- 可直接复用现有 Node.js 库
- 隔离性好，Node.js 崩溃不影响 Swift

**缺点**：
- 每次调用都有进程启动开销
- 数据序列化/反序列化开销
- 需要管理临时文件

---

### 方案 B：嵌入式 JavaScript 引擎

**原理**：使用 JavaScriptCore 或 QuickJS 在 Swift 进程内执行 JavaScript。

```swift
import JavaScriptCore

class JS引擎 {
    private let context = JSContext()!
    
    init() {
        // 加载 npm 包（需要打包）
        加载脚本("node_modules/bundle.js")
    }
    
    func 调用函数(_ name: String, 参数: [Any]) -> Any? {
        let jsFunction = context.objectForKeyedSubscript(name)
        return jsFunction?.call(withArguments: 参数)
    }
}
```

**优点**：
- 无进程启动开销
- 数据直接在内存中传递

**缺点**：
- 无法直接使用 npm 包（需要打包）
- JavaScriptCore 不支持 Node.js API
- 调试困难

---

### 方案 C：HTTP 服务桥接

**原理**：Node.js 作为 HTTP 服务运行，Swift 通过 HTTP 请求调用。

```
Swift 应用 ──HTTP──► Node.js 服务 ──► Office 操作
     ▲                    │
     └────── JSON ────────┘
```

```swift
// Swift 侧
func 调用Office服务(_ endpoint: String, 参数: [String: Any]) async throws -> [String: Any] {
    var request = URLRequest(url: URL(string: "http://localhost:3000/\(endpoint)")!)
    request.httpMethod = "POST"
    request.httpBody = try JSONSerialization.data(withJSONObject: 参数)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONSerialization.jsonObject(with: data) as! [String: Any]
}
```

**优点**：
- 服务可独立部署和扩展
- 支持远程调用
- 易于调试

**缺点**：
- 需要管理服务生命周期
- HTTP 开销
- 部署复杂度高

---

### 方案比较

| 方案 | 实现复杂度 | 性能 | 部署复杂度 | 推荐度 |
|------|------------|------|------------|--------|
| A: 子进程调用 | 低 | 中 | 低 | ⭐⭐⭐⭐⭐ |
| B: 嵌入式引擎 | 高 | 高 | 中 | ⭐⭐ |
| C: HTTP 服务 | 中 | 低 | 高 | ⭐⭐⭐ |

**推荐**：方案 A（子进程调用）

---

## 二、POP 架构设计

### 核心思路

用 Swift 的 Protocol + Extension + Struct 替代 CoffeeScript 的 Class 继承链。

### 原 CoffeeScript 继承链

```
JSONSimple → JSONDatabase → StormDBSingleton → AnyCaseSingleton 
→ CaseSingleton → NormalCaseSingleton → PPTSection → 具体Section
```

### Swift POP 重构

```swift
// 第一层：数据协议
protocol JSON数据: Codable {
    static var 文件名: String { get }
    static func 读取() async throws -> Self
    static func 写入(_ data: Self) async throws
}

// 第二层：数据库协议
protocol JSON数据库: JSON数据 {
    associatedtype 数据类型: Codable
    var 数据: 数据类型 { get set }
    func 保存() async throws
}

// 第三层：单例协议
protocol 单例: AnyObject {
    static var 共享实例: Self { get async }
    static func 初始化() async -> Self
}

// 第四层：数据准备协议
protocol 数据准备: 单例 {
    static var 依赖项: [数据准备.Type] { get }
    static func 数据准备() async throws
}

// 第五层：PPT Section 协议
protocol PPTSection: 数据准备 {
    static var 名称: String { get }
    static func 生成幻灯片(_ 上下文: PPT上下文) async throws
}

// 第六层：PPT Report 协议
protocol PPT报告: 数据准备 {
    associatedtype Section类型: PPTSection
    static func sections() -> [Section类型.Type]
    static func 生成报告() async throws
}
```

### 具体实现示例

```swift
// 数据模型（struct）
struct 三级指标数据: Codable {
    var 指标名: String
    var 数值: [String: Double]
}

// 数据库实现
actor 三级指标数据库: JSON数据库 {
    typealias 数据类型 = [String: 三级指标数据]
    
    static var 文件名: String { "三级指标数据.json" }
    var 数据: 数据类型 = [:]
    
    func 保存() async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(数据)
        try data.write(to: URL(fileURLWithPath: Self.文件名))
    }
}

// Section 实现
struct 三级指标数据统计分析: PPTSection {
    static var 名称: String { "三级指标数据统计分析" }
    
    static var 依赖项: [数据准备.Type] {
        [三级指标数据库.self, 项目设置.self, 指标导向库.self]
    }
    
    static func 数据准备() async throws {
        // 先准备依赖
        for dep in 依赖项 {
            _ = try await dep.共享实例
        }
        // 再处理自己的数据
        // ...
    }
    
    static func 生成幻灯片(_ 上下文: PPT上下文) async throws {
        // 调用 Node.js 生成 PPT
        try await 上下文.桥接器.执行脚本("addSlide", 参数: [
            "title": 名称,
            "content": "..."
        ])
    }
}

// Report 实现
struct 院科内部分析报告: PPT报告 {
    typealias Section类型 = any PPTSection.Type
    
    static func sections() -> [Section类型] {
        [
            三级指标数据统计分析.self,
            三级指标数据前后各五名列表.self,
            // ...
        ]
    }
    
    static func 生成报告() async throws {
        let 桥接器 = NodeJS桥接器(scriptsPath: URL(fileURLWithPath: "./scripts"))
        
        // 创建 PPT
        _ = try await 桥接器.执行脚本("createPPT", 参数: [:])
        
        // 遍历 sections 生成幻灯片
        for section in sections() {
            try await section.数据准备()
            try await section.生成幻灯片(PPT上下文(桥接器: 桥接器))
        }
        
        // 保存 PPT
        _ = try await 桥接器.执行脚本("savePPT", 参数: [
            "path": "output.pptx"
        ])
    }
}
```

---

## 三、小范围验证方案

### 验证目标

1. Swift 调用 Node.js 子进程的可行性
2. 数据序列化/反序列化的性能
3. POP 架构的基本可行性

### 验证步骤

#### 步骤 1：创建最小化项目结构

```
SwiftOffice/
├── Package.swift
├── Sources/
│   └── SwiftOffice/
│       ├── 核心协议.swift
│       ├── NodeJS桥接.swift
│       └── 测试用例.swift
└── Scripts/
    ├── readExcel.js
    └── writePPTX.js
```

#### 步骤 2：验证 Node.js 子进程调用

```swift
// 测试代码
func testNodeJS调用() async throws {
    let 桥接器 = NodeJS桥接器(scriptsPath: URL(fileURLWithPath: "./Scripts"))
    
    let result = try await 桥接器.执行脚本("test", 参数: [
        "message": "Hello from Swift"
    ])
    
    print(result) // 应该返回 { "echo": "Hello from Swift" }
}
```

```javascript
// Scripts/test.js
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const params = JSON.parse(input);
    console.log(JSON.stringify({ echo: params.message }));
});
```

#### 步骤 3：验证 Excel 读取

```swift
func testExcel读取() async throws {
    let 桥接器 = NodeJS桥接器(scriptsPath: URL(fileURLWithPath: "./Scripts"))
    
    let data = try await 桥接器.执行脚本("readExcel", 参数: [
        "path": "./test.xlsx",
        "sheet": "Sheet1"
    ])
    
    // 验证数据结构
    print(data)
}
```

#### 步骤 4：验证 PPTX 生成

```swift
func testPPTX生成() async throws {
    let 桥接器 = NodeJS桥接器(scriptsPath: URL(fileURLWithPath: "./Scripts"))
    
    // 创建 PPT
    _ = try await 桥接器.执行脚本("createPPT", 参数: [:])
    
    // 添加幻灯片
    _ = try await 桥接器.执行脚本("addSlide", 参数: [
        "title": "测试标题",
        "content": "测试内容"
    ])
    
    // 保存
    _ = try await 桥接器.执行脚本("savePPT", 参数: [
        "path": "./output.pptx"
    ])
}
```

---

## 四、完整架构设计

### 模块划分

```
SwiftOffice/
├── Sources/
│   ├── 核心/
│   │   ├── 协议定义.swift          # POP 核心协议
│   │   ├── 数据模型.swift          # 基础数据结构
│   │   └── 错误处理.swift          # 自定义错误类型
│   │
│   ├── 桥接/
│   │   ├── NodeJS桥接器.swift      # 子进程调用封装
│   │   ├── Excel桥接.swift         # Excel 操作封装
│   │   └── PPTX桥接.swift          # PPTX 操作封装
│   │
│   ├── 数据库/
│   │   ├── JSON数据库.swift        # JSON 文件数据库
│   │   ├── 单例管理.swift          # 单例缓存管理
│   │   └── 依赖调度.swift          # 依赖初始化调度
│   │
│   ├── 统计/
│   │   ├── 基础统计.swift          # 均值、中位数等
│   │   ├── 排序算法.swift          # 各种排序
│   │   └── 图表数据.swift          # 图表数据准备
│   │
│   └── 报告/
│       ├── PPTSection协议.swift    # Section 协议
│       ├── PPTReport协议.swift     # Report 协议
│       └── 预设Section.swift       # 常用 Section 实现
│
├── Scripts/
│   ├── excel/
│   │   ├── readExcel.js            # Excel 读取
│   │   └── writeExcel.js           # Excel 写入
│   │
│   └── pptx/
│       ├── createPPT.js            # 创建 PPT
│       ├── addSlide.js             # 添加幻灯片
│       ├── addChart.js             # 添加图表
│       └── savePPT.js              # 保存 PPT
│
└── Tests/
    ├── 核心测试.swift
    ├── 桥接测试.swift
    └── 集成测试.swift
```

### 依赖关系

```
┌─────────────────────────────────────────────────────────────┐
│                        应用层                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    报告模块                          │   │
│  │  PPTSection协议 ◄── PPTReport协议 ◄── 具体报告      │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   统计模块   │  │   数据库模块 │  │   桥接模块   │         │
│  │ Accelerate  │  │ JSON数据库   │  │ NodeJS桥接   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                          │                                   │
│                          ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    核心模块                          │   │
│  │  协议定义 ◄── 数据模型 ◄── 错误处理                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 五、无法实现的功能

### 1. 自动调度

**CoffeeScript**：
```coffee
@cso: @dataPrepare?()  # 访问时自动触发
```

**Swift 需要显式调用**：
```swift
let data = try await 三级指标数据库.共享实例  // 显式获取
```

### 2. 不着痕迹的程序入口

**CoffeeScript**：
```coffee
@init: @newReport(this)  # 定义时自动执行
```

**Swift 需要显式入口**：
```swift
// main.swift
Task {
    try await 院科内部分析报告.生成报告()
}
```

### 3. Class 作为一等公民

**CoffeeScript**：
```coffee
sections: -> [ClassA, ClassB]  # 直接传递 Class
```

**Swift 需要用 Protocol.Type**：
```swift
static func sections() -> [PPTSection.Type] {
    [ClassA.self, ClassB.self]  // 使用 .self
}
```

---

## 六、下一步行动

### 阶段 1：小范围验证（1-2 天）

1. 创建最小化 SPM 项目
2. 实现 NodeJS桥接器
3. 验证 Excel 读取
4. 验证 PPTX 生成
5. 评估性能和可行性

### 阶段 2：确定方案（半天）

1. 根据验证结果调整方案
2. 编写详细的实现计划文档
3. 确定模块划分和接口设计

### 阶段 3：核心实现（按计划）

1. 实现核心协议层
2. 实现数据库层
3. 实现统计层
4. 实现桥接层
5. 实现报告层

---

## 七、决策点

在开始验证之前，需要确认：

1. **Node.js 路径**：使用系统安装的 Node.js 还是打包嵌入？
2. **脚本位置**：Scripts 目录放在包内还是包外？
3. **数据交换格式**：JSON 还是 MessagePack？
4. **错误处理策略**：抛出异常还是返回 Result？

请确认以上方向，然后开始小范围验证。
