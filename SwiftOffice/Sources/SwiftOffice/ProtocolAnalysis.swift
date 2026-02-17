import Foundation

// MARK: - Protocol 继承分析

// ========================================
// 场景 1: 不需要 Protocol (100% 方案)
// ========================================

// 每个 struct 独立，直接使用 static var
struct 项目设置V1 {
    nonisolated(unsafe) static var _cso: [String: Any]?
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
    static func dataPrepare() -> [String: Any] { [:] }
}

struct 指标导向库V1 {
    nonisolated(unsafe) static var _cso: [String: Any]?
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
    static func dataPrepare() -> [String: Any] {
        let _ = 项目设置V1.cso  // 直接访问依赖
        return [:]
    }
}

// ========================================
// 场景 2: 需要 Protocol (多态处理)
// ========================================

// 当需要统一处理多个实体时，需要 Protocol

protocol 数据实体 {
    static var basename: String { get }
    static func dataPrepare() -> [String: Any]
}

extension 数据实体 {
    static func dataPrepare() -> [String: Any] { [:] }
}

struct 项目设置V2: 数据实体 {
    static let basename = "项目设置"
    nonisolated(unsafe) static var _cso: [String: Any]?
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
}

struct 指标导向库V2: 数据实体 {
    static let basename = "指标导向库"
    nonisolated(unsafe) static var _cso: [String: Any]?
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
}

// 多态处理：统一重置所有实体
func resetAllEntities() {
    let entities: [any 数据实体.Type] = [
        项目设置V2.self,
        指标导向库V2.self
    ]
    
    for entity in entities {
        print("重置: \(entity.basename)")
        // 这里可以调用统一的 reset 方法
    }
}

// ========================================
// 场景 3: Protocol 继承 (分层能力)
// ========================================

// 原著的继承链在 Swift 中可以用 Protocol 继承模拟

protocol 基础实体 {
    static var basename: String { get }
}

protocol 缓存实体: 基础实体 {
    static func reset()
}

protocol 数据实体完整: 缓存实体 {
    static var cso: [String: Any] { get }
    static func dataPrepare() -> [String: Any]
}

// 实现
struct 项目设置V3: 数据实体完整 {
    static let basename = "项目设置"
    nonisolated(unsafe) static var _cso: [String: Any]?
    
    static var cso: [String: Any] {
        if _cso == nil { _cso = dataPrepare() }
        return _cso!
    }
    
    static func dataPrepare() -> [String: Any] { [:] }
    
    static func reset() { _cso = nil }
}

// ========================================
// 对比总结
// ========================================

/*
 | 场景 | 是否需要 Protocol | 原因 |
 |------|------------------|------|
 | 基础使用 | ❌ | struct + static var 足够 |
 | 多态处理 | ✅ | 需要统一处理多个实体 |
 | 代码共享 | ✅ | Protocol extension 提供默认实现 |
 | 能力分层 | ✅ | Protocol 继承模拟原著继承链 |
 
 结论:
 
 1. 100% 方案 (static var) 本身不需要 Protocol
 2. Protocol 在需要多态或代码共享时有用
 3. Protocol 继承可以模拟原著的继承链能力分层
 4. 但对于简单的数据实体，直接 struct + static var 最简洁
 */
