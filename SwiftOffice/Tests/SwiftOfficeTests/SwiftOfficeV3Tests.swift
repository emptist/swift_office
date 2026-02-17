import Testing
import Foundation
@testable import SwiftOffice

@Suite("SwiftOffice API Tests")
struct SwiftOfficeAPITests {
    
    @Test("SingletonCache stores and retrieves values")
    func testSingletonCache() {
        let cache = SingletonCache.shared
        
        let loaded = cache.get(for: "test_key") {
            return "test_value"
        }
        
        #expect(loaded == "test_value")
        
        cache.clear("test_key")
    }
    
    @Test("SingletonCache clears all values")
    func testSingletonCacheClearAll() {
        let cache = SingletonCache.shared
        
        cache.set("value1", for: "key1")
        cache.set("value2", for: "key2")
        
        cache.clear()
        
        let loaded = cache.get(for: "key1") { return "new_value" }
        #expect(loaded == "new_value")
    }
}

@Suite("Refined Entities Tests")
struct RefinedEntitiesTests {
    
    @Test("别名库V3 has correct basename")
    func testAliasLibraryV3Basename() {
        #expect(别名库V3.shared.basename == "别名库")
    }
    
    @Test("名字ID库V3 has correct basename")
    func testNameIDLibraryV3Basename() {
        #expect(名字ID库V3.shared.basename == "名字ID库")
    }
    
    @Test("简称库V3 has correct basename")
    func testShortNameLibraryV3Basename() {
        #expect(简称库V3.shared.basename == "简称库")
    }
    
    @Test("自制别名库V3 has correct basename")
    func testCustomAliasLibraryV3Basename() {
        #expect(自制别名库V3.shared.basename == "自制别名库")
    }
    
    @Test("实体基类 generates correct JSON filename")
    func testEntityBaseClassJSONFilename() {
        let entity = 实体基类(dirname: "/test", basename: "testfile")
        #expect(entity.getJSONFilename() == "/test/testfile.json")
    }
    
    @Test("实体基类 generates correct Excel filename")
    func testEntityBaseClassExcelFilename() {
        let entity = 实体基类(dirname: "/test", basename: "testfile")
        #expect(entity.getExcelFilename() == "/test/testfile.xlsx")
    }
    
    @Test("实体基类 generates correct PPT filename")
    func testEntityBaseClassPPTFilename() {
        let entity = 实体基类(dirname: "/test", basename: "testfile")
        #expect(entity.getPPTFilename(generator: "pg") == "/test/testfile.pg.pptx")
    }
}

@Suite("Protocol Conformance Tests")
struct ProtocolConformanceTests {
    
    @Test("别名库V3 conforms to AliasProtocol")
    func testAliasProtocolConformance() {
        let entity = 别名库V3.shared
        
        // Test that the protocol methods are available
        let _ = entity.basename
        let _ = entity.dirname
        let _ = entity.needToRewrite
    }
    
    @Test("名字ID库V3 conforms to GlobalSingletonProtocol")
    func testGlobalSingletonProtocolConformance() {
        let entity = 名字ID库V3.shared
        
        // Test options property from GlobalSingletonProtocol
        let opts = entity.options
        #expect(opts["mainKeyName"] as? String == "数据名")
    }
}

@Suite("Integration Tests")
struct IntegrationTests {
    
    @Test("SwiftOffice provides entity access")
    func testSwiftOfficeEntityAccess() {
        let aliasLib = SwiftOffice.别名库
        #expect(aliasLib.basename == "别名库")
        
        let nameIDLib = SwiftOffice.名字ID库
        #expect(nameIDLib.basename == "名字ID库")
        
        let shortNameLib = SwiftOffice.简称库
        #expect(shortNameLib.basename == "简称库")
        
        let customAliasLib = SwiftOffice.自制别名库
        #expect(customAliasLib.basename == "自制别名库")
    }
    
    @Test("SwiftOffice provides database access")
    func testSwiftOfficeDatabaseAccess() {
        let db = SwiftOffice.database
        #expect(db is DatabaseHandler)
    }
    
    @Test("PPTGenerator has correct values")
    func testPPTGeneratorValues() {
        #expect(PPTGenerator.pptxgen.rawValue == "pg")
        #expect(PPTGenerator.officegen.rawValue == "og")
    }
}

@Suite("Backward Compatibility Tests")
struct BackwardCompatibilityTests {
    
    @Test("v1 classes still work")
    func testV1ClassesStillWork() {
        // Test that v1 classes are still accessible
        let _ = 别名库.self
        let _ = 名字ID库.self
        let _ = 简称库.self
        let _ = 自制别名库.self
    }
    
    @Test("v2 handlers still work")
    func testV2HandlersStillWork() {
        let handler = JSONSimpleHandler(basename: "test")
        #expect(handler.basename == "test")
    }
    
    @Test("v2 entities still work")
    func testV2EntitiesStillWork() {
        let entity = 别名库实体.shared
        #expect(entity.basename == "别名库")
    }
}
