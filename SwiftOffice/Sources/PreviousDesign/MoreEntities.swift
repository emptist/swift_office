import Foundation

// MARK: - 更多业务实体翻译

// ========================================
// 指标体系相关实体
// ========================================

// 一级指标对应二级指标
struct 一级指标对应二级指标V4: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "一级指标对应二级指标"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
}

// 一级指标对应三级指标
struct 一级指标对应三级指标V4: DatabaseCapable, CacheCapable, IndicatorCapable {
    let dirname: String?
    let basename: String = "一级指标对应三级指标"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
}

// 一二三级指标体系 (组合多种能力)
struct 一二三级指标体系V4: DatabaseCapable, CacheCapable, IndicatorCapable, YearCapable {
    let dirname: String?
    let basename: String = "一二三级指标体系"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 一级指标列表
    func 一级指标() -> [String] {
        guard let data = cso else { return [] }
        return data.keys.map { $0 }
    }
    
    // 二级指标列表
    func 二级指标(一级: String) -> [String] {
        guard let data = cso?[一级] as? [String: Any] else { return [] }
        return data.keys.map { $0 }
    }
    
    // 三级指标列表
    func 三级指标(一级: String, 二级: String) -> [String] {
        guard let level1 = cso?[一级] as? [String: Any],
              let level2 = level1[二级] as? [String] else { return [] }
        return level2
    }
}

// 一二三级院级指标体系 (特化)
struct 一二三级院级指标体系V4: DatabaseCapable, CacheCapable, IndicatorCapable, YearCapable {
    let dirname: String?
    let basename: String = "一二三级院级指标体系"
    var cachedData: [String: Any]?
    let scope: String = "院级"
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    func 一级指标() -> [String] {
        guard let data = cso else { return [] }
        return data.keys.map { $0 }
    }
}

// 一二三级科级指标体系 (特化)
struct 一二三级科级指标体系V4: DatabaseCapable, CacheCapable, IndicatorCapable, YearCapable {
    let dirname: String?
    let basename: String = "一二三级科级指标体系"
    var cachedData: [String: Any]?
    let scope: String = "科级"
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    func 一级指标() -> [String] {
        guard let data = cso else { return [] }
        return data.keys.map { $0 }
    }
}

// ========================================
// 项目资料表相关实体
// ========================================

// Excel 写入能力
protocol ExcelWritable {
    func write2Excel(_ opts: [String: Any])
    func saveExcel(opts: [String: Any])
}

extension ExcelWritable {
    func write2Excel(_ opts: [String: Any]) {
        // 默认实现
    }
    
    func saveExcel(opts: [String: Any]) {
        write2Excel(opts)
    }
}

// 项目内外资料表 (组合 Excel 写入能力)
struct 项目内外资料表V4: DatabaseCapable, CacheCapable, IndicatorCapable, ExcelWritable {
    let dirname: String?
    let basename: String
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
    
    // 生成 Excel 数据
    func generateExcelData() -> [[String: Any]] {
        var sheets: [[String: Any]] = []
        
        // 医院数据
        sheets.append([
            "sheet": "医院",
            "columns": [
                ["label": "数据名", "value": "数据名"],
                ["label": "计量单位", "value": "计量单位"]
            ],
            "content": []
        ])
        
        return sheets
    }
}

// 项目指标填报表 (特化)
struct 项目指标填报表V4: DatabaseCapable, CacheCapable, IndicatorCapable, ExcelWritable {
    let dirname: String?
    let basename: String = "项目指标填报表"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    // 初始化即保存
    static func initSave() {
        let table = 项目指标填报表V4()
        table.saveExcel(opts: [:])
    }
}

// 项目对标资料表 (特化)
struct 项目对标资料表V4: DatabaseCapable, CacheCapable, IndicatorCapable, ExcelWritable {
    let dirname: String?
    let basename: String = "项目对标资料表"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    static func initSave() {
        let table = 项目对标资料表V4()
        table.saveExcel(opts: [:])
    }
}

// ========================================
// 数据名称相关实体
// ========================================

