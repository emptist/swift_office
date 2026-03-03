import SwiftUI
import AppKit

@available(macOS 13.0, *)
public enum Gantt渲染器 {
    @MainActor
    public static func 渲染图片(_ 图表: Gantt图表, 宽度: CGFloat = 900, 高度: CGFloat = 500, 缩放: CGFloat = 2.0) throws -> Data {
        let view = Gantt图表视图(图表: 图表, 宽度: 宽度, 高度: 高度)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 缩放
        
        guard let tiffData = renderer.nsImage?.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw GanttError.imageGenerationFailed
        }
        
        return pngData
    }
    
    @MainActor
    public static func 渲染图片带尺寸(_ 图表: Gantt图表, 宽度: CGFloat = 900, 高度: CGFloat = 500, 缩放: CGFloat = 2.0) throws -> (data: Data, width: Int, height: Int) {
        let data = try 渲染图片(图表, 宽度: 宽度, 高度: 高度, 缩放: 缩放)
        return (data, Int(宽度 * 缩放), Int(高度 * 缩放))
    }
    
    @MainActor
    public static func 保存图片(_ 图表: Gantt图表, 路径: String, 宽度: CGFloat = 900, 高度: CGFloat = 500) throws {
        let data = try 渲染图片(图表, 宽度: 宽度, 高度: 高度)
        let 目录 = (路径 as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: 目录, withIntermediateDirectories: true)
        try data.write(to: URL(fileURLWithPath: 路径))
    }
    
    public static func 同步渲染(_ 图表: Gantt图表, 宽度: CGFloat = 900, 高度: CGFloat = 500, 缩放: CGFloat = 2.0) -> (data: Data, width: Int, height: Int)? {
        var result: Data?
        if Thread.isMainThread {
            result = try? MainActor.assumeIsolated {
                try 渲染图片(图表, 宽度: 宽度, 高度: 高度, 缩放: 缩放)
            }
        } else {
            DispatchQueue.main.sync {
                result = try? 渲染图片(图表, 宽度: 宽度, 高度: 高度, 缩放: 缩放)
            }
        }
        guard let data = result else { return nil }
        return (data, Int(宽度 * 缩放), Int(高度 * 缩放))
    }
}

public enum GanttError: Error, LocalizedError {
    case imageGenerationFailed
    
    public var errorDescription: String? {
        switch self {
        case .imageGenerationFailed:
            return "Failed to generate Gantt chart image"
        }
    }
}
