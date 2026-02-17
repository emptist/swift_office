import Foundation

// MARK: - 深度 Protocol 继承链

// ========================================
// 第一层: 基础文件操作
// ========================================

protocol FileIOProtocol {
    var dirname: String? { get }
    var basename: String { get }
    
    func getJSONFilename() -> String
    func getExcelFilename(saveAs: Bool) -> String
    func getPPTFilename(generator: String) -> String
    func readFromJSON() -> [String: Any]?
    func writeToJSON(_ data: [String: Any])
}

// ========================================
// 第二层: JSON 数据库操作
// ========================================

protocol JSONDatabaseProtocol: FileIOProtocol {
    var mainKeyName: String { get }
    var header: [String: Any] { get }
    var columnToKey: [String: String] { get }
    
    func requestJSON(_ key: String?) -> [String: Any]?
    func dbAsArray(dataName: String?, key: String?, except: String?) -> [[String: Any]]
    func dbDictKeys() -> [String]
    func dbRevertedValue() -> [String: [String]]
}

// ========================================
// 第三层: StormDB 单例
// ========================================

protocol StormDBProtocol: JSONDatabaseProtocol {
    func fetchSingleJSON(rebuild: Bool) -> [String: Any]?
    func reversedJSON() -> [String: [String]]
}

// ========================================
// 第四层: 案例单例
// ========================================

protocol CaseProtocol: StormDBProtocol {
    func normalKeyName(_ mainKey: String) -> String
    func years() -> [String]
    func localUnits() -> [String]
    func focusUnits() -> [String]
}

// ========================================
// 第五层: 标准案例单例
// ========================================

protocol NormalCaseProtocol: CaseProtocol {
    func options() -> [String: Any]
}

// ========================================
// 第六层: PPT 章节基类
// ========================================

protocol PPTSectionProtocol: NormalCaseProtocol {
    func sectionAvailable() -> Bool
    func sectionData() -> [String: Any]?
    func pageLimit() -> Int?
    func pageTitle(_ page: Any) -> String
    func slides(pres: inout [[String: Any]], sectionTitle: String)
}

// ========================================
// 第七层: PPT 章节子类型
// ========================================

protocol TextPPTSectionProtocol: PPTSectionProtocol {
    func textLines(_ page: [String: Any]) -> [[String: Any]]
}

protocol TablePPTSectionProtocol: PPTSectionProtocol {
    var arrayName: String? { get }
    func titles() -> [String]
}

protocol ChartPPTSectionProtocol: PPTSectionProtocol {
    func chartData() -> [String: Any]
}

// MARK: - 默认实现

extension FileIOProtocol {
    func getJSONFilename() -> String {
        if let dir = dirname {
            return "\(dir)/\(basename).json"
        }
        return "data/JSON/\(basename).json"
    }
    
    func getExcelFilename(saveAs: Bool = false) -> String {
        var name = basename
        if saveAs { name = "\(basename)_bu" }
        if let dir = dirname {
            return "\(dir)/\(name).xlsx"
        }
        return "data/Excel/\(name).xlsx"
    }
    
    func getPPTFilename(generator: String = "") -> String {
        if let dir = dirname {
            return "\(dir)/\(basename).\(generator).pptx"
        }
        return "outputs/PPT/\(basename).\(generator).pptx"
    }
    
    func readFromJSON() -> [String: Any]? {
        let file = getJSONFilename()
        guard FileManager.default.fileExists(atPath: file),
              let data = FileManager.default.contents(atPath: file),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    func writeToJSON(_ data: [String: Any]) {
        let file = getJSONFilename()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return
        }
        try? jsonData.write(to: URL(fileURLWithPath: file))
    }
}

extension JSONDatabaseProtocol {
    var mainKeyName: String { "数据名" }
    var header: [String: Any] { ["rows": 1] }
    var columnToKey: [String: String] { ["*": "{{columnHeader}}"] }
    
    func requestJSON(_ key: String? = nil) -> [String: Any]? {
        guard let json = readFromJSON() else { return nil }
        if let k = key {
            return json[k] as? [String: Any]
        }
        return json
    }
    
