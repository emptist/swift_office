import Foundation

// MARK: - PPT 章节基类 (对应 self.coffee 中的 PPTSection)

open class PPT章节: 实体基类, @unchecked Sendable {
    
    public init(basename: String) {
        super.init(dirname: nil, basename: basename, needToRewrite: false)
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    // 每部分限定几张PPT,用于测试和demo
    open func pageLimit() -> Int? {
        return nil
    }
    
    // 页面标题
    open func pageTitle() -> String {
        return "Page Title"
    }
    
    // 章节数据
    open func sectionData() -> [String: Any] {
        return [:]
    }
    
    // 生成幻灯片
    open func slides(pres: inout [[String: Any]], sectionTitle: String) {
        // 子类实现
    }
}

// MARK: - 文本页面 (对应 self.coffee 中的 文本页面 extends PPTSection)

open class 文本页面: PPT章节 {
    
    public override init(basename: String) {
        super.init(basename: basename)
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func slides(pres: inout [[String: Any]], sectionTitle: String) {
        let sectionData = self.sectionData()
        var lines: [[String: Any]] = []
        
        for (key, value) in sectionData {
            lines.append([
                "text": key,
                "options": ["fontSize": 16, "bold": true, "breakLine": true]
            ])
            lines.append([
                "text": "\(value)\n",
                "options": ["fontSize": 12, "breakLine": true]
            ])
        }
        
        let size = lines.count
        let limit = 15
        var pstart = 0
        var pend = limit
        
        while size > pstart {
            var slide: [String: Any] = ["sectionTitle": sectionTitle]
            slide["textLines"] = Array(lines[pstart..<min(pend, size)])
            slide["textOptions"] = [
                "x": 1, "y": 1, "w": "80%", "h": 4,
                "align": "left"
            ]
            pres.append(slide)
            pstart = pend
            pend += limit
        }
    }
}

// MARK: - 表格页面 (对应 self.coffee 中的 表格页面 extends PPTSection)

open class 表格页面: PPT章节 {
    
    public override init(basename: String) {
        super.init(basename: basename)
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    open func arrayName() -> String {
        return ""
    }
    
    open func titles() -> [String] {
        return []
    }
    
    public override func slides(pres: inout [[String: Any]], sectionTitle: String) {
        // 子类实现具体表格逻辑
    }
}

// MARK: - 科室逐项指标排名表 (对应 self.coffee 中的 科室逐项指标排名表 extends 表格页面)

public final class 科室逐项指标排名表: 表格页面, @unchecked Sendable {
    
    private var deptsNumber: Int = 5
    
