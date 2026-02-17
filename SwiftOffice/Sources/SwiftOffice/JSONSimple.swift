import Foundation

public class JSONSimple {
    
    public class func getJSONFilename(_ opts: [String: Any]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "data"
        let basename = opts["basename"] as? String ?? ""
        
        if let dir = dirname {
            return "\(dir)/\(basename).json"
        } else {
            return "\(folder)/JSON/\(basename).json"
        }
    }
    
    public class func getExcelFilename(_ opts: [String: Any]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "data"
        let basename = opts["basename"] as? String ?? ""
        let saveAs = opts["saveAs"] as? Bool ?? false
        
        var name = basename
        if saveAs {
            name = "\(basename)_bu"
        }
        
        if let dir = dirname {
            return "\(dir)/\(name).xlsx"
        } else {
            return "\(folder)/Excel/\(name).xlsx"
        }
    }
    
    public class func getPPTFilename(_ opts: [String: Any]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "outputs"
        let basename = opts["basename"] as? String ?? ""
        let gen = opts["gen"] as? String ?? ""
        
        if let dir = dirname {
            return "\(dir)/\(basename).\(gen).pptx"
        } else {
            return "\(folder)/PPT/\(basename).\(gen).pptx"
        }
    }
    
    public class func readFromJSON(_ opts: [String: Any]) -> [String: Any]? {
        guard let filename = opts["jsonfilename"] as? String ?? {
            return getJSONFilename(opts)
        }() as String? else {
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: filename) else {
            return nil
        }
        
        guard let data = FileManager.default.contents(atPath: filename),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    
    public class func write2JSON(_ opts: [String: Any]) {
        guard let obj = opts["obj"] as? [String: Any] else { return }
        
        let filename = getJSONFilename(opts)
        
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return
        }
        
        try? data.write(to: URL(fileURLWithPath: filename))
    }
    
    public class func jsonfileNeedsNoFix(_ opts: [String: Any]) -> (jsonfilename: String, isReady: Bool) {
        let jsonfilename = getJSONFilename(opts)
        let needToRewrite = opts["needToRewrite"] as? Bool ?? false
        
        let isReady = FileManager.default.fileExists(atPath: jsonfilename) && !needToRewrite
        
        return (jsonfilename, isReady)
    }
}
