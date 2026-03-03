import Foundation

public class 别名库: Alias {
    
    nonisolated(unsafe) private static var _cso: [String: Any]? = nil
    
    public override class var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        _ = setDB(["thisClass": "别名库"])
        return requestJSON()
    }
    
    public class func ex() {
        saveExcel()
    }
}

public class 名字ID库: AnyGlobalSingleton {
    
    nonisolated(unsafe) private static var _cso: [String: Any]? = nil
    
    public override class var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        _ = setDB(["thisClass": "名字ID库"])
        return requestJSON()
    }
}

public class 简称库: AnyGlobalSingleton {
    
    nonisolated(unsafe) private static var _cso: [String: Any]? = nil
    
    public override class var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        _ = setDB(["thisClass": "简称库"])
        return requestJSON()
    }
}

public class 自制别名库: Alias {
    
    nonisolated(unsafe) private static var _cso: [String: Any]? = nil
    
    public override class var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
    
    public override class func dataPrepare() -> [String: Any]? {
        _ = setDB(["thisClass": "自制别名库"])
        return requestJSON()
    }
}