    public init() {
        super.init(basename: "科室逐项指标排名表")
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func titles() -> [String] {
        return ["数据名", "前一", "前二", "前三", "前四", "前五", "末五", "末四", "末三", "末二", "末一"]
    }
    
    public override func slides(pres: inout [[String: Any]], sectionTitle: String) {
        let sectionData = self.sectionData()
        
        // 将数据转换为表格行
        var data: [[String]] = []
        for (indicator, dataArray) in sectionData {
            if let units = dataArray as? [[String: Any]] {
                var row = [indicator]
                for unit in units {
                    if let name = unit["unitName"] as? String {
                        row.append(name)
                    }
                }
                if row.count > 1 {
                    data.append(row)
                }
            }
        }
        
        let titles = self.titles()
        let size = data.count
        
        func newPage(_ pageData: [[String]]) {
            var rows: [[String]] = []
            rows.append(titles)
            rows.append(contentsOf: pageData)
            
            var slide: [String: Any] = [
                "sectionTitle": sectionTitle,
                "title": sectionTitle,
                "table": [
                    "headers": titles,
                    "rows": pageData
                ]
            ]
            pres.append(slide)
        }
        
        let lines = 10
        var pstart = 0
        var pend = lines
        
        while size > pstart {
            newPage(Array(data[pstart..<min(pend, size)]))
            pstart = pend
            pend += lines
        }
    }
}

// MARK: - 三级指标数据统计分析 (对应 self.coffee 中的 三级指标数据统计分析 extends 文本页面)

public final class 三级指标数据统计分析: 文本页面, @unchecked Sendable {
    
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public init() {
        super.init(basename: "三级指标数据统计分析")
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func sectionData() -> [String: Any] {
        var answer: [String: Any] = [:]
        
        // 模拟原著逻辑：从统计数据中提取需要改进的科室信息
        // 实际实现需要连接到 院内指标资料库 和 指标导向库
        
        // 示例数据
        answer["出院患者手术占比"] = "有3个科室出院患者手术占比指标须改进。建议加强手术科室建设。"
        answer["药占比"] = "有2个科室药占比指标须改进。建议优化用药结构。"
        answer["平均住院日"] = "有4个科室平均住院日指标须改进。建议优化诊疗流程。"
        
        return answer
    }
}

// MARK: - 三级指标数据前后各五名列表 (对应 self.coffee 中的 三级指标数据前后各五名列表 extends 科室逐项指标排名表)

public final class 三级指标数据前后各五名列表: 科室逐项指标排名表, @unchecked Sendable {
    
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public init() {
        super.init()
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func sectionData() -> [String: Any] {
        // 模拟原著逻辑：从排序数据中提取前后各五名
        // 实际实现需要连接到 三级指标非各部全零原值排序
        
        return [
            "出院患者手术占比": [
                ["unitName": "外科一病区", "value": 95.2],
                ["unitName": "外科二病区", "value": 92.1],
                ["unitName": "骨科", "value": 88.5],
                ["unitName": "妇产科", "value": 85.3],
                ["unitName": "眼科", "value": 82.1],
                ["unitName": "皮肤科", "value": 12.5],
                ["unitName": "中医科", "value": 10.2],
                ["unitName": "康复科", "value": 8.5],
                ["unitName": "内科三病区", "value": 5.2],
                ["unitName": "内科一病区", "value": 3.1]
            ],
            "药占比": [
                ["unitName": "外科一病区", "value": 25.3],
                ["unitName": "骨科", "value": 28.5],
                ["unitName": "眼科", "value": 30.2],
                ["unitName": "妇产科", "value": 32.1],
                ["unitName": "儿科", "value": 35.5],
                ["unitName": "内科二病区", "value": 58.2],
                ["unitName": "中医科", "value": 60.5],
                ["unitName": "内科一病区", "value": 62.3],
                ["unitName": "康复科", "value": 65.1],
                ["unitName": "老年科", "value": 68.9]
            ]
        ]
    }
    
    public override func titles() -> [String] {
        return ["数据名", "第1名", "第2名", "第3名", "第4名", "第5名", "倒数第5", "倒数第4", "倒数第3", "倒数第2", "倒数第1"]
    }
}

// MARK: - 原值排序报告 (对应 self.coffee 中的 原值排序报告)

open class 原值排序报告: PPT章节 {
    
    public override init(basename: String) {
        super.init(basename: basename)
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func sectionData() -> [String: Any] {
        // 从数据库获取排序数据
        return [:]
    }
}

// MARK: - 三级指标非各部全零原值排序 (对应 self.coffee 中的 三级指标非各部全零原值排序 extends 原值排序报告)

public final class 三级指标非各部全零原值排序: 原值排序报告, @unchecked Sendable {
    
    nonisolated(unsafe) public static var cache: [String: Any]?
    
    public init() {
        super.init(basename: "三级指标非各部全零原值排序")
    }
    
    public required init(dirname: String? = nil, basename: String, needToRewrite: Bool = false) {
        super.init(dirname: dirname, basename: basename, needToRewrite: needToRewrite)
    }
    
    public override func sectionData() -> [String: Any] {
        // 实际实现需要从 院内指标资料库 获取数据并排序
        return [:]
    }
}
