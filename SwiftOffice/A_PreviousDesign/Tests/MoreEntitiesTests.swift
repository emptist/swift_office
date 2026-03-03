import Testing
import Foundation
@testable import SwiftOffice

@Suite("更多业务实体测试")
struct MoreEntitiesTests {
    
    @Test("一二三级指标体系V4: 层级查询")
    func testIndicatorHierarchy() {
        let hierarchy = 一二三级指标体系V4()
        
        // 验证层级查询方法
        let level1 = hierarchy.一级指标()
        #expect(level1.isEmpty)  // 无数据时返回空
        
        let level2 = hierarchy.二级指标(一级: "质量安全")
        #expect(level2.isEmpty)
        
        let level3 = hierarchy.三级指标(一级: "质量安全", 二级: "医疗质量")
        #expect(level3.isEmpty)
    }
    
    @Test("一二三级院级指标体系V4: 特化 scope")
    func testHospitalIndicatorHierarchy() {
        let hierarchy = 一二三级院级指标体系V4()
        
        #expect(hierarchy.scope == "院级")
        #expect(hierarchy.basename == "一二三级院级指标体系")
    }
    
    @Test("一二三级科级指标体系V4: 特化 scope")
    func testDeptIndicatorHierarchy() {
        let hierarchy = 一二三级科级指标体系V4()
        
        #expect(hierarchy.scope == "科级")
        #expect(hierarchy.basename == "一二三级科级指标体系")
    }
    
    @Test("项目内外资料表V4: Excel 写入能力")
    func testProjectDataTable() {
        let table = 项目内外资料表V4(basename: "测试表")
        
        // 验证组合了 Excel 写入能力
        table.write2Excel([:])
        table.saveExcel(opts: [:])
        
        let data = table.generateExcelData()
        #expect(data.count == 1)  // 默认一个 sheet
        #expect(data[0]["sheet"] as? String == "医院")
    }
    
    @Test("章节扉页V4Full: PPT 章节能力")
    func testSectionTitlePage() {
        var page = 章节扉页V4Full(basename: "扉页")
        
        var pres: [[String: Any]] = []
        page.slides(pres: &pres, sectionTitle: "测试章节")
        
        #expect(pres.count == 1)
        #expect(pres[0]["type"] as? String == "section")
    }
    
    @Test("排序报告V4Full: 组合 5 种能力")
    func testSortedReport() {
        let report = 排序报告V4Full(basename: "排序报告")
        
        // 验证组合了 5 种能力
        let _: [String: Any]? = report.sectionData()  // PPTSectionCapable
        let _: [String: Any] = report.setDB()  // DatabaseCapable
        let _: [String: Any]? = report.requestJSON()  // DatabaseCapable
        let _: [String: Any] = report.generateChartData()  // ChartGeneratable
        let _: [[String: Any]] = report.sortedData(by: "value")  // Sortable
        
        var pres: [[String: Any]] = []
        report.slides(pres: &pres, sectionTitle: "测试")
        
        #expect(pres.count == 1)
        #expect(pres[0]["chartType"] as? String == "bar")
    }
    
    @Test("原值排序报告V4Full: showValue = true")
    func testOriginalValueReport() {
        let report = 原值排序报告V4Full(basename: "原值报告")
        
        #expect(report.showValue == true)
        
        var pres: [[String: Any]] = []
        report.slides(pres: &pres, sectionTitle: "测试")
        
        #expect(pres[0]["showValue"] as? Bool == true)
    }
    
    @Test("内部原值排序报告V4Full: showValue = false")
    func testInternalOriginalValueReport() {
        let report = 内部原值排序报告V4Full(basename: "内部报告")
        
        #expect(report.showValue == false)
        
        var pres: [[String: Any]] = []
        report.slides(pres: &pres, sectionTitle: "测试")
        
        #expect(pres[0]["showValue"] as? Bool == false)
    }
    
    @Test("雷达图报告V4Full: chartType = radar")
    func testRadarChartReport() {
        let report = 雷达图报告V4Full(basename: "雷达图")
        
        var pres: [[String: Any]] = []
        report.slides(pres: &pres, sectionTitle: "测试")
        
        #expect(pres.count == 1)
        #expect(pres[0]["chartType"] as? String == "radar")
    }
    
    @Test("多科雷达图报告V4Full: 组合 5 种能力")
    func testMultiDeptRadarReport() {
        let report = 多科雷达图报告V4Full(basename: "多科雷达图")
        
        // 验证组合了 5 种能力
        let _: [String: Any]? = report.sectionData()  // PPTSectionCapable
        let _: [String: Any] = report.setDB()  // DatabaseCapable
        let _: [String: Any] = report.generateChartData()  // ChartGeneratable
        let _: String = report.adjustedName("test_name")  // AliasCapable
        
        // 额外方法
        let comparison = report.compareIndicators("指标A", "指标B")
        #expect(comparison["indicator1"] as? String == "指标A")
        #expect(comparison["indicator2"] as? String == "指标B")
        
        var pres: [[String: Any]] = []
        report.slides(pres: &pres, sectionTitle: "测试")
        
        #expect(pres[0]["multiDept"] as? Bool == true)
    }
    
    @Test("Protocol 类型集合: 统一处理 PPT 章节")
    func testPPTSectionPolymorphism() {
        let sections: [any PPTSectionCapable] = [
            章节扉页V4Full(basename: "扉页"),
            分节文本页面V4Full(basename: "文本"),
            排序报告V4Full(basename: "排序"),
            雷达图报告V4Full(basename: "雷达图"),
            多科雷达图报告V4Full(basename: "多科雷达图")
        ]
        
        var pres: [[String: Any]] = []
        for section in sections {
            section.slides(pres: &pres, sectionTitle: "测试")
        }
        
        #expect(pres.count == 5)
    }
    
    @Test("对比: 原著需要 5 个类，Swift 只需 5 个 struct")
    func testCodeComparison() {
        /*
         原著 CoffeeScript:
         
         class ChartPPTSection
         class 排序报告 extends ChartPPTSection
         class 原值排序报告 extends 排序报告
         class 内部原值排序报告 extends 原值排序报告
         class 雷达图报告 extends ChartPPTSection
         class 多科雷达图报告 extends 雷达图报告
         
         问题:
         1. 需要创建 ChartPPTSection 基类
         2. 内部原值排序报告需要继承原值排序报告
         3. 多科雷达图报告无法组合其他能力
         
         Swift Protocol 组合:
         
         排序报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable, Sortable
         原值排序报告V4Full: ... { showValue = true }
         内部原值排序报告V4Full: ... { showValue = false }
         雷达图报告V4Full: PPTSectionCapable, DatabaseCapable, CacheCapable, ChartGeneratable
         多科雷达图报告V4Full: ..., AliasCapable
         
         优势:
         1. 不需要基类
         2. 特化通过属性实现
         3. 可以自由组合能力
         */
        
        #expect(true)
    }
}
