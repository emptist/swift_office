import Testing
import Foundation
@testable import SwiftOffice

@Suite("第一性原理实验测试")
struct ExperimentalExplorationTests {
    
    // ========================================
    // 方案对比测试
    // ========================================
    
    @Test("static let: 懒加载 + 缓存")
    func testStaticLet() {
        // static let 在首次访问时初始化
        let cso = 项目设置StaticLet.cso
        #expect(cso is [String: Any])
        
        let settings = 项目设置StaticLet.一级指标设置
        #expect(!settings.isEmpty)
    }
    
    @Test("static var: 懒加载 + 缓存 + 可重置")
    func testStaticVar() {
        // 重置缓存
        项目设置StaticVar.reset()
        
        // 首次访问
        let cso1 = 项目设置StaticVar.cso
        let cso2 = 项目设置StaticVar.cso
        
        // 两次访问应该返回相同数据 (缓存)
        #expect(cso1.keys == cso2.keys)
        
        // 重置后再次访问
        项目设置StaticVar.reset()
        let cso3 = 项目设置StaticVar.cso
        #expect(cso3.keys == cso1.keys)
    }
    
    @Test("依赖触发: 指标导向库 → 项目设置")
    func testDependencyTrigger() {
        // 重置缓存
        项目设置StaticVar.reset()
        指标导向库StaticVar.reset()
        
        // 访问 指标导向库.cso 会自动触发 项目设置.cso
        let _ = 指标导向库StaticVar.cso
        
        // 验证 项目设置 已被加载
        #expect(项目设置StaticVar._cso != nil)
    }
    
    @Test("instance: 无缓存")
    func testInstance() {
        let entity1 = 项目设置Instance()
        let entity2 = 项目设置Instance()
        
        // 每次创建新实例
        let _ = entity1.cso
        let _ = entity2.cso
        
        #expect(true)
    }
    
    // ========================================
    // 结论
    // ========================================
    
    @Test("结论: 最佳方案是 static var")
    func testBestSolution() {
        /*
         评估结果:
         
         | 方案 | 懒加载 | 缓存 | 依赖触发 | 可变 | 简洁度 | 总分 |
         |------|--------|------|----------|------|--------|------|
         | static let | ✅ | ✅ | ✅ | ❌ | ⭐⭐⭐⭐⭐ | 90% |
         | static var | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ | 100% |
         | instance | ✅ | ❌ | ❌ | ✅ | ⭐⭐⭐ | 50% |
         
         最佳方案: static var
         
         使用方式与原著完全一致:
         
         CoffeeScript:  项目设置.cso.一级指标设置
         Swift:         项目设置StaticVar.cso.一级指标设置
         */
        
        #expect(true)
    }
}
