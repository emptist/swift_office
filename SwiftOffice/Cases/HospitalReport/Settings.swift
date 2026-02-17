import Foundation

// MARK: - 项目设置

public final class 项目设置: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 项目设置(basename: "项目设置", needToRewrite: false)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public var 一级指标设置: [String: [String: Any]] {
        (Self.fetch()?["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    public var 二级指标设置: [String: [String: Any]] {
        (Self.fetch()?["二级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    public var 三级指标设置: [String: [String: Any]] {
        (Self.fetch()?["三级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    public var 科室设置: [String: [String: Any]] {
        (Self.fetch()?["科室设置"] as? [String: [String: Any]]) ?? [:]
    }
}

// MARK: - 指标导向库

public final class 指标导向库: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 指标导向库(basename: "指标导向库", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func 导向指标集() -> [String: [String]] {
        var result: [String: [String]] = [:]
        guard let data = Self.fetch() as? [String: String] else { return result }
        for (指标名, 导向) in data {
            if result[导向] == nil {
                result[导向] = []
            }
            result[导向]?.append(指标名)
        }
        return result
    }
}

// MARK: - 三级指标对应二级指标

public final class 三级指标对应二级指标: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 三级指标对应二级指标(basename: "三级指标对应二级指标", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func 矢量指标() -> [String: [String]] {
        var result: [String: [String]] = [:]
        guard let data = Self.fetch() as? [String: String] else { return result }
        let 导向数据 = 指标导向库.shared.导向指标集()
        let 矢量导向 = ["逐步提高", "逐步降低", "高优", "低优"]
        
        for (三级指标, 二级指标) in data {
            if let 导向 = (导向数据.first { $0.value.contains(三级指标) })?.key,
               矢量导向.contains(导向) {
                if result[二级指标] == nil {
                    result[二级指标] = []
                }
                result[二级指标]?.append(三级指标)
            }
        }
        return result
    }
}

// MARK: - 院内资料库

public final class 院内资料库: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 院内资料库(basename: "院内资料库", needToRewrite: false)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func years() -> [String] {
        guard let data = Self.fetch() as? [String: [String: Any]] else { return [] }
        if let first = data.values.first {
            return first.keys.filter { $0.hasPrefix("Y") }.sorted().reversed()
        }
        return []
    }
    
    public func localUnits() -> [String] {
        guard let data = Self.fetch() as? [String: [String: Any]] else { return [] }
        return Array(data.keys)
    }
}

// MARK: - 对标资料库

public final class 对标资料库: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 对标资料库(basename: "对标资料库", needToRewrite: false)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func focusUnits() -> [String] {
        guard let data = Self.fetch() as? [String: [String: Any]] else { return [] }
        return Array(data.keys)
    }
}
