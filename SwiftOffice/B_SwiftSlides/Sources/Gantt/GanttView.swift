import SwiftUI
import AppKit

@available(macOS 13.0, *)
public struct Gantt图表视图: View {
    let 图表: Gantt图表
    let 宽度: CGFloat
    let 高度: CGFloat
    
    public init(图表: Gantt图表, 宽度: CGFloat = 900, 高度: CGFloat = 500) {
        self.图表 = 图表
        self.宽度 = 宽度
        self.高度 = 高度
    }
    
    private let 日期格式: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()
    
    private let 任务高度: CGFloat = 36
    private let 左侧标签宽度: CGFloat = 120
    private let 顶部日期高度: CGFloat = 30
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !图表.标题.isEmpty {
                Text(图表.标题)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 12)
            }
            
            HStack(alignment: .top, spacing: 0) {
                任务名称列
                Divider().frame(width: 1)
                图表主体
            }
        }
        .frame(width: 宽度, height: 高度)
        .background(.white)
    }
    
    private var 任务名称列: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 顶部日期高度)
            
            ForEach(Array(图表.任务列表.enumerated()), id: \.offset) { _, 任务 in
                Text(任务.名称)
                    .font(.system(size: 12))
                    .frame(width: 左侧标签宽度 - 10, height: 任务高度, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
        .frame(width: 左侧标签宽度)
    }
    
    private var 图表主体: some View {
        VStack(alignment: .leading, spacing: 0) {
            if 图表.显示日期 {
                日期行
            }
            
            ForEach(Array(图表.任务列表.enumerated()), id: \.offset) { index, 任务 in
                任务条(任务: 任务, 序号: index)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var 日期行: some View {
        HStack(spacing: 0) {
            if let 开始 = 图表.最早开始 {
                let 天数 = 图表.总天数
                let 列宽 = (宽度 - 左侧标签宽度 - 20) / CGFloat(max(天数, 1))
                
                ForEach(0..<天数, id: \.self) { i in
                    if let 日期 = Calendar.current.date(byAdding: .day, value: i, to: 开始) {
                        Text(日期格式.string(from: 日期))
                            .font(.system(size: 10))
                            .frame(width: 列宽, height: 顶部日期高度)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(height: 顶部日期高度)
    }
    
    private func 任务条(任务: Gantt任务, 序号: Int) -> some View {
        GeometryReader { geometry in
            let 可用宽度 = geometry.size.width
            let 总天数 = CGFloat(max(图表.总天数, 1))
            let 开始偏移 = CGFloat(任务开始偏移(任务))
            let 任务宽度 = CGFloat(任务.持续天数) / 总天数 * 可用宽度
            let 条左边 = 开始偏移 / 总天数 * 可用宽度
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(序号 % 2 == 0 ? .gray.opacity(0.1) : .white)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(任务颜色(任务))
                    .frame(width: max(任务宽度, 2), height: 任务高度 - 8)
                    .offset(x: 条左边)
                    .overlay(
                        GeometryReader { geo in
                            if let 进度 = 任务.进度, 进度 > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.3))
                                    .frame(width: geo.size.width * CGFloat(进度))
                            }
                        }
                    )
            }
        }
        .frame(height: 任务高度)
    }
    
    private func 任务开始偏移(_ 任务: Gantt任务) -> Int {
        guard let 最早 = 图表.最早开始 else { return 0 }
        return Calendar.current.dateComponents([.day], from: 最早, to: 任务.开始日期).day ?? 0
    }
    
    private func 任务颜色(_ 任务: Gantt任务) -> SwiftUI.Color {
        if let 颜色代码 = 任务.颜色 {
            return Color从十六进制(颜色代码)
        }
        let 默认颜色: [SwiftUI.Color] = [
            Color从十六进制("007AFF"),
            Color从十六进制("34C759"),
            Color从十六进制("FF9500"),
            Color从十六进制("AF52DE"),
            Color从十六进制("FF2D55"),
            Color从十六进制("5AC8FA"),
            Color从十六进制("5856D6"),
            Color从十六进制("00C7BE")
        ]
        let index = 图表.任务列表.firstIndex { $0.名称 == 任务.名称 } ?? 0
        return 默认颜色[index % 默认颜色.count]
    }
    
    private func Color从十六进制(_ hex: String) -> SwiftUI.Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let length = hexSanitized.count
        if length == 6 {
            return SwiftUI.Color(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else {
            return SwiftUI.Color.blue
        }
    }
}
