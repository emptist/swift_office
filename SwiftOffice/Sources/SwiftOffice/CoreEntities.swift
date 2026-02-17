import Foundation

// MARK: - 基于 static var 的重构版本 (v1.0)

// ========================================
// 核心工具: 文件操作
// ========================================

public enum FileTools {
    public static func getJSONFilename(_ opts: [String: Any]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "data"
        let basename = opts["basename"] as? String ?? ""
        
        if let dir = dirname {
            return "\(dir)/\(basename).json"
        } else {
            return "\(folder)/JSON/\(basename).json"
        }
    }
    
    public static func getExcelFilename(_ opts: [String: Any]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "data"
        let basename = opts["basename"] as? String ?? ""
        
        if let dir = dirname {
            return "\(dir)/\(basename).xlsx"
        } else {
            return "\(folder)/Excel/\(basename).xlsx"
        }
    }
    
    public static func readFromJSON(_ filename: String) -> [String: Any]? {
        guard FileManager.default.fileExists(atPath: filename) else { return nil }
        
        guard let data = FileManager.default.contents(atPath: filename),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    
    public static func write2JSON(_ filename: String, obj: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return
        }
        try? data.write(to: URL(fileURLWithPath: filename))
    }
}

// ========================================
// 数据库实体模式 (static var 版本)
// ========================================

public struct DatabaseEntity {
    public let basename: String
    public let dirname: String?
    
    nonisolated(unsafe) static var _globalDB: [String: Any] = [:]
    
    public init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    public static var db: [String: Any] {
        get { _globalDB }
        set { _globalDB = newValue }
    }
    
    public func jsonFilename() -> String {
        FileTools.getJSONFilename([
            "dirname": dirname as Any,
            "basename": basename
        ])
    }
    
    public func readJSON() -> [String: Any]? {
        FileTools.readFromJSON(jsonFilename())
    }
    
    public func writeJSON(_ obj: [String: Any]) {
        FileTools.write2JSON(jsonFilename(), obj: obj)
    }
}

// ========================================
// 缓存实体模式 (static var + 懒加载)
// ========================================

public struct CachedEntity {
    public let basename: String
    public let dirname: String?
    
    nonisolated(unsafe) static var _cache: [String: [String: Any]] = [:]
    
    public init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    public var cso: [String: Any] {
        let key = "\(dirname ?? "")/\(basename)"
        if Self._cache[key] == nil {
            Self._cache[key] = dataPrepare()
        }
        return Self._cache[key] ?? [:]
    }
    
    public func dataPrepare() -> [String: Any] {
        FileTools.readFromJSON(FileTools.getJSONFilename([
            "dirname": dirname as Any,
            "basename": basename
        ])) ?? [:]
    }
    
    public static func clearCache() {
        _cache = [:]
    }
    
    public func reset() {
        let key = "\(dirname ?? "")/\(basename)"
        Self._cache.removeValue(forKey: key)
    }
}

// ========================================
// 别名实体模式
// ========================================

public struct AliasEntity {
    public let basename: String
    public let dirname: String?
    
    nonisolated(unsafe) static var _cache: [String: [String: Any]] = [:]
    
    public init(dirname: String? = nil, basename: String) {
        self.dirname = dirname
        self.basename = basename
    }
    
    public var cso: [String: Any] {
        let key = "alias:\(basename)"
        if Self._cache[key] == nil {
            Self._cache[key] = dataPrepare()
        }
        return Self._cache[key] ?? [:]
    }
    
    public func dataPrepare() -> [String: Any] {
        FileTools.readFromJSON(FileTools.getJSONFilename([
            "dirname": dirname as Any,
            "basename": basename
        ])) ?? [:]
    }
    
    public func adjustedName(_ name: String) -> String {
        // 先清理特殊字符
        let pattern = "[*↑↓()（、）/▲\\s]"
        var cleanName = name
        if name.range(of: pattern, options: .regularExpression) != nil {
            cleanName = name.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // 查找别名
        guard let aliasDict = cso[basename] as? [String: String] else {
            return cleanName
        }
        
        // 返回别名或清理后的名称
        return aliasDict[cleanName] ?? aliasDict[name] ?? cleanName
    }
    
    public static func clearCache() {
        _cache = [:]
    }
}

// ========================================
// 使用示例
// ========================================

/*
 // 基础使用
 let 项目设置 = CachedEntity(basename: "项目设置")
 let data = 项目设置.cso  // 懒加载
 
 // 别名处理
 let 别名 = AliasEntity(basename: "别名库")
 let correctName = 别名.adjustedName("内科*")  // 返回 "内科"
 
 // 清除缓存
 CachedEntity.clearCache()
 AliasEntity.clearCache()
 */
