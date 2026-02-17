import Foundation

// MARK: - 多重 Protocol 优势展示

// ========================================
// 功能性 Protocol (可组合)
// ========================================

// 数据读取能力
protocol DataReadable {
    func readFromJSON() -> [String: Any]?
}

// 数据写入能力
protocol DataWritable {
    func writeToJSON(_ data: [String: Any])
}

// 缓存能力
protocol Cacheable {
    var cachedData: [String: Any]? { get set }
    mutating func clearCache()
}

// 别名处理能力
protocol AliasProcessable {
    func adjustedName(_ name: String) -> String
}

// 排序能力
protocol Sortable {
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]]
}

// 图表生成能力
protocol ChartGeneratable {
    func generateChartData() -> [String: Any]
}

// 表格生成能力
protocol TableGeneratable {
    func generateTableData() -> [[String]]
}

// ========================================
// 默认实现
// ========================================

extension Cacheable {
    mutating func clearCache() {
        cachedData = nil
    }
}

extension Sortable {
    func sortedData(by key: String, ascending: Bool = false) -> [[String: Any]] {
        // 默认实现
        return []
    }
}

// ========================================
// 组合示例 1: 可读可写可缓存
// ========================================

struct 项目设置V4Plus: DataReadable, DataWritable, Cacheable, AliasProcessable {
    let dirname: String?
    let basename: String = "项目设置"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    // DataReadable
    func readFromJSON() -> [String: Any]? {
        let file = dirname ?? "" + "/\(basename).json"
        guard FileManager.default.fileExists(atPath: file),
              let data = FileManager.default.contents(atPath: file),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    // DataWritable
    func writeToJSON(_ data: [String: Any]) {
        let file = dirname ?? "" + "/\(basename).json"
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return
        }
        try? jsonData.write(to: URL(fileURLWithPath: file))
    }
    
    // AliasProcessable
    func adjustedName(_ name: String) -> String {
        return name.replacingOccurrences(of: "[*↑↓()（、）/▲\\s]", with: "", options: .regularExpression)
    }
    
    // 带缓存的数据访问
    mutating func getData() -> [String: Any]? {
        if cachedData == nil {
            cachedData = readFromJSON()
        }
        return cachedData
    }
}

// ========================================
// 组合示例 2: 可排序可图表
// ========================================

struct 排序报告V4: Sortable, ChartGeneratable, DataReadable {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func readFromJSON() -> [String: Any]? {
        return nil
    }
    
    func sortedData(by key: String, ascending: Bool = false) -> [[String: Any]] {
        guard let json = readFromJSON() else { return [] }
        var arr: [[String: Any]] = []
        for (k, v) in json {
            var obj: [String: Any] = ["unitName": k]
            if let valueDict = v as? [String: Any] {
                obj.merge(valueDict) { (_, new) in new }
            }
            arr.append(obj)
        }
        return arr.sorted { a, b in
            guard let va = a[key] as? Double, let vb = b[key] as? Double else { return false }
            return ascending ? va < vb : va > vb
        }
    }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar", "data": sortedData(by: "value", ascending: false)]
    }
}

// ========================================
// 组合示例 3: 原值排序报告 (继承 + 组合)
// ========================================

// 原著: class 原值排序报告 extends 排序报告
// Swift: 可以组合多个能力

struct 原值排序报告V4: Sortable, ChartGeneratable, DataReadable, TableGeneratable {
    let dirname: String?
    let basename: String
    let showValue: Bool = true
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func readFromJSON() -> [String: Any]? { return nil }
    
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]] {
        // 原值排序逻辑
        return []
    }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar", "showValue": showValue]
    }
    
    func generateTableData() -> [[String]] {
        let data = sortedData(by: "value", ascending: false)
        return data.map { [$0["unitName"] as? String ?? "", "\($0["value"] ?? 0)"] }
    }
}

// ========================================
// 组合示例 4: 内部原值排序报告 (特化)
// ========================================

// 原著: class 内部原值排序报告 extends 原值排序报告
//       @showValue: false

struct 内部原值排序报告V4: Sortable, ChartGeneratable, DataReadable, TableGeneratable {
    let dirname: String?
    let basename: String
    let showValue: Bool = false  // 特化: 不显示值
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func readFromJSON() -> [String: Any]? { return nil }
    
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]] { return [] }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar", "showValue": showValue]  // showValue = false
    }
    
    func generateTableData() -> [[String]] { return [] }
}

// ========================================
// 组合示例 5: 雷达图报告 (多能力组合)
// ========================================

// 原著: class 雷达图报告 extends ChartPPTSection
// Swift: 可以组合 ChartGeneratable + DataReadable + Sortable

struct 雷达图报告V4Plus: ChartGeneratable, DataReadable, Sortable {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func readFromJSON() -> [String: Any]? { return nil }
    
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]] { return [] }
    
    func generateChartData() -> [String: Any] {
        return [
            "type": "radar",
            "title": basename,
            "categories": ["质量安全", "功能定位", "合理用药", "服务流程", "医保价值"],
            "values": [85, 78, 92, 88, 75]
        ]
    }
}

// ========================================
// 组合示例 6: 多科雷达图报告 (更复杂组合)
// ========================================

// 原著: class 多科雷达图报告 extends 雷达图报告
// Swift: 组合更多能力

struct 多科雷达图报告V4: ChartGeneratable, DataReadable, Sortable, AliasProcessable {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func readFromJSON() -> [String: Any]? { return nil }
    
    func sortedData(by key: String, ascending: Bool) -> [[String: Any]] { return [] }
    
    func adjustedName(_ name: String) -> String {
        return name.replacingOccurrences(of: "_", with: "")
    }
    
    func generateChartData() -> [String: Any] {
        // 多科室雷达图逻辑
        return ["type": "radar", "multiDept": true]
    }
    
    // 额外方法: 对比两个指标
    func compareIndicators(_ ind1: String, _ ind2: String) -> [String: Any] {
        return [
            "indicator1": adjustedName(ind1),
            "indicator2": adjustedName(ind2),
            "chartData": generateChartData()
        ]
    }
}

// MARK: - 对比总结

/*
 原著 CoffeeScript 单继承:
 
 class 排序报告 extends ChartPPTSection
 class 原值排序报告 extends 排序报告
 class 内部原值排序报告 extends 原值排序报告
   @showValue: false
 
 class 雷达图报告 extends ChartPPTSection
 class 多科雷达图报告 extends 雷达图报告
 
 问题:
 1. 只能单继承
 2. 想要组合功能需要创建新的继承链
 3. 代码重复
 
 Swift 多重 Protocol:
 
 struct 排序报告V4: Sortable, ChartGeneratable, DataReadable
 struct 原值排序报告V4: Sortable, ChartGeneratable, DataReadable, TableGeneratable
 struct 内部原值排序报告V4: Sortable, ChartGeneratable, DataReadable, TableGeneratable {
     let showValue: Bool = false  // 特化
 }
 
 struct 雷达图报告V4Plus: ChartGeneratable, DataReadable, Sortable
 struct 多科雷达图报告V4: ChartGeneratable, DataReadable, Sortable, AliasProcessable {
     func compareIndicators(...)  // 额外功能
 }
 
 优势:
 1. 可以组合多个能力
 2. 不需要创建深层继承链
 3. 功能可复用
 4. 类型安全
 */
