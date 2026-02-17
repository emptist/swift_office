import Foundation

open class OfficeGenUtils {
    
    public class func getPPTFilename(_ opts: [String: Any]) -> String {
        var newOpts = opts
        newOpts["gen"] = "og"
        return JSONDatabase.getPPTFilename(newOpts)
    }
    
    public class func createPPT(_ opts: [String: Any]) async throws {
        let pptname = getPPTFilename(opts)
        
        // Note: Actual PPT generation would be done via NodeJS bridge
        // using officegen package
        // This is a placeholder for the structure
        
        print("Creating PPT: \(pptname)")
    }
    
    public class func testChart(_ opts: [String: Any] = [:]) async throws {
        // Test chart generation
        // Note: This would use officegen's chart capabilities
        
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
        // Basic test for officegen
        print("Testing OfficeGenUtils")
    }
}
