import Foundation

open class JSONSimple {
    
    public class func getJSON(_ opts: [String: Any]) -> [String: Any]? {
        let (jsonfilename, isReady) = jsonfileNeedsNoFix(opts)
        if isReady {
            return readFromJSON(["jsonfilename": jsonfilename])
        } else {
            return jsonizedExcelData(opts)
        }
    }
    
    public class func jsonizedExcelData(_ opts: [String: Any]) -> [String: Any] {
        var options = opts
        if options["sourceFile"] == nil {
            options["sourceFile"] = getExcelFilename(opts)
        }
        
        guard let sourceFile = options["sourceFile"] as? String,
              FileManager.default.fileExists(atPath: sourceFile) else {
            return [:]
        }
        
        if options["header"] == nil {
            options["header"] = ["rows": opts["headerRows"] ?? 1]
        }
        if options["columnToKey"] == nil {
            options["columnToKey"] = ["*": "{{columnHeader}}"]
        }
        
        do {
            let obj = try readFromExcel(options)
            options["obj"] = obj
            write2JSON(options)
            return obj
        } catch {
            print("Error reading Excel: \(error)")
            return [:]
        }
    }
    
    public class func readFromExcel(_ opts: [String: Any]) throws -> [String: Any] {
        guard let sourceFile = opts["sourceFile"] as? String else {
            return [:]
        }
        
        let mainKeyName = opts["mainKeyName"] as? String
        let unwrap = opts["unwrap"] as? Bool ?? false
        let renaming = opts["renaming"] as? (([String: Any]) -> String)
        
        var result: [String: Any] = [:]
        
        // Note: Actual Excel reading would be done via NodeJS bridge
        // This is a placeholder for the structure
        // The real implementation would call readExcel.js script
        
        return result
    }
    
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
        let outfolder = opts["outfolder"] as? String
        let basename = opts["basename"] as? String ?? ""
        let basenameOnly = opts["basenameOnly"] as? Bool ?? false
        let saveAs = opts["saveAs"] as? Bool ?? false
        
        var name = basename
        if saveAs {
            name = "\(basename)_bu"
        }
        
        let fd = outfolder ?? folder
        
        if let dir = dirname {
            return basenameOnly ? "\(dir)/\(name)" : "\(dir)/\(name).xlsx"
        } else {
            return "\(fd)/Excel/\(name).xlsx"
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
        let filename: String
        if let jsonfilename = opts["jsonfilename"] as? String {
            filename = jsonfilename
        } else {
            filename = getJSONFilename(opts)
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
        
        let (jsonfilename, isReady) = jsonfileNeedsNoFix(opts)
        
        guard !isReady else { return }
        
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return
        }
        
        try? data.write(to: URL(fileURLWithPath: jsonfilename))
    }
    
    public class func write2Excel(_ opts: [String: Any]) {
        let (_, isReady) = jsonfileNeedsNoFix(opts)
        
        guard !isReady else { return }
        
        guard let _ = opts["data"] as? [[String: Any]],
              let _ = opts["settings"] as? [String: Any] else {
            return
        }
        
        var options = opts
        options["basenameOnly"] = true
        if options["outfolder"] == nil {
            options["outfolder"] = "outputs"
        }
        
        let filename = getExcelFilename(options)
        // Note: Actual Excel writing would be done via NodeJS bridge
        // This is a placeholder for the structure
        print("Would write Excel to: \(filename)")
    }
    
    public class func jsonfileNeedsNoFix(_ opts: [String: Any]) -> (jsonfilename: String, isReady: Bool) {
        let jsonfilename = getJSONFilename(opts)
        let needToRewrite = opts["needToRewrite"] as? Bool ?? false
        
        let isReady = FileManager.default.fileExists(atPath: jsonfilename) && !needToRewrite
        
        if isReady {
            print("Already have file: \(jsonfilename)")
        }
        
        return (jsonfilename, isReady)
    }
}
