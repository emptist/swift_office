import Foundation

// MARK: - Case Singleton Base (translates CoffeeScript's StormDBSingleton pattern)

public protocol CaseSingletonProtocol {
    static var cso: [String: Any] { get }
    static func dataPrepare() -> [String: Any]
    static func clearCache()
}

public extension CaseSingletonProtocol {
    static func clearCache() {}
}

// MARK: - 项目设置 (Project Settings)

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
    
    public static func dataPrepare() -> [String: Any] {
        let entity = CachedEntity(basename: "项目设置")
        var obj = entity.cso
        
        if let 项目信息 = obj["项目信息"] as? [String: Any] {
            resetInfo(项目信息)
        }
        
        return obj
    }
    
    public static func resetInfo(_ info: [String: Any]) {
        // These would update global settings
        // In Swift, we'd use a settings manager or environment
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
    
    public static var isHospital: Bool {
        (cso["项目信息"] as? [String: Any])?["isHospital"] as? [String: Any]?["数据资料"] as? Bool ?? true
    }
    
    public static var finalYear: Int {
        (cso["项目信息"] as? [String: Any])?["finalYear"] as? [String: Any]?["数据资料"] as? Int ?? 2021
    }
    
    public static var customerName: String {
        (cso["项目信息"] as? [String: Any])?["customerName"] as? [String: Any]?["数据资料"] as? String ?? "Good Hospital"
    }
}

// MARK: - 院内资料库 (Internal Hospital Database)

public struct 院内资料库: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        let entity = CachedEntity(basename: "院内资料库")
        return entity.cso
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
    
    public static func years() -> [String] {
        let finalYear = 项目设置.finalYear
        return [
            "Y\(finalYear)",
            "Y\(finalYear - 1)",
            "Y\(finalYear - 2)"
        ]
    }
    
    public static func localUnits() -> [String] {
        Array(cso.keys)
    }
}

// MARK: - 对标资料库 (Benchmark Database)

public struct 对标资料库: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        let entity = CachedEntity(basename: "对标资料库")
        return entity.cso
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
    
    public static func dbDictKeys() -> [String] {
        Array(cso.keys)
    }
}

// MARK: - 指标导向库 (Indicator Direction Library)

public struct 指标导向库: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        var result: [String: Any] = [:]
        if let 三级指标设置 = 项目设置.cso["三级指标设置"] as? [String: Any] {
            for (key, obj) in 三级指标设置 {
                if let indicator = obj as? [String: Any],
                   let direction = indicator["指标导向"] as? String {
                    result[key] = direction
                }
            }
        }
        return result
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
    
    public static func 导向指标集() -> [String: [String]] {
        var result: [String: [String]] = [:]
        for (key, value) in cso {
            if let direction = value as? String {
                result[direction, default: []].append(key)
            }
        }
        return result
    }
}

// MARK: - 三级指标对应二级指标 (Level 3 to Level 2 Mapping)

public struct 三级指标对应二级指标: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        var result: [String: Any] = [:]
        if let 三级指标设置 = 项目设置.cso["三级指标设置"] as? [String: Any] {
            for (key, obj) in 三级指标设置 {
                if let indicator = obj as? [String: Any],
                   let 上级指标 = indicator["上级指标"] as? String {
                    result[key] = 上级指标
                }
            }
        }
        return result
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
}

// MARK: - 二级指标对应三级指标 (Level 2 to Level 3 Mapping)

public struct 二级指标对应三级指标: CaseSingletonProtocol {
    
    nonisolated(unsafe) static var _cso: [String: Any] = [:]
    nonisolated(unsafe) static var _isLoaded: Bool = false
    
    public static var cso: [String: Any] {
        if !_isLoaded {
            _cso = dataPrepare()
            _isLoaded = true
        }
        return _cso
    }
    
    public static func dataPrepare() -> [String: Any] {
        var result: [String: [String]] = [:]
        for (三级指标, 二级指标) in 三级指标对应二级指标.cso {
            if let 二级 = 二级指标 as? String {
                result[二级, default: []].append(三级指标)
            }
        }
        return result
    }
    
    public static func clearCache() {
        _cso = [:]
        _isLoaded = false
    }
}

// MARK: - Case Context (Holds all case-specific data)

public struct CaseContext {
    public let dirname: String
    
