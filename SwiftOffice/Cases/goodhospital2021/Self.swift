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
