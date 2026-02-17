import Foundation

open class StormDBSingleton: JSONDatabase {
    
    nonisolated(unsafe) static var _json: [String: Any]? = nil
    
    public class var jsonObjectCache: [String: Any]? {
        get { _json }
        set { _json = newValue }
    }
    
    public class func fetchSingleJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let rebuild = opts["rebuild"] as? Bool ?? false
        
        if rebuild {
            var options = self.options()
            options["needToRewrite"] = true
            _json = getJSON(options)
        } else {
            if _json == nil {
                _json = getJSON(self.options())
            }
        }
        
        return _json
    }
    
    public class func reversedJSON() -> [String: [String]] {
        guard let dictionary = fetchSingleJSON() else { return [:] }
        
        var redict: [String: [String]] = [:]
        for (key, value) in dictionary {
            if let v = value as? String {
                redict[v, default: []].append(key)
            }
        }
        return redict
    }
    
    public class func options() -> [String: Any] {
        return [
            "dirname": "",
            "basename": String(describing: self),
            "mainKeyName": "数据名",
            "header": ["rows": 1],
            "columnToKey": ["*": "{{columnHeader}}"],
            "sheetStubs": true,
            "needToRewrite": true,
            "unwrap": true,
            "saveAs": true,
            "renaming": normalKeyName
        ]
    }
    
    public class func normalKeyName(_ opts: [String: Any]) -> String {
        return opts["mainKey"] as? String ?? ""
    }
    
    public class func getJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let (jsonfilename, isReady) = jsonfileNeedsNoFix(opts)
        
        if isReady {
            return readFromJSON(["jsonfilename": jsonfilename])
        }
        
        return [:]
    }
}
