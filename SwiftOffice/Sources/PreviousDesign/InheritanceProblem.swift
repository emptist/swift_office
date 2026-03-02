import Foundation

// MARK: - 完整继承链翻译 (展示 @cso 问题)

// ============================================
// 第一层: JSONSimple (无依赖)
// ============================================

open class JSONSimple完整版 {
    
    public class func getJSONFilename(_ opts: [String: Any] = [:]) -> String {
        let dirname = opts["dirname"] as? String
        let folder = opts["folder"] as? String ?? "data"
        let basename = opts["basename"] as? String ?? String(describing: self)
        
        if let dir = dirname {
            return "\(dir)/\(basename).json"
        }
        return "\(folder)/JSON/\(basename).json"
    }
    
    public class func jsonfileNeedsNoFix(_ opts: [String: Any] = [:]) -> (String, Bool) {
        let jsonfilename = getJSONFilename(opts)
        let needToRewrite = opts["needToRewrite"] as? Bool ?? false
        let isReady = FileManager.default.fileExists(atPath: jsonfilename) && !needToRewrite
        return (jsonfilename, isReady)
    }
    
    public class func readFromJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let jsonfilename = opts["jsonfilename"] as? String ?? getJSONFilename(opts)
        guard FileManager.default.fileExists(atPath: jsonfilename),
              let data = FileManager.default.contents(atPath: jsonfilename),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    public class func getJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let (jsonfilename, isReady) = jsonfileNeedsNoFix(opts)
        if isReady {
            return readFromJSON(["jsonfilename": jsonfilename])
        }
        return [:]
    }
}

// ============================================
// 第二层: JSONDatabase (继承 JSONSimple, 添加 @cso)
// ============================================

open class JSONDatabase完整版: JSONSimple完整版 {
    
    // 问题1: 每个子类都需要重新声明 cache
    // 原著 CoffeeScript: @cso: @dataPrepare?() 自动处理
    // Swift: 需要显式声明 static var cache
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    // 问题2: 每个子类都需要重写 dataPrepare
    public class func dataPrepare() -> [String: Any]? {
        // 默认实现 - 子类应该重写
        return nil
    }
    
    // 模拟 @cso 访问
    public class var cso: [String: Any]? {
        if cache == nil {
            cache = dataPrepare()
        }
        return cache
    }
    
    // 数据库路径
    public class func dbfilenm(_ classname: String) -> String {
        return "\(classname).json"
    }
    
    public class func db(_ opts: [String: Any] = [:]) -> [String: Any]? {
        return cso
    }
    
    public class func requestJSON(_ key: String? = nil) -> [String: Any]? {
        if let k = key {
            return cso?[k] as? [String: Any]
        }
        return cso
    }
    
    public class func dbAsArray(_ opts: [String: Any] = [:]) -> [[String: Any]] {
        var arr: [[String: Any]] = []
        guard let json = requestJSON() else { return arr }
        
        for (k, v) in json {
            var obj: [String: Any] = ["unitName": k]
            if let valueDict = v as? [String: Any] {
                obj.merge(valueDict) { (_, new) in new }
            }
            arr.append(obj)
        }
        return arr
    }
    
    public class func dbDictKeys(_ opts: [String: Any] = [:]) -> [String] {
        guard let json = requestJSON() else { return [] }
        return Array(json.keys)
    }
}

// ============================================
// 第三层: StormDBSingleton (继承 JSONDatabase)
// ============================================

open class StormDBSingleton完整版: JSONDatabase完整版 {
    
    // 问题3: 需要重新声明 cache (否则会使用父类的)
    nonisolated(unsafe) public static var _stormCache: [String: Any]?
    
    public class func fetchSingleJSON(_ opts: [String: Any] = [:]) -> [String: Any]? {
        let rebuild = opts["rebuild"] as? Bool ?? false
        
        if rebuild {
            var options = self.options()
            options["needToRewrite"] = true
            _stormCache = getJSON(options)
        } else {
            if _stormCache == nil {
                _stormCache = getJSON(self.options())
            }
        }
        
        return _stormCache
    }
    
    public class func options() -> [String: Any] {
        return [
            "dirname": "",
            "basename": String(describing: self),
            "mainKeyName": "数据名",
            "header": ["rows": 1],
            "columnToKey": ["*": "{{columnHeader}}"],
            "sheetStubs": true,
            "needToRewrite": true,
            "unwrap": true,
            "saveAs": true
        ]
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        return fetchSingleJSON()
    }
}

