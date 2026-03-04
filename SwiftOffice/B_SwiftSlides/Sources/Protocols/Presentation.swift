import Foundation

// ============================================
// Presentation 协议 - 演示文稿协议
// ============================================
//
// 设计原则：
// 1. 协议用 var { get }，实现用 let
// 2. Presentation 由多个 Section 组成
// 3. 支持 PPTX 生成
// ============================================

@available(macOS 10.15, *)
public protocol Presentation: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var contents: SlideContent { get }
    var author: String? { get }
    var sections: [any Section] { get }
    var theme: 主题? { get }
    func toDict() -> [String: Any]
    func toJSON() throws -> String
    func generatePPTX(outputPath: String) async throws
}

@available(macOS 10.15, *)
public extension Presentation {
    var id: UUID { UUID() }
    var contents: SlideContent { SlideContent([:]) }
    var author: String? { contents["Author"]?.asString }
    var theme: 主题? { nil }
    
    var sections: [any Section] {
        contents.asSectionArray
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "contents": contents.toJSONDict(),
            "sections": sections.map { $0.toDict() }
        ]
        if let author = author { dict["author"] = author }
        if let theme = theme { dict["theme"] = theme.toDict() }
        return dict
    }
    
    func toJSON() throws -> String {
        let dict = toDict()
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    func generatePPTX(outputPath: String) async throws {
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let scriptsPath = URL(fileURLWithPath: currentPath)
            .appendingPathComponent("B_SwiftSlides/Scripts")
        
        let bridge = try NodeJSBridge(scriptsPath: scriptsPath)
        let presentationJSON = try toJSON()
        let params: [String: any Sendable & Codable] = [
            "presentation": presentationJSON,
            "outputPath": outputPath
        ]
        let result = try await bridge.executeScript("swiftslides-pptx", params: params)
        guard let success = result["success"] as? Bool, success else {
            throw SwiftSlidesError.scriptExecutionFailed(
                script: "swiftslides-pptx",
                exitCode: 1,
                output: "",
                errorOutput: result["error"] as? String ?? "Unknown error"
            )
        }
    }
    
    func allSlides() -> [any Slide] {
        sections.flatMap { $0.flattenSlides() }
    }
}

// MARK: - 默认实现

@available(macOS 10.15, *)
public struct 演示文稿: Presentation {
    public let id = UUID()
    public let title: String
    public let author: String?
    public let sections: [any Section]
    public let theme: 主题?
    
    public init(
        标题: String,
        作者: String? = nil,
        主题: 主题? = nil,
        sections: [any Section] = []
    ) {
        self.title = 标题
        self.author = 作者
        self.theme = 主题
        self.sections = sections
    }
}

@available(macOS 10.15, *)
public typealias PresentationBase = 演示文稿
