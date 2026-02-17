import Testing
import Foundation
@testable import SwiftOfficeValidator

@Suite("Excel Reader Tests")
struct ExcelReaderTests {
    
    @Test("Read hqcoffee Excel file")
    func testReadExcel() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let excelPath = "/Users/jk/gits/hub/prog_langs/swift/hqcoffee/previous/评价指标体系_国考.xlsx"
        
        let result = try await bridge.executeScript("readExcel", params: [
            "path": excelPath
        ])
        
        #expect(result["success"] as? Bool == true)
        #expect(result["data"] != nil)
        
        print("✅ Excel read success")
        if let data = result["data"] {
            print("✅ Data type: \(type(of: data))")
        }
    }
}
