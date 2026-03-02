import Foundation

// MARK: - Core File Handling Protocol

public protocol FileHandling {
    var dirname: String? { get }
    var basename: String { get }
    var needToRewrite: Bool { get }
    
    func getJSONFilename(folder: String) -> String
    func getExcelFilename(folder: String, saveAs: Bool) -> String
    func getPPTFilename(folder: String, generator: String) -> String
    func readFromJSON(filename: String?) -> [String: Any]?
    func writeToJSON(_ data: [String: Any], filename: String?)
    func jsonfileNeedsNoFix(folder: String) -> (jsonfilename: String, isReady: Bool)
}

public extension FileHandling {
    var needToRewrite: Bool { false }
    
    func getJSONFilename(folder: String = "data") -> String {
        if let dir = dirname {
            return "\(dir)/\(basename).json"
        }
        return "\(folder)/JSON/\(basename).json"
    }
    
    func getExcelFilename(folder: String = "data", saveAs: Bool = false) -> String {
        var name = basename
        if saveAs {
            name = "\(basename)_bu"
        }
        if let dir = dirname {
            return "\(dir)/\(name).xlsx"
        }
        return "\(folder)/Excel/\(name).xlsx"
    }
    
    func getPPTFilename(folder: String = "outputs", generator: String = "") -> String {
        if let dir = dirname {
            return "\(dir)/\(basename).\(generator).pptx"
        }
        return "\(folder)/PPT/\(basename).\(generator).pptx"
    }
    
    func readFromJSON(filename: String? = nil) -> [String: Any]? {
        let file = filename ?? getJSONFilename()
        guard FileManager.default.fileExists(atPath: file),
              let data = FileManager.default.contents(atPath: file),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    func writeToJSON(_ data: [String: Any], filename: String? = nil) {
        let file = filename ?? getJSONFilename()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return
        }
        try? jsonData.write(to: URL(fileURLWithPath: file))
    }
    
    func jsonfileNeedsNoFix(folder: String = "data") -> (jsonfilename: String, isReady: Bool) {
        let jsonfilename = getJSONFilename(folder: folder)
        let isReady = FileManager.default.fileExists(atPath: jsonfilename) && !needToRewrite
        return (jsonfilename, isReady)
    }
}

// MARK: - Database Protocol

public protocol DatabaseProtocol: FileHandling {
    var mainKeyName: String { get }
    var header: [String: Any] { get }
    var columnToKey: [String: String] { get }
    var unwrap: Bool { get }
    
    func requestJSON(key: String?) -> [String: Any]?
    func dbAsArray(dataName: String?, key: String?, except: String?) -> [[String: Any]]
    func dbDictKeys(key: String?) -> [String]
    func dbRevertedValue() -> [String: [String]]
}

public extension DatabaseProtocol {
    var mainKeyName: String { "数据名" }
    var header: [String: Any] { ["rows": 1] }
    var columnToKey: [String: String] { ["*": "{{columnHeader}}"] }
    var unwrap: Bool { false }
    
    func requestJSON(key: String? = nil) -> [String: Any]? {
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
            
            if let dn = dataName {
                if let valueDict = v as? [String: Any] {
                    if let ky = key {
                        if let innerDict = valueDict[dn] as? [String: Any] {
                            obj[dn] = innerDict[ky]
                        }
                    } else {
                        obj[dn] = valueDict[dn]
                    }
                }
            } else {
                if let valueDict = v as? [String: Any] {
                    obj.merge(valueDict) { (_, new) in new }
                }
            }
            arr.append(obj)
        }
        
        return arr
    }
    
    func dbDictKeys(key: String? = nil) -> [String] {
        guard let json = requestJSON(key: key) else { return [] }
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

// MARK: - Singleton Protocol

public protocol SingletonProtocol: DatabaseProtocol {
    static var cache: [String: Any]? { get set }
    
    static func dataPrepare() -> [String: Any]?
    static func fetch(rebuild: Bool) -> [String: Any]?
}

public extension SingletonProtocol {
    static func fetch(rebuild: Bool = false) -> [String: Any]? {
        if rebuild || cache == nil {
            cache = dataPrepare()
        }
        return cache
    }
}

// MARK: - Alias Protocol

public protocol AliasProtocol: SingletonProtocol {
    func addPairs(dict: [String: String], keep: Bool)
    func adjustedName(_ name: String, keep: Bool) -> String?
}

public extension AliasProtocol {
    func addPairs(dict: [String: String], keep: Bool = false) {
        guard var db = Self.cache as? [String: String] else { return }
        
        for (key, value) in dict where key != value {
            db[key] = value
        }
        
        if keep {
            writeToJSON(db, filename: nil)
        }
    }
    
    func adjustedName(_ name: String, keep: Bool = false) -> String? {
        guard let json = Self.fetch(),
              let aliasDict = json[String(describing: Self.self)] as? [String: String] else {
            return name
        }
        
        if let correctName = aliasDict[name] {
            return correctName
        }
        
        let pattern = "[*↑↓()（、）/▲\\s]"
        if name.range(of: pattern, options: .regularExpression) != nil {
            let cleanName = name.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            
            if let correctName = aliasDict[cleanName] {
                return correctName
            }
            
            addPairs(dict: [name: cleanName], keep: keep)
            return cleanName
        }
        
        return name
    }
}

// MARK: - Global Singleton Protocol

public protocol GlobalSingletonProtocol: SingletonProtocol {
    var options: [String: Any] { get }
}

public extension GlobalSingletonProtocol {
    var options: [String: Any] {
        return [
            "dirname": "",
            "basename": String(describing: Self.self),
            "mainKeyName": "数据名",
            "header": ["rows": 1],
            "columnToKey": ["*": "{{columnHeader}}"],
            "sheetStubs": true,
            "needToRewrite": true,
            "unwrap": true,
            "saveAs": true
        ]
    }
}
