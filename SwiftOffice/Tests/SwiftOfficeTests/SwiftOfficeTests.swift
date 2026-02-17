import Testing
import Foundation
@testable import SwiftOffice

@Suite("JSONSimple Tests")
struct JSONSimpleTests {
    
    @Test("getJSONFilename returns correct path")
    func testGetJSONFilename() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile"
        ]
        let result = JSONSimple.getJSONFilename(opts)
        #expect(result == "/test/path/testfile.json")
    }
    
    @Test("getJSONFilename uses default folder")
    func testGetJSONFilenameDefault() {
        let opts: [String: Any] = [
            "basename": "testfile"
        ]
        let result = JSONSimple.getJSONFilename(opts)
        #expect(result.contains("testfile.json"))
    }
    
    @Test("getExcelFilename returns correct path")
    func testGetExcelFilename() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile"
        ]
        let result = JSONSimple.getExcelFilename(opts)
        #expect(result == "/test/path/testfile.xlsx")
    }
    
    @Test("getExcelFilename handles saveAs option")
    func testGetExcelFilenameSaveAs() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile",
            "saveAs": true
        ]
        let result = JSONSimple.getExcelFilename(opts)
        #expect(result == "/test/path/testfile_bu.xlsx")
    }
    
    @Test("getPPTFilename returns correct path")
    func testGetPPTFilename() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile",
            "gen": "pg"
        ]
        let result = JSONSimple.getPPTFilename(opts)
        #expect(result == "/test/path/testfile.pg.pptx")
    }
}

@Suite("JSONDatabase Tests")
struct JSONDatabaseTests {
    
    @Test("setDB initializes database")
    func testSetDB() {
        let opts: [String: Any] = ["thisClass": "TestClass"]
        let result = JSONDatabase.setDB(opts)
        #expect(result["TestClass"] != nil)
    }
    
    @Test("db returns correct value")
    func testDB() {
        _ = JSONDatabase.setDB(["thisClass": "TestClass"])
        let result = JSONDatabase.db(["thisClass": "TestClass"])
        #expect(result is [String: Any])
    }
}

@Suite("StormDBSingleton Tests")
struct StormDBSingletonTests {
    
    @Test("options returns correct configuration")
    func testOptions() {
        let opts = StormDBSingleton.options()
        #expect(opts["mainKeyName"] as? String == "数据名")
        #expect(opts["unwrap"] as? Bool == true)
    }
    
    @Test("normalKeyName returns mainKey")
    func testNormalKeyName() {
        let opts: [String: Any] = ["mainKey": "testKey"]
        let result = StormDBSingleton.normalKeyName(opts)
        #expect(result == "testKey")
    }
}

@Suite("Singletons Tests")
struct SingletonsTests {
    
    @Test("别名库 has correct name")
    func testAliasLibraryName() {
        let name = String(describing: 别名库.self)
        #expect(name == "别名库")
    }
    
    @Test("名字ID库 has correct name")
    func testNameIDLibraryName() {
        let name = String(describing: 名字ID库.self)
        #expect(name == "名字ID库")
    }
    
    @Test("简称库 has correct name")
    func testShortNameLibraryName() {
        let name = String(describing: 简称库.self)
        #expect(name == "简称库")
    }
    
    @Test("自制别名库 has correct name")
    func testCustomAliasLibraryName() {
        let name = String(describing: 自制别名库.self)
        #expect(name == "自制别名库")
    }
}

@Suite("PPTXGenUtils Tests")
struct PPTXGenUtilsTests {
    
    @Test("getPPTFilename uses pg generator")
    func testGetPPTFilename() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile"
        ]
        let result = PPTXGenUtils.getPPTFilename(opts)
        #expect(result == "/test/path/testfile.pg.pptx")
    }
}

@Suite("OfficeGenUtils Tests")
struct OfficeGenUtilsTests {
    
    @Test("getPPTFilename uses og generator")
    func testGetPPTFilename() {
        let opts: [String: Any] = [
            "dirname": "/test/path",
            "basename": "testfile"
        ]
        let result = OfficeGenUtils.getPPTFilename(opts)
        #expect(result == "/test/path/testfile.og.pptx")
    }
}

@Suite("NodeJSConfig Tests")
struct NodeJSConfigTests {
    
    @Test("autoFindNodePath finds node")
    func testAutoFindNodePath() throws {
        let path = try NodeJSConfig.autoFindNodePath()
        #expect(!path.isEmpty)
        #expect(path.contains("node"))
    }
    
    @Test("version returns version string")
    func testVersion() {
        if let version = NodeJSConfig.version {
            #expect(version.hasPrefix("v"))
        }
    }
}

@Suite("SwiftOfficeError Tests")
struct SwiftOfficeErrorTests {
    
    @Test("nodeNotFound description is correct")
    func testNodeNotFoundError() {
        let error = SwiftOfficeError.nodeNotFound(searchPaths: ["/path1", "/path2"])
        let desc = error.description
        #expect(desc.contains("Node.js not found"))
        #expect(desc.contains("/path1"))
    }
    
    @Test("scriptNotFound description is correct")
    func testScriptNotFoundError() {
        let error = SwiftOfficeError.scriptNotFound(path: "/test/script.js")
        let desc = error.description
        #expect(desc.contains("Script not found"))
        #expect(desc.contains("/test/script.js"))
    }
    
    @Test("timeout description is correct")
    func testTimeoutError() {
        let error = SwiftOfficeError.timeout(script: "test.js", seconds: 30.0)
        let desc = error.description
        #expect(desc.contains("Script timeout"))
        #expect(desc.contains("test.js"))
        #expect(desc.contains("30"))
    }
}
