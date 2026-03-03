import Foundation

@available(macOS 10.15, *)
public protocol ChartElement: SlideElement {
    var chartType: ChartType { get set }
    var data: ChartData { get set }
    var title: String? { get set }
    var showLegend: Bool { get set }
    var legendPosition: LegendPosition { get set }
    var showAxisLabels: Bool { get set }
    var showGridLines: Bool { get set }
    var colorScheme: ChartColorScheme { get set }
}

public enum LegendPosition: String, Codable, Sendable, CaseIterable {
    case top
    case bottom
    case left
    case right
    case none
}

public enum ChartColorScheme: String, Codable, Sendable, CaseIterable {
    case `default`
    case colorful
    case monochrome
    case gradient
    case custom
}

public struct ChartData: Codable, Sendable, Hashable {
    public let labels: [String]
    public let series: [ChartSeries]
    public let xAxisTitle: String?
    public let yAxisTitle: String?
    
    public init(labels: [String], series: [ChartSeries], xAxisTitle: String? = nil, yAxisTitle: String? = nil) {
        self.labels = labels
        self.series = series
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
    }
}

public struct ChartSeries: Codable, Sendable, Hashable {
    public let name: String
    public let values: [Double]
    public let color: Color?
    
    public init(name: String, values: [Double], color: Color? = nil) {
        self.name = name
        self.values = values
        self.color = color
    }
}

@available(macOS 10.15, *)
public extension ChartElement {
    var hasMultipleSeries: Bool {
        data.series.count > 1
    }
    
    var seriesCount: Int {
        data.series.count
    }
    
    var dataPointCount: Int {
        data.labels.count
    }
}
