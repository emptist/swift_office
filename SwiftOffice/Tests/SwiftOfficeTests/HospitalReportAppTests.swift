import Testing
import Foundation
@testable import SwiftOffice

@Suite("Hospital Report App Tests")
struct HospitalReportAppTests {
    
    @Test("项目设置 has correct basename")
    func testProjectSettingsBasename() {
        #expect(项目设置.shared.basename == "项目设置")
    }
    
    @Test("指标导向库 has correct basename")
    func testIndicatorGuideBasename() {
        #expect(指标导向库.shared.basename == "指标导向库")
    }
    
    @Test("院内资料库 has correct basename")
    func testInternalDataBasename() {
        #expect(院内资料库.shared.basename == "院内资料库")
    }
    
    @Test("对标资料库 has correct basename")
    func testBenchmarkDataBasename() {
        #expect(对标资料库.shared.basename == "对标资料库")
    }
    
    @Test("医院报告生成器 creates correct year strings")
    func testHospitalReportGeneratorYears() {
        let generator = 医院报告生成器(最终年份: 2024, 客户名称: "测试医院")
        
        #expect(generator.year_1 == "Y2024")
        #expect(generator.year_2 == "Y2023")
        #expect(generator.year_3 == "Y2022")
    }
    
    @Test("医院报告生成器 creates radar chart data")
    func testHospitalReportGeneratorRadarChart() {
        let generator = 医院报告生成器(最终年份: 2024, 客户名称: "测试医院")
        let chartData = generator.医疗质量雷达图数据()
        
        #expect(chartData.type == .radar)
        #expect(chartData.title == "医疗质量指标雷达图")
        #expect(chartData.series.count == 2)
        #expect(chartData.series[0].labels.count == 5)
    }
    
    @Test("医院报告生成器 creates bar chart data")
    func testHospitalReportGeneratorBarChart() {
        let generator = 医院报告生成器(最终年份: 2024, 客户名称: "测试医院")
        let chartData = generator.运营效率柱状图数据()
        
        #expect(chartData.type == .bar)
        #expect(chartData.series.count == 3)
        #expect(chartData.series[0].values.count == 5)
    }
    
    @Test("医院报告生成器 creates table data")
    func testHospitalReportGeneratorTableData() {
        let generator = 医院报告生成器(最终年份: 2024, 客户名称: "测试医院")
        let tableData = generator.科室排名表数据()
        
        #expect(tableData.headers.count == 6)
        #expect(tableData.rows.count == 5)
    }
    
    @Test("医院报告生成器 creates complete report sections")
    func testHospitalReportGeneratorCompleteReport() {
        let generator = 医院报告生成器(最终年份: 2024, 客户名称: "测试医院")
        let sections = generator.创建完整报告()
        
        #expect(sections.count == 2)
        #expect(sections[0].title == "医院层面指标")
        #expect(sections[0].slides.count == 2)
        #expect(sections[1].title == "科室层面指标")
        #expect(sections[1].slides.count == 1)
    }
    
    @Test("ChartType has correct raw values")
    func testChartTypeRawValues() {
        #expect(PPT报告生成器.ChartType.bar.rawValue == "bar")
        #expect(PPT报告生成器.ChartType.line.rawValue == "line")
        #expect(PPT报告生成器.ChartType.pie.rawValue == "pie")
        #expect(PPT报告生成器.ChartType.radar.rawValue == "radar")
    }
    
    @Test("SchemeColor has correct values")
    func testSchemeColorValues() {
        #expect(PPT报告生成器.SchemeColor.text1 == "363636")
        #expect(PPT报告生成器.SchemeColor.accent1 == "4472C4")
    }
    
    @Test("FontSettings has default values")
    func testFontSettingsDefaults() {
        #expect(PPT报告生成器.FontSettings.titleFontSize == 12)
        #expect(PPT报告生成器.FontSettings.legendFontSize == 5)
    }
}
