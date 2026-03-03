import Foundation

@available(macOS 10.15, *)
public protocol Presentation: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get set }
    var author: String? { get set }
    var sections: [any Section] { get set }
    var theme: 主题? { get set }
}

@available(macOS 10.15, *)
public extension Presentation {
    var id: UUID { UUID() }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
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
    
    func toPPTX(outputPath: String? = nil) async throws {
        let bridge = try NodeJSBridge(scriptsPath: URL(fileURLWithPath: "./Scripts"))
        
        let presentationJSON = try toJSON()
        
        let params: [String: any Sendable & Codable] = [
            "presentation": presentationJSON,
            "outputPath": outputPath ?? "\(title).pptx"
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
}

@available(macOS 10.15, *)
public struct 演示文稿: Presentation {
    public let id = UUID()
    public var title: String
    public var author: String?
    public var sections: [any Section]
    public var theme: 主题?
    
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

// 添加 generatePPTX 作为 toPPTX 的别名，方便使用
@available(macOS 10.15, *)
public extension Presentation {
    func generatePPTX(outputPath: String) async throws {
        try await toPPTX(outputPath: outputPath)
    }
}