    func dbAsArray(dataName: String? = nil, key: String? = nil, except: String? = nil) -> [[String: Any]] {
        var arr: [[String: Any]] = []
        guard let json = requestJSON() else { return arr }
        
        for (k, v) in json {
            if let pattern = except, k.range(of: pattern, options: .regularExpression) != nil {
                continue
            }
            
            var obj: [String: Any] = ["unitName": k]
            if let valueDict = v as? [String: Any] {
                if let dn = dataName {
                    if let ky = key {
                        obj[dn] = (valueDict[dn] as? [String: Any])?[ky]
                    } else {
                        obj[dn] = valueDict[dn]
                    }
                } else {
                    obj.merge(valueDict) { (_, new) in new }
                }
            }
            arr.append(obj)
        }
        return arr
    }
    
    func dbDictKeys() -> [String] {
        guard let json = requestJSON() else { return [] }
        return Array(json.keys)
    }
    
    func dbRevertedValue() -> [String: [String]] {
        guard let json = requestJSON() else { return [:] }
        var redict: [String: [String]] = [:]
        for (key, value) in json {
            if let v = value as? String {
                redict[v, default: []].append(key)
            }
        }
        return redict
    }
}

extension StormDBProtocol {
    func fetchSingleJSON(rebuild: Bool = false) -> [String: Any]? {
        // 放弃自动调度，每次都读取
        return readFromJSON()
    }
    
    func reversedJSON() -> [String: [String]] {
        guard let dictionary = fetchSingleJSON(rebuild: false) else { return [:] }
        var redict: [String: [String]] = [:]
        for (key, value) in dictionary {
            if let v = value as? String {
                redict[v, default: []].append(key)
            }
        }
        return redict
    }
}

extension CaseProtocol {
    func normalKeyName(_ mainKey: String) -> String {
        return mainKey
    }
    
    func years() -> [String] {
        return []
    }
    
    func localUnits() -> [String] {
        return []
    }
    
    func focusUnits() -> [String] {
        return []
    }
}

extension NormalCaseProtocol {
    func options() -> [String: Any] {
        return [
            "dirname": dirname ?? "",
            "basename": basename,
            "mainKeyName": mainKeyName,
            "header": header,
            "columnToKey": columnToKey,
            "sheetStubs": true,
            "needToRewrite": true,
            "unwrap": true,
            "saveAs": false
        ]
    }
}

extension PPTSectionProtocol {
    func sectionAvailable() -> Bool { true }
    
    func sectionData() -> [String: Any]? {
        return readFromJSON()
    }
    
    func pageLimit() -> Int? { nil }
    
    func pageTitle(_ page: Any) -> String { "Page Title" }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        // 默认实现
    }
}

extension TextPPTSectionProtocol {
    func textLines(_ page: [String: Any]) -> [[String: Any]] {
        var lines: [[String: Any]] = []
        if let content = page["content"] as? [String: Any] {
            for (key, value) in content {
                lines.append([
                    "text": key,
                    "options": ["fontSize": 14, "bold": true, "breakLine": true]
                ])
                lines.append([
                    "text": "\(value)\n",
                    "options": ["fontSize": 12, "breakLine": true]
                ])
            }
        }
        return lines
    }
    
    func pageTitle(_ page: Any) -> String {
        if let p = page as? [String: Any], let title = p["title"] as? String {
            return title
        }
        return "Page Title"
    }
}

extension TablePPTSectionProtocol {
    var arrayName: String? { nil }
    
    func titles() -> [String] { [] }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        // 表格页面默认实现
    }
}

extension ChartPPTSectionProtocol {
    func chartData() -> [String: Any] { [:] }
}

// MARK: - 具体实现 (Struct)

// 基础文件处理器
struct FileHandler: FileIOProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
}

// 数据库处理器
struct DatabaseHandlerV4: JSONDatabaseProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
}

// 案例处理器
struct CaseHandler: CaseProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
}

// ========================================
// 业务实体 (Struct 实现)
// ========================================

// 项目设置
struct 项目设置V4: NormalCaseProtocol {
    let dirname: String?
    let basename: String = "项目设置"
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    // 模拟原著 @cso: @dataPrepare?()
    // computed var 懒加载效果 (但每次访问都会重新计算)
    var cso: [String: Any]? {
        self.readFromJSON()
    }
    
    // 业务属性 - 通过 cso 访问
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
}

// 指标导向库
struct 指标导向库V4: NormalCaseProtocol {
    let dirname: String?
    let basename: String = "指标导向库"
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    // 模拟 @cso
    var cso: [String: Any]? {
        self.readFromJSON()
    }
}

