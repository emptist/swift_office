import Foundation

@available(macOS 10.15, *)
public protocol ImageElement: SlideElement {
    var source: ImageSource { get set }
    var altText: String { get set }
    var fitMode: ImageFitMode { get set }
    var opacity: Double { get set }
    var hyperlink: URL? { get set }
}

public enum ImageSource: Codable, Sendable, Hashable {
    case file(path: String)
    case remote(url: URL)
    case data(Data)
    case named(String)
    case system(String)
}

public enum ImageFitMode: String, Codable, Sendable, CaseIterable {
    case fill
    case fit
    case stretch
    case tile
    case center
}

@available(macOS 10.15, *)
public extension ImageElement {
    var aspectRatio: Double? {
        guard size.height > 0 else { return nil }
        return size.width / size.height
    }
    
    var isRemote: Bool {
        if case .remote = source { return true }
        return false
    }
    
    var isLocal: Bool {
        if case .file = source { return true }
        if case .data = source { return true }
        if case .named = source { return true }
        return false
    }
}