// ============================================
// 第四层: AnyCaseSingleton (案例单例基类)
// ============================================

open class AnyCaseSingleton完整版: StormDBSingleton完整版 {
    
    // 问题4: 又需要重新声明 cache
    nonisolated(unsafe) public static var _caseCache: [String: Any]?
    
    public class func normalKeyName(_ opts: [String: Any]) -> String {
        return opts["mainKey"] as? String ?? ""
    }
    
    public override class func options() -> [String: Any] {
        var opts = super.options()
        opts["renaming"] = normalKeyName
        return opts
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        // 调用父类方法
        return fetchSingleJSON()
    }
}

// ============================================
// 第五层: CaseSingleton (案例单例)
// ============================================

open class CaseSingleton完整版: AnyCaseSingleton完整版 {
    
    // 问题5: 继续需要 cache
    nonisolated(unsafe) public static var _caseSingletonCache: [String: Any]?
    
    public class func years() -> [String] {
        return []
    }
    
    public class func localUnits() -> [String] {
        return []
    }
    
    public class func focusUnits() -> [String] {
        return []
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        return fetchSingleJSON()
    }
}

// ============================================
// 第六层: NormalCaseSingleton (标准案例单例)
// ============================================

open class NormalCaseSingleton完整版: CaseSingleton完整版 {
    
    // 问题6: cache 继续累积
    nonisolated(unsafe) public static var _normalCaseCache: [String: Any]?
    
    public override class func options() -> [String: Any] {
        return [
            "dirname": "",
            "basename": String(describing: self),
            "mainKeyName": "数据名",
            "header": ["rows": 1],
            "columnToKey": ["*": "{{columnHeader}}"],
            "sheetStubs": true,
            "needToRewrite": true,
            "unwrap": true,
            "saveAs": false,
            "renaming": normalKeyName
        ]
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        return fetchSingleJSON()
    }
}

// ============================================
// 第七层: 具体业务类 (项目设置)
// ============================================

public final class 项目设置完整版: NormalCaseSingleton完整版, @unchecked Sendable {
    
    // 问题7: 最终业务类也需要 cache
    nonisolated(unsafe) public static var _projectCache: [String: Any]?
    
    // 问题8: 需要重写 cso 计算属性来使用正确的 cache
    public override class var cso: [String: Any]? {
        if _projectCache == nil {
            _projectCache = dataPrepare()
        }
        return _projectCache
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        // 模拟原著: @sdb = @setDB({thisClass: this})
        // 然后读取 JSON
        return fetchSingleJSON()
    }
    
    public override class func options() -> [String: Any] {
        var opts = super.options()
        opts["unwrap"] = false
        return opts
    }
    
    // 业务方法
    public class var 一级指标设置: [String: [String: Any]] {
        (cso?["一级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    public class var 二级指标设置: [String: [String: Any]] {
        (cso?["二级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
    
    public class var 三级指标设置: [String: [String: Any]] {
        (cso?["三级指标设置"] as? [String: [String: Any]]) ?? [:]
    }
}

// ============================================
// 问题总结
// ============================================

/*
 原著 CoffeeScript 的 @cso: @dataPrepare?() 工作原理:
 
 1. @cso 是一个 class-side 属性
 2. @dataPrepare?() 是可选调用 - 如果方法存在则调用
 3. CoffeeScript/JavaScript 的原型链自动处理继承
 4. 每个类只需要写 @cso: @dataPrepare?() 一行代码
 
 Swift 翻译遇到的问题:
 
 1. static 属性不能被 override
    - 每个子类都需要重新声明 cache
    - 导致 cache 变量名累积 (_cache, _stormCache, _caseCache...)
 
 2. static 方法可以被 override，但需要显式调用 super
    - dataPrepare() 需要在每层重写
    - 容易遗漏 super 调用
 
 3. 计算属性 cso 需要在每层重写
    - 因为要访问正确的 cache 变量
 
 4. 没有自动触发机制
    - 原著: 访问 类名.cso 自动触发 dataPrepare
    - Swift: 需要显式设计访问模式
 
 解决方案:
 
 方案A: 使用 class 实例 + 单例模式
    - shared 实例持有 cache
    - 但失去了 class-side 编程的简洁性
 
 方案B: 使用 Protocol + 默认实现
    - protocol 定义接口
    - extension 提供默认实现
    - 但 static 属性仍需在每个类型中声明
 
 方案C: 使用 Actor + 全局注册表
    - 一个全局 Actor 管理所有缓存
    - 通过类名作为 key 访问
    - 线程安全，但增加复杂度
 */