    nonisolated(unsafe) static var _shared: CaseContext?
    
    public static var shared: CaseContext {
        if _shared == nil {
            _shared = CaseContext(dirname: "")
        }
        return _shared!
    }
    
    public init(dirname: String) {
        self.dirname = dirname
    }
    
    public func loadAllData() {
        _ = 项目设置.cso
        _ = 院内资料库.cso
        _ = 对标资料库.cso
        _ = 指标导向库.cso
        _ = 三级指标对应二级指标.cso
        _ = 二级指标对应三级指标.cso
    }
    
    public static func clearAllCache() {
        项目设置.clearCache()
        院内资料库.clearCache()
        对标资料库.clearCache()
        指标导向库.clearCache()
        三级指标对应二级指标.clearCache()
        二级指标对应三级指标.clearCache()
    }
}

// MARK: - Report Generator

public struct ReportGenerator {
    
    public static func generateHospitalReport() throws -> [String: Any] {
        let context = CaseContext.shared
        context.loadAllData()
        
        var sections: [[String: Any]] = []
        
        sections.append(contentsOf: ContentTexts.医疗机构量化评价介绍sectionData())
        sections.append(contentsOf: ContentTexts.reviewAndTarget(项目信息: 项目设置.cso["项目信息"] as? [String: Any] ?? [:]))
        sections.append(contentsOf: ContentTexts.suggests())
        
        return [
            "customerName": 项目设置.customerName,
            "finalYear": 项目设置.finalYear,
            "sections": sections
        ]
    }
}

// MARK: - Stage 1: Data Collection Excel Generator

public struct Stage1Generator {
    
    @available(macOS 10.15, *)
    public static func generate项目指标填报表(outputPath: String) async throws -> String {
        let json = 项目设置.cso
        
        let sheets: [ExcelSheet] = [
            make一级指标Sheet(json: json),
            make二级指标Sheet(json: json),
            make三级指标Sheet(json: json),
            make科室设置Sheet(json: json)
        ]
        
        let fileName = outputPath.replacingOccurrences(of: ".xlsx", with: "")
        return try await SwiftOffice.writeExcelSheets(fileName: fileName, sheets: sheets)
    }
    
    private static func make一级指标Sheet(json: [String: Any]) -> ExcelSheet {
        var content: [[String: Any]] = []
        if let 一级指标设置 = json["一级指标设置"] as? [String: [String: Any]] {
            for (key, value) in 一级指标设置 {
                content.append([
                    "数据名": key,
                    "权重": value["权重"] ?? 0,
                    "序号": value["序号"] ?? 0
                ])
            }
            content.sort { ($0["权重"] as? Double ?? 0) > ($1["权重"] as? Double ?? 0) }
        }
        
        return ExcelSheet(
            sheet: "一级指标设置",
            columns: [
                ExcelColumn(label: "数据名", value: "数据名"),
                ExcelColumn(label: "权重", value: "权重"),
                ExcelColumn(label: "序号", value: "序号")
            ],
            content: content
        )
    }
    
    private static func make二级指标Sheet(json: [String: Any]) -> ExcelSheet {
        var content: [[String: Any]] = []
        if let 二级指标设置 = json["二级指标设置"] as? [String: [String: Any]] {
            for (key, value) in 二级指标设置 {
                content.append([
                    "数据名": key,
                    "权重": value["权重"] ?? 0,
                    "序号": value["序号"] ?? 0,
                    "上级指标": value["上级指标"] ?? ""
                ])
            }
            content.sort { ($0["上级指标"] as? String ?? "") > ($1["上级指标"] as? String ?? "") }
        }
        
        return ExcelSheet(
            sheet: "二级指标设置",
            columns: [
                ExcelColumn(label: "数据名", value: "数据名"),
                ExcelColumn(label: "权重", value: "权重"),
                ExcelColumn(label: "序号", value: "序号"),
                ExcelColumn(label: "上级指标", value: "上级指标")
            ],
            content: content
        )
    }
    
