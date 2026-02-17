import Foundation

// MARK: - JSON Simple Handler (Struct-based)

public struct JSONSimpleHandler: FileHandling {
    public let dirname: String?
    public let basename: String
    public let needToRewrite: Bool
    
    public init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        self.dirname = dirname
        self.basename = basename
        self.needToRewrite = needToRewrite
    }
    
    public func getJSON() -> [String: Any]? {
        let (_, isReady) = jsonfileNeedsNoFix()
        if isReady {
            return readFromJSON()
        }
        return [:]
    }
}

// MARK: - Database Handler (Actor-based for thread safety)

public actor DatabaseHandler {
    public var storage: [String: Any] = [:]
    
    public init() {}
    
    public func initialize(classname: String, preserved: Bool = false) {
        if !preserved {
            storage[classname] = [:]
        }
    }
    
    public func getJSON(for classname: String) -> [String: Any]? {
        return storage[classname] as? [String: Any]
    }
    
    public func setJSON(_ data: [String: Any], for classname: String) {
        storage[classname] = data
    }
    
    public func clear() {
        storage.removeAll()
    }
}

// MARK: - Singleton Handler (Generic)

public final class SingletonHandler<T: FileHandling>: @unchecked Sendable {
    private var cache: [String: Any]?
    private let handler: T
    
    public init(handler: T) {
        self.handler = handler
    }
    
    public func fetch(rebuild: Bool = false) -> [String: Any]? {
        if rebuild || cache == nil {
            cache = handler.readFromJSON()
        }
        return cache
    }
    
    public func clearCache() {
        cache = nil
    }
}
