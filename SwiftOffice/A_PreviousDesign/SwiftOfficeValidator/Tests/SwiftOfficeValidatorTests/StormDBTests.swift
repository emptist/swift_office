import Testing
import Foundation
@testable import SwiftOfficeValidator

@Suite("StormDB Tests")
struct StormDBTests {
    
    @Test("Initialize database")
    func testInitDatabase() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let dbPath = "\(currentPath)/test_db.json"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let dataJSON = """
        {
            "DRGs组数": 125,
            "settings": {
                "version": "1.0"
            }
        }
        """
        
        let result = try await bridge.executeScript("stormdb", params: [
            "action": "init",
            "dbPath": dbPath,
            "dataJSON": dataJSON
        ])
        
        #expect(result["success"] as? Bool == true)
        print("✅ Database initialized")
        
        if FileManager.default.fileExists(atPath: dbPath) {
            try FileManager.default.removeItem(atPath: dbPath)
        }
    }
    
    @Test("Read and write database")
    func testReadWriteDatabase() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let dbPath = "\(currentPath)/test_rw_db.json"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let initDataJSON = """
        {"别名表": {"DRGs组数": "DRGs组数(组)"}}
        """
        
        let initResult = try await bridge.executeScript("stormdb", params: [
            "action": "init",
            "dbPath": dbPath,
            "dataJSON": initDataJSON
        ])
        #expect(initResult["success"] as? Bool == true)
        
        let getResult = try await bridge.executeScript("stormdb", params: [
            "action": "get",
            "dbPath": dbPath,
            "key": "别名表"
        ])
        #expect(getResult["success"] as? Bool == true)
        print("✅ Read data: \(getResult)")
        
        let setResult = try await bridge.executeScript("stormdb", params: [
            "action": "set",
            "dbPath": dbPath,
            "key": "别名表.DRGs组数",
            "value": "DRGs组数_新"
        ])
        #expect(setResult["success"] as? Bool == true)
        
        let updatedResult = try await bridge.executeScript("stormdb", params: [
            "action": "get",
            "dbPath": dbPath,
            "key": "别名表"
        ])
        print("✅ Updated data: \(updatedResult)")
        
        if FileManager.default.fileExists(atPath: dbPath) {
            try FileManager.default.removeItem(atPath: dbPath)
        }
    }
    
    @Test("Array operations")
    func testArrayOperations() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        let dbPath = "\(currentPath)/test_array_db.json"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let initResult = try await bridge.executeScript("stormdb", params: [
            "action": "init",
            "dbPath": dbPath,
            "dataJSON": "[]"
        ])
        #expect(initResult["success"] as? Bool == true)
        
        let value1JSON = """
        {"name": "内科", "score": 85}
        """
        
        let pushResult1 = try await bridge.executeScript("stormdb", params: [
            "action": "push",
            "dbPath": dbPath,
            "valueJSON": value1JSON
        ])
        #expect(pushResult1["success"] as? Bool == true)
        
        let value2JSON = """
        {"name": "外科", "score": 90}
        """
        
        let pushResult2 = try await bridge.executeScript("stormdb", params: [
            "action": "push",
            "dbPath": dbPath,
            "valueJSON": value2JSON
        ])
        #expect(pushResult2["success"] as? Bool == true)
        
        let getResult = try await bridge.executeScript("stormdb", params: [
            "action": "get",
            "dbPath": dbPath
        ])
        print("✅ Array data: \(getResult)")
        
        if FileManager.default.fileExists(atPath: dbPath) {
            try FileManager.default.removeItem(atPath: dbPath)
        }
    }
}
