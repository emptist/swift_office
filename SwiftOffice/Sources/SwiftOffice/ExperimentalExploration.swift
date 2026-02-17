import Foundation

// MARK: - 第一性原理探索实验 (简化版)

// ========================================
// 核心发现: static var 最接近原著
// ========================================

/*
 原著 CoffeeScript:
 
 class 项目设置
   @cso: @dataPrepare?()
   
   @dataPrepare: ->
     @sdb = @setDB({thisClass: this})
     @requestJSON()
 
 使用: 项目设置.cso.一级指标设置
 
 Swift 最佳方案:
 
 struct 项目设置 {
     nonisolated(unsafe) static var _cso: [String: Any]?
     
     static var cso: [String: Any] {
         if _cso == nil { _cso = dataPrepare() }
         return _cso!
     }
     
     static func dataPrepare() -> [String: Any] { ... }
 }
 
 使用: 项目设置.cso.一级指标设置  // 完全一致！
 */

// ========================================
// 方案 1: static let (最简洁，不可变)
// ========================================

struct 项目设置StaticLet {
    nonisolated(unsafe) static let cso: [String: Any] = {
        print("懒加载 项目设置 (static let)")
        return ["一级指标设置": ["安全": ["权重": 0.3]]]
    }()
    
    static var 一级指标设置: [String: [String: Any]] {
        (cso["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
}

// ========================================
// 方案 2: static var (可变，最接近原著)
// ========================================

struct 项目设置StaticVar {
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any] {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso!
    }
    
    static func dataPrepare() -> [String: Any] {
        print("dataPrepare 被调用 (static var)")
        return ["一级指标设置": ["安全": ["权重": 0.3]]]
    }
    
    static var 一级指标设置: [String: [String: Any]] {
        (cso["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    static func reset() {
        _cso = nil
    }
}

// ========================================
// 方案 3: 依赖自动触发
// ========================================

struct 指标导向库StaticVar {
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any] {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso!
    }
    
    static func dataPrepare() -> [String: Any] {
        print("指标导向库.dataPrepare 被调用")
        // 访问 项目设置.cso 会自动触发其 dataPrepare
        let settings = 项目设置StaticVar.cso
        print("依赖 项目设置 已就绪: \(settings.keys)")
        return ["指标导向": "高优"]
    }
    
    static func reset() {
        _cso = nil
    }
}

// ========================================
// 方案 4: 实例版本 (Protocol + Struct)
// ========================================

protocol DataEntity {
    var basename: String { get }
    func dataPrepare() -> [String: Any]
}

extension DataEntity {
    func dataPrepare() -> [String: Any] {
        return [:]
    }
}

struct 项目设置Instance: DataEntity {
    let basename: String = "项目设置"
    
    var cso: [String: Any] {
        dataPrepare()
    }
    
    var 一级指标设置: [String: [String: Any]] {
        (cso["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
}

// ========================================
// 对比总结
// ========================================

/*
 | 方案 | 懒加载 | 缓存 | 依赖触发 | 可变 | 简洁度 | 总分 |
 |------|--------|------|----------|------|--------|------|
 | static let | ✅ | ✅ | ✅ | ❌ | ⭐⭐⭐⭐⭐ | 90% |
 | static var | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ | 100% |
 | instance | ✅ | ❌ | ❌ | ✅ | ⭐⭐⭐ | 50% |
 
 最佳方案: static var
 
 原因:
 1. 使用方式与原著完全一致: 项目设置.cso
 2. 支持懒加载和缓存
 3. 支持依赖自动触发
 4. 可以重新加载数据 (reset)
 5. 代码最简洁
 */
