import Foundation

// MARK: - 业务实体基类 (POP 实现)

public class 业务实体: DatabaseProtocol {
    public let dirname: String?
    public let basename: String
    public let needToRewrite: Bool
    
    public init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        self.dirname = dirname
        self.basename = basename
        self.needToRewrite = needToRewrite
    }
    
    public func dataPrepare() -> [String: Any]? {
        let (_, isReady) = jsonfileNeedsNoFix()
        if isReady {
            return readFromJSON()
        }
        return [:]
    }
}

// MARK: - 别名库实体

public final class 别名库实体: 业务实体, AliasProtocol {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static var shared: 别名库实体 {
        return 别名库实体(basename: "别名库", needToRewrite: true)
    }
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
}

// MARK: - 名字ID库实体

public final class 名字ID库实体: 业务实体, GlobalSingletonProtocol {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static var shared: 名字ID库实体 {
        return 名字ID库实体(basename: "名字ID库", needToRewrite: true)
    }
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
}

// MARK: - 简称库实体

public final class 简称库实体: 业务实体, GlobalSingletonProtocol {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static var shared: 简称库实体 {
        return 简称库实体(basename: "简称库", needToRewrite: true)
    }
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
}

// MARK: - 自制别名库实体

public final class 自制别名库实体: 业务实体, AliasProtocol {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static var shared: 自制别名库实体 {
        return 自制别名库实体(basename: "自制别名库", needToRewrite: true)
    }
    
    public override init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
}
