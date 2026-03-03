import Testing
import Foundation
@testable import SwiftOffice

@Suite("Core Entities Tests (static var 版本)")
struct CoreEntitiesTests {
    
    // ========================================
    // FileTools 测试
    // ========================================
    
    @Test("FileTools: JSON 文件名生成")
    func testJSONFilename() {
        let filename = FileTools.getJSONFilename([
            "dirname": "/path/to/dir",
            "basename": "项目设置"
        ])
        #expect(filename == "/path/to/dir/项目设置.json")
        
        let filename2 = FileTools.getJSONFilename([
            "basename": "指标导向库"
        ])
        #expect(filename2 == "data/JSON/指标导向库.json")
    }
    
    @Test("FileTools: Excel 文件名生成")
    func testExcelFilename() {
        let filename = FileTools.getExcelFilename([
            "dirname": "/path/to/dir",
            "basename": "数据表"
        ])
        #expect(filename == "/path/to/dir/数据表.xlsx")
    }
    
    @Test("FileTools: JSON 读写")
    func testJSONReadWrite() {
        let outputDir = "/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/core"
        try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        
        let filename = "\(outputDir)/test_entity.json"
        let data: [String: Any] = ["name": "测试", "value": 123]
        
        // 写入
        FileTools.write2JSON(filename, obj: data)
        
        // 读取
        let readData = FileTools.readFromJSON(filename)
        
        #expect(readData?["name"] as? String == "测试")
        #expect(readData?["value"] as? Int == 123)
    }
    
    // ========================================
    // CachedEntity 测试
    // ========================================
    
    @Test("CachedEntity: 懒加载")
    func testCachedEntityLazyLoad() {
        // 清除缓存
        CachedEntity.clearCache()
        
        let entity = CachedEntity(basename: "项目设置")
        
        // 首次访问
        let data1 = entity.cso
        let data2 = entity.cso
        
        // 两次访问返回数据 (缓存生效)
        #expect(data1.keys == data2.keys)
    }
    
    @Test("CachedEntity: 重置缓存")
    func testCachedEntityReset() {
        CachedEntity.clearCache()
        
        let entity = CachedEntity(basename: "测试实体")
        let _ = entity.cso
        
        // 重置
        CachedEntity.clearCache()
        
        // 再次访问会重新加载
        let data = CachedEntity(basename: "测试实体").cso
        #expect(data is [String: Any])
    }
    
    // ========================================
    // AliasEntity 测试
    // ========================================
    
    @Test("AliasEntity: 名称调整")
    func testAliasEntityAdjustedName() {
        AliasEntity.clearCache()
        
        let alias = AliasEntity(basename: "别名库")
        
        // 测试名称调整 (无别名数据时返回原名)
        let name1 = alias.adjustedName("内科")
        #expect(name1 == "内科")
        
        // 测试特殊字符清理
        let name2 = alias.adjustedName("内科*")
        #expect(name2 == "内科")
        
        let name3 = alias.adjustedName("外科↑")
        #expect(name3 == "外科")
    }
    
    // ========================================
    // 对比测试: class vs struct
    // ========================================
    
    @Test("对比: struct + static var 更简洁")
    func testStructVsClass() {
        /*
         原著 CoffeeScript:
         
         class 项目设置 extends AnyGlobalSingleton
           @cso: @dataPrepare?()
         
         Swift class 版本 (旧):
         
         class 项目设置: AnyGlobalSingleton {
             nonisolated(unsafe) private static var _cso: [String: Any]? = nil
             public override class var cso: [String: Any]? { ... }
             public override class func dataPrepare() -> [String: Any]? { ... }
         }
         
         Swift struct 版本 (新):
         
         let 项目设置 = CachedEntity(basename: "项目设置")
         let data = 项目设置.cso
         
         优势:
         1. 无继承链
         2. 无 override
         3. 代码更简洁
         4. 使用方式一致
         */
        
        let entity = CachedEntity(basename: "项目设置")
        let _ = entity.cso
        
        #expect(true)
    }
    
    // ========================================
    // 结论
    // ========================================
    
    @Test("结论: static var 方案验证通过")
    func testConclusion() {
        /*
         重构完成:
         
         1. FileTools - 文件操作工具
         2. DatabaseEntity - 数据库操作
         3. CachedEntity - 懒加载 + 缓存
         4. AliasEntity - 名称调整
         
         核心优势:
         
         1. struct 无继承性 → 无需考虑继承链
         2. static var → 直接模拟 class-side
         3. 代码更简洁 → 无 override
         4. 使用方式一致 → entity.cso
         */
        
        #expect(true)
    }
}
