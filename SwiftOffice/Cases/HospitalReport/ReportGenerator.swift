import Foundation

// MARK: - PPT 报告生成器

public class PPT报告生成器 {
    
    public let 项目名: String
    public let 最终年份: Int
    public let 客户名称: String
    
    public init(项目名: String, 最终年份: Int, 客户名称: String) {
        self.项目名 = 项目名
        self.最终年份 = 最终年份
        self.客户名称 = 客户名称
    }
    
    // MARK: - 年份计算
    
    public var year_1: String { "Y\(最终年份)" }
    public var year_2: String { "Y\(最终年份 - 1)" }
    public var year_3: String { "Y\(最终年份 - 2)" }
    
    // MARK: - 图表颜色方案
    
    public struct SchemeColor {
        public static let text1 = "363636"
        public static let text2 = "666666"
        public static let background1 = "FFFFFF"
        public static let background2 = "F5F5F5"
        public static let accent1 = "4472C4"
        public static let accent2 = "ED7D31"
        public static let accent3 = "A5A5A5"
    }
    
    // MARK: - 字体设置
    
    public struct FontSettings {
        public static let titleFontSize: Int = 12
        public static let legendFontSize: Int = 5
        public static let dataLabelFontSize: Int = 5
        public static let catAxisLabelFontSize: Int = 5
    }
    
    // MARK: - 幻灯片数据结构
    
    public struct SlideData {
        public let title: String
        public let content: String?
        public let chart: ChartData?
        public let table: TableData?
        
        public init(title: String, content: String? = nil, chart: ChartData? = nil, table: TableData? = nil) {
            self.title = title
            self.content = content
            self.chart = chart
            self.table = table
        }
    }
    
    public struct ChartData {
        public let type: ChartType
        public let title: String
        public let series: [ChartSeries]
        public let options: [String: Any]?
        
        public init(type: ChartType, title: String, series: [ChartSeries], options: [String: Any]? = nil) {
            self.type = type
            self.title = title
            self.series = series
            self.options = options
        }
    }
    
    public enum ChartType: String {
        case bar = "bar"
        case line = "line"
        case pie = "pie"
        case radar = "radar"
        case scatter = "scatter"
    }
    
    public struct ChartSeries {
        public let name: String
        public let labels: [String]
        public let values: [Double]
        
        public init(name: String, labels: [String], values: [Double]) {
            self.name = name
            self.labels = labels
            self.values = values
        }
    }
    
    public struct TableData {
        public let headers: [String]
        public let rows: [[String]]
        public let options: [String: Any]?
        
        public init(headers: [String], rows: [[String]], options: [String: Any]? = nil) {
            self.headers = headers
            self.rows = rows
            self.options = options
        }
    }
    
    // MARK: - 报告生成
    
    @available(macOS 10.15, *)
    public func generateReport(
        sections: [ReportSection],
        outputPath: String
    ) async throws {
        var slides: [[String: Any]] = []
        
        // 标题页
        slides.append([
            "title": "\(客户名称)运营分析报告",
            "content": "\(最终年份)年度数据分析"
        ])
        
        // 各章节幻灯片
        for section in sections {
            slides.append(contentsOf: section.toSlideData())
        }
        
        try await SwiftOffice.createPPT(slides: slides, outputPath: outputPath)
    }
    
    public struct ReportSection {
        public let title: String
        public let slides: [SlideData]
        
        public init(title: String, slides: [SlideData]) {
            self.title = title
            self.slides = slides
        }
        
        public func toSlideData() -> [[String: Any]] {
            return slides.map { slide in
                var data: [String: Any] = ["title": slide.title]
                
                if let content = slide.content {
                    data["content"] = content
                }
                
                if let chart = slide.chart {
                    data["chart"] = [
                        "type": chart.type.rawValue,
                        "title": chart.title,
                        "series": chart.series.map { [
                            "name": $0.name,
                            "labels": $0.labels,
                            "values": $0.values
                        ] }
                    ]
                }
                
                if let table = slide.table {
                    data["table"] = [
                        "headers": table.headers,
                        "rows": table.rows
                    ]
                }
                
                return data
            }
        }
    }
}

// MARK: - 医院报告生成器

public final class 医院报告生成器: PPT报告生成器 {
    
    public init(最终年份: Int, 客户名称: String) {
        super.init(项目名: "医院运营分析", 最终年份: 最终年份, 客户名称: 客户名称)
    }
    
    // MARK: - 医疗质量雷达图
    
    public func 医疗质量雷达图数据() -> ChartData {
        return ChartData(
            type: .radar,
            title: "医疗质量指标雷达图",
            series: [
                ChartSeries(
                    name: "\(最终年份)年",
                    labels: ["质量安全", "功能定位", "合理用药", "服务流程", "医保价值"],
                    values: [85, 78, 92, 88, 75]
                ),
                ChartSeries(
                    name: "\(最终年份 - 1)年",
                    labels: ["质量安全", "功能定位", "合理用药", "服务流程", "医保价值"],
                    values: [80, 75, 88, 82, 70]
                )
            ]
        )
    }
    
    // MARK: - 运营效率柱状图
    
    public func 运营效率柱状图数据() -> ChartData {
        let years = (最终年份 - 4...最终年份).map { String($0) }
        return ChartData(
            type: .bar,
            title: "运营效率年度对比",
            series: [
                ChartSeries(name: "收支结构", labels: years, values: [72, 75, 78, 82, 85]),
                ChartSeries(name: "费用控制", labels: years, values: [68, 70, 73, 78, 82]),
                ChartSeries(name: "资源效率", labels: years, values: [65, 68, 72, 76, 80])
            ],
            options: ["barDir": "col"]
        )
    }
    
    // MARK: - 科室排名表
    
    public func 科室排名表数据() -> TableData {
        return TableData(
            headers: ["科室名称", "排名1", "排名2", "排名3", "排名4", "排名5"],
            rows: [
                ["内科一病区", "92.5", "88.3", "85.6", "82.1", "78.9"],
                ["外科一病区", "90.2", "86.7", "84.2", "80.5", "76.3"],
                ["妇产科", "88.9", "85.4", "82.8", "79.6", "75.2"],
                ["儿科", "87.6", "84.1", "81.5", "78.3", "74.1"],
                ["急诊科", "86.3", "82.8", "80.2", "77.0", "73.0"]
            ]
        )
    }
    
    // MARK: - 完整报告
    
    public func 创建完整报告() -> [ReportSection] {
        return [
            ReportSection(
                title: "医院层面指标",
                slides: [
                    SlideData(title: "医疗质量指标雷达图", chart: 医疗质量雷达图数据()),
                    SlideData(title: "运营效率年度对比", chart: 运营效率柱状图数据())
                ]
            ),
            ReportSection(
                title: "科室层面指标",
                slides: [
                    SlideData(title: "科室指标排名表", table: 科室排名表数据())
                ]
            )
        ]
    }
}