// 院内资料库
struct 院内资料库V4: CaseProtocol {
    let dirname: String?
    let basename: String = "院内资料库"
    
    init(dirname: String? = nil) {
        self.dirname = dirname
    }
    
    func years() -> [String] {
        guard let json = self.readFromJSON(),
              let first = json.first?.value as? [String: Any] else {
            return []
        }
        return first.keys
            .filter { $0.hasPrefix("Y") }
            .sorted(by: >)
    }
    
    func localUnits() -> [String] {
        return self.dbDictKeys()
    }
}

// ========================================
// PPT 章节实体
// ========================================

// 章节扉页
struct 章节扉页V4: TextPPTSectionProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func pageTitle(_ page: Any) -> String {
        if let p = page as? [String: Any], let name = p["name"] as? String {
            return name.split(separator: "_").first.map(String.init) ?? name
        }
        return "章节扉页"
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "sectionTitle": sectionTitle,
            "text": "\n\n" + pageTitle(sectionTitle),
            "textOptions": ["fontSize": 32, "align": "right"]
        ])
    }
}

// 分节文本页面
struct 分节文本页面V4: TextPPTSectionProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        guard sectionData() != nil else { return }
        
        let pages: [[String: Any]] = []
        // 实现分页逻辑...
        
        for page in pages {
            let lines = textLines(page)
            let lineLimit = 15
            var pstart = 0
            var pend = lineLimit
            
            while lines.count > pstart {
                var slide: [String: Any] = [
                    "sectionTitle": sectionTitle,
                    "title": pageTitle(page)
                ]
                slide["textLines"] = Array(lines[pstart..<min(pend, lines.count)])
                pres.append(slide)
                pstart = pend
                pend += lineLimit
            }
        }
    }
}

// 科室逐项指标排名表
struct 科室逐项指标排名表V4: TablePPTSectionProtocol {
    let dirname: String?
    let basename: String
    
    var arrayName: String? { nil }
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func titles() -> [String] {
        return ["数据名", "前一", "前二", "前三", "前四", "前五", "末五", "末四", "末三", "末二", "末一"]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        guard let data = sectionData() else { return }
        
        // 将数据转换为表格
        var rows: [[String]] = []
        for (indicator, array) in data {
            if let units = array as? [[String: Any]] {
                var row = [indicator]
                for unit in units.prefix(5) {
                    if let name = unit["unitName"] as? String {
                        row.append(name)
                    }
                }
                rows.append(row)
            }
        }
        
        let slide: [String: Any] = [
            "sectionTitle": sectionTitle,
            "title": sectionTitle,
            "table": [
                "headers": titles(),
                "rows": rows
            ]
        ]
        pres.append(slide)
    }
}

// 雷达图报告
struct 雷达图报告V4: ChartPPTSectionProtocol {
    let dirname: String?
    let basename: String
    
    init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    func chartData() -> [String: Any] {
        return [
            "type": "radar",
            "title": "雷达图",
            "data": []
        ]
    }
    
    func slides(pres: inout [[String: Any]], sectionTitle: String) {
        pres.append([
            "sectionTitle": sectionTitle,
            "title": sectionTitle,
            "chart": chartData()
        ])
    }
}

// MARK: - 对比总结

/*
 原著 CoffeeScript (safe 分支):
 
 class 章节扉页 extends TextPPTSection
   @cso: @dataPrepare?()
   @slides: (funcOpts) -> ...
 
 class 分节文本页面 extends 分节自动换页文本页面
   @cso: @dataPrepare?()
   @textLines: (page) -> ...
 
 Swift Protocol + Struct:
 
 struct 章节扉页V4: TextPPTSectionProtocol {
     let dirname: String?
     let basename: String
     
     func slides(...) { ... }
 }
 
 struct 分节文本页面V4: TextPPTSectionProtocol {
     let dirname: String?
     let basename: String
     
     func textLines(...) { ... }
 }
 
 关键差异:
 1. 原著: @cso 自动触发 dataPrepare
    Swift: 需要显式调用 readFromJSON()
 
 2. 原著: class 继承链自动传递
    Swift: Protocol 继承 + 默认实现
 
 3. 原著: 87 个类轻松实现
    Swift: 每个 struct 需要显式声明属性
 
 4. 原著: 动态修改 class 属性
    Swift: struct 不可变，需要 mutating 或 class 包装
 */
