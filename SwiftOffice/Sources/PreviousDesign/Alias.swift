import Foundation

open class Alias: AnyGlobalSingleton {
    
    public override class func setDB(_ opts: [String: Any]) -> [String: Any] {
        var newOpts = opts
        newOpts["preserved"] = requestJSON() != nil
        return super.setDB(newOpts)
    }
    
    public class func addPairs(_ opts: [String: Any] = [:]) {
        guard let dict = opts["dict"] as? [String: String] else { return }
        let keep = opts["keep"] as? Bool ?? false
        
        _ = fetchSingleJSON()
        
        for (key, value) in dict where key != value {
            if var db = JSONDatabase._sdb[String(describing: self)] as? [String: Any] {
                db[key] = value
                JSONDatabase._sdb[String(describing: self)] = db
            }
        }
        
        if keep {
            // save to file
        }
    }
    
    public class func ajustedName(_ opts: [String: Any] = [:]) -> String? {
        guard let name = opts["name"] as? String else { return nil }
        let keep = opts["keep"] as? Bool ?? false
        
        guard let json = fetchSingleJSON(),
              let aliasDict = json[String(describing: self)] as? [String: String] else {
            return name
        }
        
        if let correctName = aliasDict[name] {
            return correctName
        }
        
        // Check for special characters
        let pattern = "[*↑↓()（、）/▲\\s]"
        if name.range(of: pattern, options: .regularExpression) != nil {
            let cleanName = name.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            
            if let correctName = aliasDict[cleanName] {
                return correctName
            }
            
            addPairs(["dict": [name: cleanName], "keep": keep])
            return cleanName
        }
        
        return name
    }
    
    public override class func normalKeyName(_ opts: [String: Any]) -> String {
        return opts["mainKey"] as? String ?? ""
    }
    
    public override class func options() -> [String: Any] {
        var opts = super.options()
        opts["needToRewrite"] = true
        opts["rebuild"] = false
        return opts
    }
    
    public override class func fetchSingleJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let rebuild = opts["rebuild"] as? Bool ?? false
        var options = self.options()
        options["needToRewrite"] = false
        
        if rebuild {
            StormDBSingleton._json = getJSON(options)
        } else {
            if StormDBSingleton._json == nil {
                StormDBSingleton._json = getJSON(options)
            }
        }
        
        return StormDBSingleton._json
    }
    
    public class func saveExcel(_ opts: [String: Any] = [:]) {
        // Save to Excel format
    }
}
