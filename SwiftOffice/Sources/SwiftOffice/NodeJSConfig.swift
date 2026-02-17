import Foundation

public struct NodeJSConfig: Sendable {
    public var nodePath: String?
    public var scriptsPath: URL?
    
    public init(nodePath: String? = nil, scriptsPath: URL? = nil) {
        self.nodePath = nodePath
        self.scriptsPath = scriptsPath
    }
    
    public func resolveNodePath() throws -> String {
        if let custom = nodePath {
            if FileManager.default.isExecutableFile(atPath: custom) {
                return custom
            }
            throw SwiftOfficeError.invalidConfig(reason: "Invalid custom Node.js path: \(custom)")
        }
        
        return try Self.autoFindNodePath()
    }
    
    public static func autoFindNodePath() throws -> String {
        let searchPaths = [
            "/opt/homebrew/bin/node",
            "/usr/local/bin/node",
            "/usr/bin/node",
            "/opt/local/bin/node",
        ]
        
        for path in searchPaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                return path
            }
        }
        
        if let whichResult = try? executeWhichCommand() {
            return whichResult
        }
        
        throw SwiftOfficeError.nodeNotFound(searchPaths: searchPaths)
    }
    
    private static func executeWhichCommand() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "which node"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            return ""
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return output.isEmpty ? "" : output
    }
    
    public static var version: String? {
        guard let path = try? autoFindNodePath() else { return nil }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["--version"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try? process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
