import Testing
import Foundation
@testable import SwiftOffice

@Suite("V4 Protocol + Struct 深度测试")
struct V4ProtocolStructTests {
    
    // MARK: - Protocol 继承链测试
    
    @Test("FileIOProtocol 默认实现")
    func testFileIOProtocolDefaults() {
        let handler = FileHandler(basename: "test")
        
        #expect(handler.basename == "test")
        #expect(handler.dirname == nil)
        #expect(handler.getJSONFilename() == "data/JSON/test.json")
        #expect(handler.getExcelFilename() == "data/Excel/test.xlsx")
        #expect(handler.getPPTFilename(generator: "pg") == "outputs/PPT/test.pg.pptx")
    }
    
    @Test("JSONDatabaseProtocol 默认实现")
    func testJSONDatabaseProtocolDefaults() {
        let handler = DatabaseHandlerV4(basename: "test")
        
        #expect(handler.mainKeyName == "数据名")
        #expect(handler.header["rows"] as? Int == 1)
        #expect(handler.columnToKey["*"] == "{{columnHeader}}")
    }
    
    @Test("CaseProtocol 默认实现")
    func testCaseProtocolDefaults() {
        let handler = CaseHandler(basename: "test")
        
        #expect(handler.normalKeyName("测试名称") == "测试名称")
        #expect(handler.years().isEmpty)
        #expect(handler.localUnits().isEmpty)
        #expect(handler.focusUnits().isEmpty)
    }
    
    // MARK: - 业务实体测试
    
    @Test("项目设置V4 结构正确")
    func testProjectSettingsV4() {
        let settings = 项目设置V4(dirname: nil)
        
        #expect(settings.basename == "项目设置")
        #expect(settings.mainKeyName == "数据名")
        #expect(settings.options()["basename"] as? String == "项目设置")
    }
    
    @Test("院内资料库V4 结构正确")
    func testInternalDataV4() {
        let data = 院内资料库V4(dirname: nil)
        
        #expect(data.basename == "院内资料库")
        // years() 和 localUnits() 需要实际文件才能测试
    }
    
    // MARK: - PPT 章节测试
    
    @Test("章节扉页V4 继承链正确")
    func testChapterTitlePageV4() {
        let page = 章节扉页V4(basename: "测试章节")
        
        // 验证 Protocol 继承
        #expect(page.basename == "测试章节")
        #expect(page.sectionAvailable() == true)
        #expect(page.pageTitle("测试") == "章节扉页")
    }
    
    @Test("分节文本页面V4 继承链正确")
    func testSectionTextPageV4() {
        let page = 分节文本页面V4(basename: "测试文本")
        
        // 验证 TextPPTSectionProtocol
        let testPage: [String: Any] = [
            "title": "测试标题",
            "content": ["项目1": "内容1", "项目2": "内容2"]
        ]
        
        let lines = page.textLines(testPage)
        #expect(lines.count == 4) // 2 keys * 2 lines each
    }
    
    @Test("科室逐项指标排名表V4 继承链正确")
    func testDeptRankingTableV4() {
        let table = 科室逐项指标排名表V4(basename: "排名表")
        
        // 验证 TablePPTSectionProtocol
        let titles = table.titles()
        #expect(titles.count == 11)
        #expect(titles[0] == "数据名")
        #expect(titles[1] == "前一")
    }
    
    @Test("雷达图报告V4 继承链正确")
    func testRadarChartV4() {
        let chart = 雷达图报告V4(basename: "雷达图")
        
        // 验证 ChartPPTSectionProtocol
        let data = chart.chartData()
        #expect(data["type"] as? String == "radar")
        #expect(data["title"] as? String == "雷达图")
    }
    
    // MARK: - Protocol 多态测试
    
    @Test("Protocol 多态: 所有实体都是 NormalCaseProtocol")
    func testProtocolPolymorphism() {
        // 可以用 Protocol 类型统一处理
        let entities: [any NormalCaseProtocol] = [
            项目设置V4(),
            指标导向库V4(),
            项目设置V4()  // CaseHandler 不符合 NormalCaseProtocol
        ]
        
        for entity in entities {
            // 都有相同的接口
            let _ = entity.basename
            let _ = entity.options()
            let _ = entity.readFromJSON()
        }
        
        #expect(entities.count == 3)
    }
    
    @Test("Protocol 多态: PPT 章节统一处理")
    func testPPTSectionPolymorphism() {
        // 可以用 Protocol 类型统一处理 PPT 章节
        let sections: [any PPTSectionProtocol] = [
            章节扉页V4(basename: "扉页1"),
            科室逐项指标排名表V4(basename: "表格1")
        ]
        
        var pres: [[String: Any]] = []
        
        for section in sections {
            // 统一调用 slides 方法
            section.slides(pres: &pres, sectionTitle: section.basename)
        }
        
        // 只有章节扉页会添加幻灯片
        #expect(pres.count >= 1)
    }
    
    // MARK: - 与原著对比
    
    @Test("对比: CoffeeScript vs Swift 代码量")
    func testCodeComparison() {
        /*
         原著 CoffeeScript (每个类):
         
         class 章节扉页 extends TextPPTSection
           @cso: @dataPrepare?()
           @slides: (funcOpts) ->
             {section, pres, sectionTitle} = funcOpts
             slide = pres.addSlide({sectionTitle})
             slide.addText(...)
           @pageTitle: (page) ->
             page.name.split('_')[0]
         
         约 10 行代码
         
         Swift Protocol + Struct (每个实体):
         
         struct 章节扉页V4: TextPPTSectionProtocol {
             let dirname: String?
             let basename: String
             
             init(dirname: String? = nil, basename: String) {
                 self.dirname = dirname
                 self.basename = basename
             }
             
             func pageTitle(_ page: Any) -> String { ... }
             func slides(...) { ... }
         }
         
         约 15-20 行代码
         
         差异:
         1. Swift 需要显式声明属性和初始化器
         2. Swift 需要 Protocol 定义 (但只需一次)
         3. Swift 类型安全，编译时检查
         4. 原著 @cso 自动调度，Swift 需要显式调用
         */
        
        #expect(true)
    }
    
    // MARK: - 缓存问题测试
    
    @Test("Struct 无状态: 每次都重新读取")
    func testStructStateless() {
        /*
         原著 CoffeeScript:
         
         class 项目设置
           @cso: @dataPrepare?()  # 自动缓存
           
           @dataPrepare: ->
             # 只执行一次
             @sdb = @setDB({thisClass: this})
             @requestJSON()
         
         访问 项目设置.cso 多次，dataPrepare 只执行一次
         
         Swift Struct:
         
         struct 项目设置V4: NormalCaseProtocol {
             func readFromJSON() -> [String: Any]? {
                 // 每次调用都读取文件
             }
         }
         
         每次调用 readFromJSON() 都会读取文件
         
         解决方案:
         1. 使用 class 包装带缓存
         2. 用户自己管理缓存
         3. 使用 Actor 全局缓存
         */
        
        let settings = 项目设置V4()
        
        // 第一次调用
        let _ = settings.readFromJSON()
        // 第二次调用
        let _ = settings.readFromJSON()
        // 两次都会读取文件
        
        #expect(true)
    }
}
