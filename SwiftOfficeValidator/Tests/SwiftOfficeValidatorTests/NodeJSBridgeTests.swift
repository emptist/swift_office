import Testing
import Foundation
@testable import SwiftOfficeValidator

@Suite("NodeJS Bridge Tests")
struct NodeJSBridgeTests {
    
    @Test("Find Node path")
    func testFindNodePath() async throws {
        let path = try NodeJSConfig.autoFindNodePath()
        #expect(!path.isEmpty)
        #expect(FileManager.default.isExecutableFile(atPath: path))
        print("✅ Node.js path: \(path)")
    }
    
    @Test("Get Node version")
    func testGetNodeVersion() async throws {
        let version = NodeJSConfig.version
        #expect(version != nil)
        #expect(version!.hasPrefix("v"))
        print("✅ Node.js version: \(version!)")
    }
    
    @Test("Execute test script")
    func testExecuteTestScript() async throws {
        let currentPath = FileManager.default.currentDirectoryPath
        let scriptsPath = "\(currentPath)/Scripts"
        
        let bridge = try NodeJSBridge(
            scriptsPath: scriptsPath,
            debug: DebugOptions(verbose: true, printScriptOutput: true)
        )
        
        let result = try await bridge.executeScript("test", params: [
            "message": "Hello from Swift!"
        ])
        
        #expect(result["echo"] != nil)
        #expect(result["echo"] as? String == "Hello from Swift!")
        print("✅ Test script result: \(result)")
    }
}
