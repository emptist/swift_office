import Foundation

// PPTXGenUtils uses pptxgenjs for PPT generation.
// This is the ONLY supported PPT generator in SwiftOffice.
// The officegen package was evaluated but contains bugs and is NOT used.
// The original CoffeeScript implementation (hqcoffee) also uses pptxgenjs exclusively.
// See: https://github.com/gitbrent/PptxGenJS

open class PPTXGenUtils {
    
    public class func getPPTFilename(_ opts: [String: Any]) -> String {
        var newOpts = opts
        newOpts["gen"] = "pg"
        return JSONDatabase.getPPTFilename(newOpts)
    }
    
    public class func createPPT(_ opts: [String: Any]) {
        guard let generate = opts["generate"] as? ([String: Any]) -> Void else {
            return
        }
        
        var newOpts = opts
        newOpts["pres"] = [:] // placeholder for presentation object
        
        generate(newOpts)
        
        let pptname = getPPTFilename(opts)
        // In real implementation, would save the presentation
        print("Created file: \(pptname)")
    }
}

open class MakePPTReport {
    
    public class func newReport(_ opts: [String: Any]) {
        var newOpts = opts
        if newOpts["generate"] == nil {
            newOpts["generate"] = generate
        }
        PPTXGenUtils.createPPT(newOpts)
    }
    
    public class func generate(_ opts: [String: Any]) {
        guard let json = opts["json"] as? [String: Any],
              let pres = opts["pres"] as? [String: Any] else {
            return
        }
        
        // Title slide
        _ = pres // placeholder
        
        for (key, section) in json {
            var sectionOpts = opts
            sectionOpts["json"] = section
            sectionOpts["sectionTitle"] = key
            
            singleObjectCharts(sectionOpts)
        }
    }
    
    public class func singleObjectCharts(_ opts: [String: Any]) {
        guard let json = opts["json"] as? [String: Any],
              let settings = json["settings"] as? [String: Any],
              let chartType = settings["chartType"] as? String,
              let data = json["data"] as? [String: Any] else {
            return
        }
        
        let unitNameLabel = settings["unitNameLabel"] as? String ?? "科室名"
        
        for (key, obj) in data {
            guard let objDict = obj as? [String: Any] else { continue }
            
            var labels: [String] = []
            var values: [Double] = []
            
            for (k, v) in objDict where k != unitNameLabel {
                let label = k.count < 7 ? k : "\(k.prefix(5))\(k.suffix(1))"
                labels.append(label)
                if let num = v as? Double {
                    values.append(num)
                } else if let num = v as? Int {
                    values.append(Double(num))
                }
            }
            
            // Limit to 12 items
            labels = Array(labels.prefix(12))
            values = Array(values.prefix(12))
            
            let chartData: [String: Any] = [
                "name": key,
                "labels": labels,
                "values": values
            ]
            
            print("Chart: \(chartType), title: \(objDict[unitNameLabel] ?? key)")
            print("Data: \(chartData)")
        }
    }
}
