import Foundation

// MARK: - 完整翻译原著继承结构

// ========================================
// 原著继承链分析
// ========================================

/*
 原著 CoffeeScript 继承链:
 
 StormDBSingleton
      ↓
 AnyCaseSingleton
      ↓
 CaseSingleton
      ↓
 NormalCaseSingleton
      ↓
 ├── 项目设置
 ├── 指标名称和体系
 │      ↓
 │    指标导向库
 │    三级指标对应二级指标基础
 │           ↓
 │        三级指标对应二级指标
 │        三级院级指标对应二级指标
 │        三级科级指标对应二级指标
 │
 └── LogSystem
        ↓
     MistakeChasingLog
     MissingDataFuncLog
     MissingDataRegister
 
 Swift Protocol 组合方案:
 
 不需要深层继承链，直接组合所需能力
 */

// ========================================
// 能力型 Protocol (可自由组合)
// ========================================

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
    func readableName(_ unitName: String) -> String
    func simpleName(_ unitName: String) -> String
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

// ========================================
// 默认实现
// ========================================

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

extension UnitCapable {
    func localUnits() -> [String] {
        ["医院", "总体估值"]
    }
    
    func focusUnits() -> [String] {
        ["医院", "总体估值", "均1", "均2"]
    }
}

extension AliasCapable {
    func readableName(_ unitName: String) -> String {
        unitName.split(separator: "_").reversed().joined()
    }
    
    func simpleName(_ unitName: String) -> String {
        unitName.replacingOccurrences(of: "[*↑↓()（、）/▲\\s]", with: "", options: .regularExpression)
    }
}

extension IndicatorCapable {
    func 二级指标表(full: Bool = false) -> [String] {
        return full ? ["质量安全", "功能定位", "合理用药"] : ["安全", "功能", "用药"]
    }
    
    func shortIndicatorName(_ name: String) -> String {
        return name
    }
}

extension LogCapable {
    func log(_ message: String) {
        print("[LOG] \(message)")
    }
    
    func error(_ message: String) {
        print("[ERROR] \(message)")
    }
}

// ========================================
// 基础实体 (组合多种能力)
// ========================================

// StormDBSingleton 翻译
struct StormDBSingletonV4: DatabaseCapable, CacheCapable {
    let dirname: String?
    let basename: String
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] {
        return [:]
    }
    
    func requestJSON() -> [String: Any]? {
        return nil
    }
}

// AnyCaseSingleton 翻译
struct AnyCaseSingletonV4: DatabaseCapable, CacheCapable, LogCapable {
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

// CaseSingleton 翻译 (组合 5 种能力)
struct CaseSingletonV4: DatabaseCapable, CacheCapable, YearCapable, UnitCapable, AliasCapable, IndicatorCapable {
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

// NormalCaseSingleton 翻译
struct NormalCaseSingletonV4: DatabaseCapable, CacheCapable, YearCapable, UnitCapable, AliasCapable, IndicatorCapable {
    let dirname: String?
    let basename: String
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func options() -> [String: Any] {
        return [
            "dirname": dirname ?? "",
            "basename": basename,
            "mainKeyName": "数据名",
            "header": ["rows": 1],
            "columnToKey": ["*": "{{columnHeader}}"]
        ]
    }
}

// ========================================
// 业务实体 (直接组合所需能力)
// ========================================

// 项目设置 (原著: extends NormalCaseSingleton)
struct 项目设置V4Full: DatabaseCapable, CacheCapable, YearCapable, UnitCapable, AliasCapable, IndicatorCapable {
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
    
    var 三级指标设置: [String: [String: Any]] {
        (cso?["三级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    var 科室设置: [String: [String: Any]] {
        (cso?["科室设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    // 项目信息
    var isHospital: Bool {
        (cso?["项目信息"] as? [String: Any])?["isHospital"] as? Bool ?? true
    }
    
    var customerName: String {
        (cso?["项目信息"] as? [String: Any])?["customerName"] as? String ?? ""
    }
    
    var finalYear: Int {
        (cso?["项目信息"] as? [String: Any])?["finalYear"] as? Int ?? 2021
    }
}

// 指标导向库 (原著: extends 指标名称和体系 extends NormalCaseSingleton)
struct 指标导向库V4Full: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "指标导向库"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 导向指标集
    func 导向指标集() -> [String: [String]] {
        var result: [String: [String]] = [:]
        guard let data = cso else { return result }
        for (指标, 导向) in data {
            if let 导向Str = 导向 as? String {
                if result[导向Str] == nil {
                    result[导向Str] = []
                }
                result[导向Str]?.append(指标)
            }
        }
        return result
    }
}

// 三级指标对应二级指标 (原著: extends 三级指标对应二级指标基础 extends 指标名称和体系)
struct 三级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "三级指标对应二级指标"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 矢量指标
    func vectors() -> [String: [String]] {
        let result: [String: [String]] = [:]
        // 实现逻辑
        return result
    }
}

// 三级院级指标对应二级指标 (特化版本)
struct 三级院级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "三级院级指标对应二级指标"
    var cachedData: [String: Any]?
    let scope: String = "院级"  // 特化
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
}

// 三级科级指标对应二级指标 (特化版本)
struct 三级科级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "三级科级指标对应二级指标"
    var cachedData: [String: Any]?
    let scope: String = "科级"  // 特化
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
}

// ========================================
// 日志系统 (组合日志能力)
// ========================================

// LogSystem 翻译
struct LogSystemV4: DatabaseCapable, CacheCapable, LogCapable {
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

// MistakeChasingLog 翻译
struct MistakeChasingLogV4: DatabaseCapable, CacheCapable, LogCapable {
    let dirname: String?
    let basename: String = "MistakeChasingLog"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func errorChasingDB() -> [String: Any]? {
        return cachedData
    }
    
    mutating func errorChasingDBClear() {
        cachedData = nil
    }
}

// MissingDataFuncLog 翻译
struct MissingDataFuncLogV4: DatabaseCapable, CacheCapable, LogCapable {
    let dirname: String?
    let basename: String = "MissingDataFuncLog"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
}

// MissingDataRegister 翻译
struct MissingDataRegisterV4: DatabaseCapable, CacheCapable, LogCapable {
    let dirname: String?
    let basename: String = "MissingDataRegister"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
}

// MARK: - 对比总结

/*
 原著 CoffeeScript 深层继承:
 
 StormDBSingleton → AnyCaseSingleton → CaseSingleton → NormalCaseSingleton
                                                                    ↓
                                                              项目设置
                                                              指标名称和体系
                                                                    ↓
                                                              指标导向库
                                                              三级指标对应二级指标基础
                                                                    ↓
                                                              三级指标对应二级指标
                                                              三级院级指标对应二级指标
                                                              三级科级指标对应二级指标
 
 问题:
 1. 继承链过长，难以理解
 2. 中间类只是为了传递能力
 3. 无法灵活组合能力
 
 Swift Protocol 组合:
 
 项目设置V4Full: DatabaseCapable, CacheCapable, YearCapable, UnitCapable, AliasCapable, IndicatorCapable
 指标导向库V4Full: DatabaseCapable, CacheCapable, IndicatorCapable
 三级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable
 三级院级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable { scope = "院级" }
 三级科级指标对应二级指标V4Full: DatabaseCapable, CacheCapable, IndicatorCapable { scope = "科级" }
 
 优势:
 1. 扁平化，无深层继承
 2. 能力自由组合
 3. 特化通过属性实现
 4. 类型安全
 */
