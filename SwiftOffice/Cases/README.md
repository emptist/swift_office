# Cases - 项目案例文件夹

每个项目一个文件夹，以客户名项目名加年份命名。

## 文件夹结构

```
Cases/
├── goodhospital2021/          # 开发平台和模板程序
│   ├── Self.swift             # 项目分析制作程序
│   ├── ContentTexts.swift     # 报告内容文本模板
│   ├── 项目设置.xlsx          # 项目配置文件 (Stage 1)
│   ├── 院内资料库.xlsx        # 本院数据原始报表 (Stage 2)
│   └── 对标资料库.xlsx        # 对标数据原始报表 (Stage 2)
└── README.md
```

## 数据文件说明

### Stage 1: 数据分析服务准备
- **项目设置.xlsx**: 项目配置信息，包括指标体系、科室设置、项目信息等

### Stage 2: 数据分析服务实施
- **院内资料库.xlsx**: 本院各科室/部门的历史数据
- **对标资料库.xlsx**: 对标医院/科室的参考数据

## Swift 文件说明

### Self.swift
项目分析制作程序，对应 CoffeeScript 的 `self.coffee`。

**核心模式:**
```swift
// 使用 static var 实现懒加载 + 缓存
public struct 项目设置: CaseSingletonProtocol {
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
}
```

### ContentTexts.swift
报告内容文本模板，对应 CoffeeScript 的 `contentTexts.coffee`。

包含各类报告章节的文本内容模板。

## CoffeeScript → Swift 翻译对照

| CoffeeScript | Swift |
|--------------|-------|
| `@cso: @dataPrepare?()` | `static var cso` + 懒加载 |
| `class 项目设置 extends StormDBSingleton` | `struct 项目设置: CaseSingletonProtocol` |
| 类继承链 | 协议组合 |
| 动态类型 | `[String: Any]` 字典 |

## 使用方法

```swift
// 加载项目数据
let context = CaseContext.shared
context.loadAllData()

// 访问项目设置
let customerName = 项目设置.customerName
let finalYear = 项目设置.finalYear

// 生成报告
let report = try ReportGenerator.generateHospitalReport()
```

## 注意事项

- 文件名、Sheet名、列标签、章节标题等大量使用中文
- 实现代码即注释，资料名即结构名
- 分解JSON为报告各要素的证据以及debug的依据
