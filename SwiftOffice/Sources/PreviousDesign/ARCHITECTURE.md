# SwiftOffice 工具层架构

## 三层实现对比

### 1. v1 仿写层 - Class 继承 (仿原著 CoffeeScript)

```
JSONSimple (open class)                    # 基类：JSON 文件读写
  └── JSONDatabase: JSONSimple             # 数据库操作
        └── StormDBSingleton: JSONDatabase # StormDB 单例
              └── AnyGlobalSingleton       # 全局单例基类
                    ├── 别名库              # 业务实体
                    ├── 名字ID库            # 业务实体
                    ├── 简称库              # 业务实体
                    └── 自制别名库          # 业务实体
```

**特点**：
- 使用 `class` 继承链
- `nonisolated(unsafe)` 处理静态变量
- `static var cache` 模拟 class-side 属性
- `static func dataPrepare()` 模拟 `@dataPrepare`

### 2. v2 POP 层 - Protocol + Struct

```
FileHandling (protocol)                    # 文件操作协议
  └── JSONSimpleHandler: FileHandling      # struct 实现

DatabaseProtocol: FileHandling (protocol)  # 数据库协议
  └── DatabaseHandler (actor)              # actor 实现

SingletonProtocol: DatabaseProtocol        # 单例协议
  └── SingletonHandler<T> (generic class) # 泛型处理器
```

**特点**：
- 使用 `protocol` 定义接口
- 使用 `struct` 实现无状态操作
- 使用 `actor` 保证线程安全
- 组合优于继承

### 3. v3 完善层 - 混合方式

```
实体基类 (open class): DatabaseProtocol    # class 基类
  ├── 别名库V3: 实体基类, AliasProtocol    # class + protocol 组合
  ├── 名字ID库V3: 实体基类                 # class 实现
  ├── 简称库V3: 实体基类                   # class 实现
  └── 自制别名库V3: 实体基类               # class 实现
```

**特点**：
- 基类使用 `class` 保持继承链
- 协议定义特定功能 (如 AliasProtocol)
- `final class` 防止过度继承

## 原著 CoffeeScript vs Swift 对照

### CoffeeScript Class-Side Programming

```coffeescript
class 别名库 extends AnyGlobalSingleton
  @cso: @dataPrepare?()  # 懒加载 + 缓存
  
  @dataPrepare: ->
    @sdb = @setDB({thisClass: this})
    @sdb.get(@name).set(@fetchSingleJSON()).save()
    @requestJSON()
```

### Swift 实现

```swift
// v1 仿写
public final class 别名库: AnyGlobalSingleton, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?  # 缓存
    
    public static func dataPrepare() -> [String: Any]? {         # 懒加载
        let sdb = setDB(["thisClass": "别名库"])
        // ...
        return requestJSON()
    }
    
    public static func fetch(rebuild: Bool = false) -> [String: Any]? {
        if rebuild || cache == nil {
            cache = dataPrepare()
        }
        return cache
    }
}

// v3 完善
public final class 别名库V3: 实体基类, AliasProtocol, @unchecked Sendable {
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public static let shared = 别名库V3(basename: "别名库")
    
    public static func dataPrepare() -> [String: Any]? {
        return shared.readFromJSON()
    }
}
```

## 文件结构

```
Sources/SwiftOffice/
├── Protocols/
│   └── FileHandling.swift      # 核心协议定义
├── Implementations/
│   ├── Handlers.swift          # struct/actor 实现
│   ├── Entities.swift          # v1 仿写实体
│   └── RefinedEntities.swift   # v3 完善实体
├── JSONSimple.swift            # v1 基类
├── JSONDatabase.swift          # v1 数据库
├── StormDBSingleton.swift      # v1 单例
├── AnyGlobalSingleton.swift    # v1 全局单例
├── Singletons.swift            # v1 业务实体
├── Alias.swift                 # v1 别名类
├── NodeJSBridge.swift          # Node.js 桥接
├── NodeJSConfig.swift          # Node.js 配置
├── SwiftOfficeError.swift      # 错误定义
└── SwiftOfficeAPI.swift        # 统一 API
```

## 使用方式

```swift
// 方式 1: 直接使用 API
let json = SwiftOffice.readJSON(from: "data.json")
try await SwiftOffice.createPPT(slides: [...], outputPath: "report.pptx")

// 方式 2: 使用实体类 (v1/v3)
let alias = 别名库.fetch()
let name = 别名库.shared.adjustedName("测试名称")

// 方式 3: 使用 Handler (v2)
let handler = JSONSimpleHandler(basename: "test")
let data = handler.readFromJSON()
```