    private static func make三级指标Sheet(json: [String: Any]) -> ExcelSheet {
        var content: [[String: Any]] = []
        if let 三级指标设置 = json["三级指标设置"] as? [String: [String: Any]] {
            for (key, value) in 三级指标设置 {
                content.append([
                    "数据名": key,
                    "权重": value["权重"] ?? 0,
                    "序号": value["序号"] ?? 0,
                    "上级指标": value["上级指标"] ?? "",
                    "院科通": value["院科通"] ?? "",
                    "指或数": value["指或数"] ?? "",
                    "指标导向": value["指标导向"] ?? "",
                    "计量单位": value["计量单位"] ?? "",
                    "指标来源": value["指标来源"] ?? "",
                    "三级中医": value["三级中医"] ?? "",
                    "三级综合": value["三级综合"] ?? "",
                    "二级综合": value["二级综合"] ?? "",
                    "指标说明": value["指标说明"] ?? ""
                ])
            }
            content.sort { ($0["上级指标"] as? String ?? "") > ($1["上级指标"] as? String ?? "") }
        }
        
        return ExcelSheet(
            sheet: "三级指标设置",
            columns: [
                ExcelColumn(label: "数据名", value: "数据名"),
                ExcelColumn(label: "权重", value: "权重"),
                ExcelColumn(label: "序号", value: "序号"),
                ExcelColumn(label: "上级指标", value: "上级指标"),
                ExcelColumn(label: "院科通", value: "院科通"),
                ExcelColumn(label: "指或数", value: "指或数"),
                ExcelColumn(label: "指标导向", value: "指标导向"),
                ExcelColumn(label: "计量单位", value: "计量单位"),
                ExcelColumn(label: "指标来源", value: "指标来源"),
                ExcelColumn(label: "三级中医", value: "三级中医"),
                ExcelColumn(label: "三级综合", value: "三级综合"),
                ExcelColumn(label: "二级综合", value: "二级综合"),
                ExcelColumn(label: "指标说明", value: "指标说明")
            ],
            content: content
        )
    }
    
    private static func make科室设置Sheet(json: [String: Any]) -> ExcelSheet {
        var content: [[String: Any]] = []
        if let 科室设置 = json["科室设置"] as? [String: [String: Any]] {
            for (key, value) in 科室设置 {
                content.append([
                    "数据名": key,
                    "内外全": value["内外全"] ?? "",
                    "序号": value["序号"] ?? 0
                ])
            }
            content.sort { ($0["内外全"] as? String ?? "") > ($1["内外全"] as? String ?? "") }
        }
        
        return ExcelSheet(
            sheet: "科室设置",
            columns: [
                ExcelColumn(label: "数据名", value: "数据名"),
                ExcelColumn(label: "内外全", value: "内外全"),
                ExcelColumn(label: "序号", value: "序号")
            ],
            content: content
        )
    }
    
    @available(macOS 10.15, *)
    public static func generate项目对标资料表(outputPath: String) async throws -> String {
        let json = 项目设置.cso
        
        var content: [[String: Any]] = []
        if let 三级指标设置 = json["三级指标设置"] as? [String: [String: Any]] {
            for (key, _) in 三级指标设置 {
                content.append([
                    "数据名": key,
                    "单位": "",
                    "Y2021": "",
                    "Y2020": "",
                    "Y2019": ""
                ])
            }
        }
        
        let sheet = ExcelSheet(
            sheet: "对标数据",
            columns: [
                ExcelColumn(label: "数据名", value: "数据名"),
                ExcelColumn(label: "单位", value: "单位"),
                ExcelColumn(label: "Y2021", value: "Y2021"),
                ExcelColumn(label: "Y2020", value: "Y2020"),
                ExcelColumn(label: "Y2019", value: "Y2019")
            ],
            content: content
        )
        
        let fileName = outputPath.replacingOccurrences(of: ".xlsx", with: "")
        return try await SwiftOffice.writeExcelSheets(fileName: fileName, sheets: [sheet])
    }
    
    @available(macOS 10.15, *)
    public static func generateAllStage1Products(outputDir: String) async throws -> [String] {
        var generatedFiles: [String] = []
        
        let 项目指标填报表Path = "\(outputDir)/项目指标填报表"
        let file1 = try await generate项目指标填报表(outputPath: 项目指标填报表Path + ".xlsx")
        generatedFiles.append(file1)
        
        let 项目对标资料表Path = "\(outputDir)/项目对标资料表"
        let file2 = try await generate项目对标资料表(outputPath: 项目对标资料表Path + ".xlsx")
        generatedFiles.append(file2)
        
        return generatedFiles
    }
}
