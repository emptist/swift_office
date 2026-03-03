import Foundation

open class AnyGlobalSingleton: StormDBSingleton {
    
    public override class func dbfilenm(_ classname: String) -> String {
        return "\(classname).json"
    }
    
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
            "saveAs": true,
            "renaming": normalKeyName
        ]
    }
    
    public class func dataPrepare() -> [String: Any]? {
        _ = setDB(["thisClass": String(describing: self)])
        return requestJSON()
    }
    
    nonisolated(unsafe) private static var _cso: [String: Any]? = nil
    
    public class var cso: [String: Any]? {
        if _cso == nil {
            _cso = dataPrepare()
        }
        return _cso
    }
}
