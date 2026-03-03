import Foundation

open class JSONDatabase: JSONSimple {
    
    nonisolated(unsafe) static var _sdb: [String: Any] = [:]
    
    public class var sdb: [String: Any] {
        get { _sdb }
        set { _sdb = newValue }
    }
    
    public class func dbfilenm(_ classname: String) -> String {
        return "\(classname).json"
    }
    
    public class func setDB(_ opts: [String: Any]) -> [String: Any] {
        guard let thisClass = opts["thisClass"] as? String else {
            fatalError("thisClass is missing")
        }
        let preserved = opts["preserved"] as? Bool ?? false
        
        var db: [String: Any] = [:]
        if !preserved {
            db[thisClass] = [:]
        }
        _sdb = db
        return _sdb
    }
    
    public class func db(_ opts: [String: Any] = [:]) -> [String: Any] {
        if let thisClass = opts["thisClass"] as? String {
            return (_sdb[thisClass] as? [String: Any]) ?? [:]
        }
        return _sdb
    }
    
    public class func requestJSON(_ key: String? = nil) -> [String: Any]? {
        let json = jsonObject()
        if let k = key {
            return json?[k] as? [String: Any]
        }
        return json
    }
    
    public class func jsonObject() -> [String: Any]? {
        return readFromJSON(["jsonfilename": dbfilenm(String(describing: self))])
    }
    
    public class func dbAsArray(_ opts: [String: Any] = [:]) -> [[String: Any]] {
        var arr: [[String: Any]] = []
        guard let json = requestJSON() else { return arr }
        
        let dataName = opts["dataName"] as? String
        let key = opts["key"] as? String
        let except = opts["except"] as? String
        
        for (k, v) in json {
            if let pattern = except, k.range(of: pattern, options: .regularExpression) != nil {
                continue
            }
            
            var obj: [String: Any] = [:]
            obj["unitName"] = k
            
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
    
    public class func dbDictKeys(_ opts: [String: Any] = [:]) -> [String] {
        guard let _ = opts["thisClass"] as? String,
              let json = requestJSON(opts["key"] as? String) else {
            return []
        }
        return Array(json.keys)
    }
    
    public class func dbRevertedValue(_ opts: [String: Any] = [:]) -> [String: [String]] {
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
