import Foundation

// MARK: - SwiftOffice Main API

public enum SwiftOffice {
    
    // MARK: - File Operations
    
    public static func readJSON(from path: String) -> [String: Any]? {
        let handler = JSONSimpleHandler(basename: path)
        return handler.readFromJSON(filename: path)
    }
    
    public static func writeJSON(_ data: [String: Any], to path: String) {
        let handler = JSONSimpleHandler(basename: path)
        handler.writeToJSON(data, filename: path)
    }
    
    // MARK: - Database Operations
    
    public static let database = DatabaseHandler()
    
    // MARK: - Entity Access
    
    public static var 别名库: 别名库V3 {
        return .shared
    }
    
    public static var 名字ID库: 名字ID库V3 {
        return .shared
    }
    
    public static var 简称库: 简称库V3 {
        return .shared
    }
    
    public static var 自制别名库: 自制别名库V3 {
        return .shared
    }
    
    // MARK: - PPT Generation
    
    // NOTE: Only pptxgenjs is supported. The officegen package was evaluated but contains bugs.
    // The original CoffeeScript implementation (hqcoffee) uses pptxgenjs exclusively.
    // See: https://github.com/gitbrent/PptxGenJS
    
    @available(macOS 10.15, *)
    public static func createPPT(
        slides: [[String: Any]],
        outputPath: String
    ) async throws {
        let bridge = try NodeJSBridge(
            scriptsPath: URL(fileURLWithPath: "./Scripts")
        )
        
        let slidesJSON = try JSONSerialization.data(withJSONObject: slides)
        let slidesString = String(data: slidesJSON, encoding: .utf8) ?? "[]"
        
        let params: [String: any Sendable & Codable] = [
            "action": "save",
            "path": outputPath,
            "slidesJSON": slidesString
        ]
        
        _ = try await bridge.executeScript("pptx", params: params)
    }
    
    // MARK: - Excel Operations
    
    @available(macOS 10.15, *)
    public static func readExcel(
        path: String,
        header: [String: Any] = ["rows": 1],
        columnToKey: [String: String] = ["*": "{{columnHeader}}"]
    ) async throws -> [String: Any] {
        let bridge = try NodeJSBridge(
            scriptsPath: URL(fileURLWithPath: "./Scripts")
        )
        
        let headerJSON = try JSONSerialization.data(withJSONObject: header)
        let headerString = String(data: headerJSON, encoding: .utf8) ?? "{}"
        
        let columnToKeyJSON = try JSONSerialization.data(withJSONObject: columnToKey)
        let columnToKeyString = String(data: columnToKeyJSON, encoding: .utf8) ?? "{}"
        
        let params: [String: any Sendable & Codable] = [
            "path": path,
            "headerJSON": headerString,
            "columnToKeyJSON": columnToKeyString
        ]
        
        let result = try await bridge.executeScript("readExcel", params: params)
        return result["data"] as? [String: Any] ?? [:]
    }
    
    @available(macOS 10.15, *)
    public static func writeExcel(
        fileName: String,
        data: [[String: Any]],
        extraLength: Int = 5
    ) async throws -> String {
        let bridge = try NodeJSBridge(
            scriptsPath: URL(fileURLWithPath: "./Scripts")
        )
        
        let params: [String: any Sendable & Codable] = [
            "fileName": fileName,
            "data": data,
            "extraLength": extraLength
        ]
        
        let result = try await bridge.executeScript("writeExcel", params: params)
        
        if let success = result["success"] as? Bool, success {
            return result["fileName"] as? String ?? "\(fileName).xlsx"
        } else {
            let error = result["error"] as? String ?? "Unknown error"
            throw SwiftOfficeError.excelGenerationFailed(error)
        }
    }
    
    @available(macOS 10.15, *)
    public static func writeExcelSheets(
        fileName: String,
        sheets: [ExcelSheet],
        extraLength: Int = 5
    ) async throws -> String {
        let data = sheets.map { $0.toDict() }
        return try await writeExcel(fileName: fileName, data: data, extraLength: extraLength)
    }
}

// MARK: - Excel Sheet Model

public struct ExcelSheet {
    public let sheet: String
    public let columns: [ExcelColumn]
    public let content: [[String: Any]]
    
    public init(sheet: String, columns: [ExcelColumn], content: [[String: Any]]) {
        self.sheet = sheet
        self.columns = columns
        self.content = content
    }
    
    public func toDict() -> [String: Any] {
        [
            "sheet": sheet,
            "columns": columns.map { $0.toDict() },
            "content": content
        ]
    }
}

public struct ExcelColumn {
    public let label: String
    public let value: String
    
    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    public func toDict() -> [String: String] {
        ["label": label, "value": value]
    }
}

// MARK: - PPT Generator Types

// NOTE: Only pptxgenjs is actively supported. The officegen package was evaluated but contains bugs.
// The officegen case is kept for documentation purposes only.
// The original CoffeeScript implementation (hqcoffee) uses pptxgenjs exclusively.

public enum PPTGenerator: String, Sendable {
    case pptxgen = "pg"      // Active: https://github.com/gitbrent/PptxGenJS
    case officegen = "og"    // DEPRECATED: Contains bugs, not recommended
}

// MARK: - Convenience Extensions

@available(macOS 10.15, *)
public extension SwiftOffice {
    
    static func makeReport(
        title: String,
        sections: [[String: Any]],
        outputPath: String
    ) async throws {
        var slides: [[String: Any]] = [
            ["title": title, "content": ""]
        ]
        slides.append(contentsOf: sections)
        
        try await createPPT(slides: slides, outputPath: outputPath)
    }
}
