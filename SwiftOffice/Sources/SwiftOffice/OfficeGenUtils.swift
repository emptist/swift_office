import Foundation

// DEPRECATED: officegen package contains bugs and is NOT used.
// Only pptxgenjs is supported for PPT generation.
// See PPTXGenUtils.swift and SwiftOfficeAPI.swift for the active implementation.
// This file is kept for reference only.

@available(*, deprecated, message: "officegen contains bugs. Use PPTXGenUtils with pptxgenjs instead.")
open class OfficeGenUtils {
    
    public class func getPPTFilename(_ opts: [String: Any]) -> String {
        var newOpts = opts
        newOpts["gen"] = "og"
        return JSONDatabase.getPPTFilename(newOpts)
    }
    
    public class func createPPT(_ opts: [String: Any]) async throws {
        let pptname = getPPTFilename(opts)
        
        print("WARNING: OfficeGenUtils is deprecated. Use PPTXGenUtils instead.")
        print("Creating PPT: \(pptname)")
    }
    
    public class func testChart(_ opts: [String: Any] = [:]) async throws {
        print("WARNING: OfficeGenUtils is deprecated. Use PPTXGenUtils instead.")
        
        let chartData: [[String: Any]] = [
            [
                "name": "Income",
                "labels": ["2005", "2006", "2007", "2008", "2009"],
                "values": [23.5, 26.2, 30.1, 29.5, 24.6]
            ]
        ]
        
        print("Test chart data: \(chartData)")
    }
    
    public class func test(_ opts: [String: Any] = [:]) async throws {
        print("WARNING: OfficeGenUtils is deprecated. Use PPTXGenUtils instead.")
    }
}
