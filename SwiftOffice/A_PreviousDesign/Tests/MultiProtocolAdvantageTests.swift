import Testing
import Foundation
@testable import SwiftOffice

@Suite("多重 Protocol 优势测试")
struct MultiProtocolAdvantageTests {
    
    @Test("组合能力: DataReadable + DataWritable + Cacheable")
    func testComposedCapabilities() {
        var settings = 项目设置V4Plus()
        
        // 验证组合了多种能力
        #expect(settings.readFromJSON() == nil)  // DataReadable
        settings.writeToJSON([:])  // DataWritable
        settings.clearCache()  // Cacheable
        #expect(settings.adjustedName("test*name") == "testname")  // AliasProcessable
    }
    
    @Test("排序报告: Sortable + ChartGeneratable")
    func testSortableReport() {
        let report = 排序报告V4(basename: "测试报告")
        
        // 验证组合了排序和图表能力
        let sorted = report.sortedData(by: "value")
        #expect(sorted.isEmpty)  // 无数据时返回空
        
        let chartData = report.generateChartData()
        #expect(chartData["type"] as? String == "bar")
    }
    
    @Test("原值排序报告: 特化 showValue")
    func testOriginalValueReport() {
        let report = 原值排序报告V4(basename: "原值报告")
        
        // 验证 showValue = true
        #expect(report.showValue == true)
        
        let chartData = report.generateChartData()
        #expect(chartData["showValue"] as? Bool == true)
    }
    
    @Test("内部原值排序报告: 特化 showValue = false")
    func testInternalOriginalValueReport() {
        let report = 内部原值排序报告V4(basename: "内部报告")
        
        // 验证 showValue = false (特化)
        #expect(report.showValue == false)
        
        let chartData = report.generateChartData()
        #expect(chartData["showValue"] as? Bool == false)
    }
    
    @Test("雷达图报告: ChartGeneratable + Sortable")
    func testRadarChartReport() {
        let report = 雷达图报告V4Plus(basename: "雷达图")
        
        let chartData = report.generateChartData()
        #expect(chartData["type"] as? String == "radar")
        #expect(chartData["categories"] != nil)
    }
    
    @Test("多科雷达图报告: 四重 Protocol 组合")
    func testMultiDeptRadarReport() {
        let report = 多科雷达图报告V4(basename: "多科雷达图")
        
        // 验证组合了四种能力
        let _ = report.readFromJSON()  // DataReadable
        let _ = report.sortedData(by: "value")  // Sortable
        let _ = report.adjustedName("test_name")  // AliasProcessable
        let chartData = report.generateChartData()  // ChartGeneratable
        
        #expect(chartData["multiDept"] as? Bool == true)
        
        // 额外方法
        let comparison = report.compareIndicators("指标A", "指标B")
        #expect(comparison["indicator1"] as? String == "指标A")
    }
    
    @Test("Protocol 类型集合: 统一处理")
    func testProtocolTypeCollection() {
        // 可以用 Protocol 类型统一处理不同实体
        let chartGenerators: [any ChartGeneratable] = [
            排序报告V4(basename: "报告1"),
            原值排序报告V4(basename: "报告2"),
            雷达图报告V4Plus(basename: "报告3"),
            多科雷达图报告V4(basename: "报告4")
        ]
        
        var chartTypes: [String] = []
        for generator in chartGenerators {
            if let type = generator.generateChartData()["type"] as? String {
                chartTypes.append(type)
            }
        }
        
        #expect(chartTypes.count == 4)
        #expect(chartTypes.contains("bar"))
        #expect(chartTypes.contains("radar"))
    }
    
    @Test("对比: CoffeeScript 单继承 vs Swift 多重 Protocol")
    func testComparison() {
        /*
         CoffeeScript 单继承链:
         
         ChartPPTSection
              ↓
         排序报告
              ↓
         原值排序报告
              ↓
         内部原值排序报告 (@showValue: false)
         
         问题: 如果想给"雷达图报告"添加排序能力，需要重新设计继承链
         
         Swift 多重 Protocol:
         
         内部原值排序报告V4: Sortable, ChartGeneratable, DataReadable, TableGeneratable
         
         优势: 可以自由组合，不需要重新设计继承链
         */
        
        // 验证: 内部原值排序报告同时具有四种能力
        let report = 内部原值排序报告V4(basename: "测试")
        
        // Sortable
        let _: [[String: Any]] = report.sortedData(by: "value")
        
        // ChartGeneratable
        let _: [String: Any] = report.generateChartData()
        
        // DataReadable
        let _: [String: Any]? = report.readFromJSON()
        
        // TableGeneratable
        let _: [[String]] = report.generateTableData()
        
        #expect(true)
    }
}
