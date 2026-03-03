import Foundation

// MARK: - Refined Entity Base Class

open class 实体基类: DatabaseProtocol, @unchecked Sendable {
    public let dirname: String?
    public let basename: String
    public let needToRewrite: Bool
    
    public init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        self.dirname = dirname
        self.basename = basename
        self.needToRewrite = needToRewrite
    }
    
    public func prepare() -> [String: Any]? {
        let (_, isReady) = jsonfileNeedsNoFix()
        if isReady {
            return readFromJSON()
        }
        return [:]
    }
}

// MARK: - Singleton Cache Manager

public final class SingletonCache: @unchecked Sendable {
    public static let shared = SingletonCache()
    
    private var storage: [String: Any] = [:]
    
    private init() {}
    
    public func get<T>(for key: String, loader: () -> T) -> T {
        if let cached = storage[key] as? T {
            return cached
        }
        let value = loader()
        storage[key] = value
        return value
    }
    
    public func set(_ value: Any, for key: String) {
        storage[key] = value
    }
    
    public func clear(_ key: String? = nil) {
        if let key = key {
            storage.removeValue(forKey: key)
        } else {
            storage.removeAll()
        }
    }
}

// MARK: - Refined Business Entities

public final class 别名库V3: 实体基类, AliasProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 别名库V3(basename: "别名库", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func lookup(_ name: String) -> String? {
        return adjustedName(name, keep: false)
    }
}

public final class 名字ID库V3: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 名字ID库V3(basename: "名字ID库", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func findID(for name: String) -> String? {
        guard let json = Self.fetch(),
              let idMap = json[name] as? [String: String] else {
            return nil
        }
        return idMap["id"]
    }
}

public final class 简称库V3: 实体基类, GlobalSingletonProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 简称库V3(basename: "简称库", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func getShortName(for name: String) -> String? {
        guard let json = Self.fetch() else { return nil }
        return json[name] as? String
    }
}

public final class 自制别名库V3: 实体基类, AliasProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 自制别名库V3(basename: "自制别名库", needToRewrite: true)
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
    
    public func lookup(_ name: String) -> String? {
        return adjustedName(name, keep: false)
    }
}