// 二级数据名称对应一级指标名称
struct 二级数据名称对应一级指标名称V4: DatabaseCapable, CacheCapable {
    let dirname: String?
    let basename: String = "二级数据名称对应一级指标名称"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
}

// 一级指标名称对应二级数据名称
struct 一级指标名称对应二级数据名称V4: DatabaseCapable, CacheCapable {
    let dirname: String?
    let basename: String = "一级指标名称对应二级数据名称"
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    var cso: [String: Any]? {
        cachedData ?? requestJSON()
    }
}

// ========================================
// PPT 章节相关实体
// ========================================

// PPT 章节能力
protocol PPTSectionCapable {
    func slides(pres: inout [[String: Any]], sectionTitle: String)
    func sectionData() -> [String: Any]?
}

// 章节扉页
struct 章节扉页V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable {
    let dirname: String?
    let basename: String
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "section",
            "title": sectionTitle
        ])
    }
}

// 分节文本页面
struct 分节文本页面V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable {
    let dirname: String?
    let basename: String
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "text",
            "title": sectionTitle,
            "content": "文本内容"
        ])
    }
}

// 排序报告 (组合图表能力)
struct 排序报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, Sortable {
    let dirname: String?
    let basename: String
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar"]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "chart",
            "title": sectionTitle,
            "chartType": "bar"
        ])
    }
}

// 原值排序报告 (特化)
struct 原值排序报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, Sortable {
    let dirname: String?
    let basename: String
    let showValue: Bool = true
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar", "showValue": showValue]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "chart",
            "title": sectionTitle,
            "chartType": "bar",
            "showValue": showValue
        ])
    }
}

// 内部原值排序报告 (特化 showValue = false)
struct 内部原值排序报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, Sortable {
    let dirname: String?
    let basename: String
    let showValue: Bool = false  // 特化
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func generateChartData() -> [String: Any] {
        return ["type": "bar", "showValue": showValue]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "chart",
            "title": sectionTitle,
            "chartType": "bar",
            "showValue": showValue
        ])
    }
}

// 雷达图报告
struct 雷达图报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable {
    let dirname: String?
    let basename: String
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func generateChartData() -> [String: Any] {
        return ["type": "radar"]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "chart",
            "title": sectionTitle,
            "chartType": "radar"
        ])
    }
}

// 多科雷达图报告 (组合更多能力)
struct 多科雷达图报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, AliasCapable {
    let dirname: String?
    let basename: String
    
    var cachedData: [String: Any]?
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func setDB() -> [String: Any] { return [:] }
    func requestJSON() -> [String: Any]? { return nil }
    
    func sectionData() -> [String: Any]? { return nil }
    
    func generateChartData() -> [String: Any] {
        return ["type": "radar", "multiDept": true]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "type": "chart",
            "title": sectionTitle,
            "chartType": "radar",
            "multiDept": true
        ])
    }
    
    // 实现 AliasCapable
    func adjustedName(_ name: String) -> String {
        return name.replacingOccurrences(of: "[*↑↓()（、）/▲\\s]", with: "", options: .regularExpression)
    }
    
    // 对比两个指标
    func compareIndicators(_ ind1: String, _ ind2: String) -> [String: Any] {
        return [
            "indicator1": adjustedName(ind1),
            "indicator2": adjustedName(ind2)
        ]
    }
}

// MARK: - 对比总结

/*
 原著 CoffeeScript 继承链:
 
 ChartPPTSection
      ↓
 排序报告
      ↓
 原值排序报告
      ↓
 内部原值排序报告 (@showValue: false)
 
 ChartPPTSection
      ↓
 雷达图报告
      ↓
 多科雷达图报告
 
 Swift Protocol 组合:
 
 排序报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, Sortable
 原值排序报告V4Full: ... { showValue = true }
 内部原值排序报告V4Full: ... { showValue = false }
 
 雷达图报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable
 多科雷达图报告V4Full: ..., AliasCapable { func compareIndicators(...) }
 
 优势:
 1. 多科雷达图报告可以额外组合 AliasCapable，不受单继承限制
 2. 特化通过属性实现，不需要子类
 3. 可以添加额外方法
 */
