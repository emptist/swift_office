import Foundation

public struct DebugOptions: Sendable {
    public var verbose: Bool
    public var keepTempFiles: Bool
    public var printScriptOutput: Bool
    public var timeoutSeconds: Double
    
    public init(
        verbose: Bool = false,
        keepTempFiles: Bool = false,
        printScriptOutput: Bool = false,
        timeoutSeconds: Double = 30.0
    ) {
        self.verbose = verbose
        self.keepTempFiles = keepTempFiles
        self.printScriptOutput = printScriptOutput
        self.timeoutSeconds = timeoutSeconds
    }
}

@available(macOS 10.15, *)
public actor NodeJSBridge: Sendable {
    public let scriptsPath: URL
    public var debug: DebugOptions
    private let nodePath: String
    
    public init(scriptsPath: URL, debug: DebugOptions = .init()) throws {
        self.scriptsPath = scriptsPath
        self.debug = debug
        self.nodePath = try Self.findNodePath()
    }
    
    public init(scriptsPath: String, debug: DebugOptions = .init()) throws {
        self.scriptsPath = URL(fileURLWithPath: scriptsPath)
        self.debug = debug
        self.nodePath = try Self.findNodePath()
    }
    
    private static func findNodePath() throws -> String {
        let searchPaths = [
            "/usr/local/bin/node",
            "/opt/homebrew/bin/node",
            "/usr/bin/node",
            "/opt/nodejs/bin/node"
        ]
        
        for path in searchPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["node"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
            return path
        }
        
        throw SwiftSlidesError.nodeNotFound
    }
    
    @discardableResult
    public func executeScript(
        _ scriptName: String,
        params: [String: any Sendable & Codable] = [:]
    ) async throws -> [String: any Sendable] {
        let scriptURL = scriptsPath.appendingPathComponent("\(scriptName).js")
        
        guard FileManager.default.fileExists(atPath: scriptURL.path) else {
            throw SwiftSlidesError.scriptNotFound(path: scriptURL.path)
        }
        
        if debug.verbose {
            print("Execute script: \(scriptURL.path)")
            print("Params: \(params)")
        }
        
        let inputData = try JSONSerialization.data(withJSONObject: params)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: nodePath)
        process.arguments = [scriptURL.path]
        
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        
        inputPipe.fileHandleForWriting.write(inputData)
        try inputPipe.fileHandleForWriting.close()
        
        let timeout = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(debug.timeoutSeconds * 1000))
        
        while process.isRunning {
            if DispatchTime.now() > timeout {
                process.terminate()
                throw SwiftSlidesError.timeout(script: scriptName, seconds: debug.timeoutSeconds)
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        let completionStatus = process.terminationReason
        let exitCode = process.terminationStatus
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        if debug.printScriptOutput {
            print("stdout: \(outputString)")
            if !errorString.isEmpty {
                print("stderr: \(errorString)")
            }
        }
        
        guard completionStatus == .exit, exitCode == 0 else {
            throw SwiftSlidesError.scriptExecutionFailed(
                script: scriptName,
                exitCode: Int(exitCode),
                output: outputString,
                errorOutput: errorString
            )
        }
        
        guard !outputData.isEmpty else {
            return [:]
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: outputData) as? [String: any Sendable] else {
                throw SwiftSlidesError.dataFormatError(
                    expected: "[String: Any]",
                    actual: "Non-dictionary type"
                )
            }
            
            if debug.verbose {
                print("Result: \(json)")
            }
            
            return json
        } catch let error as SwiftSlidesError {
            throw error
        } catch {
            throw SwiftSlidesError.jsonParseFailed(
                rawData: outputString,
                reason: error.localizedDescription
            )
        }
    }
    
    public func executeCustomScript(
        path: String,
        params: [String: any Sendable & Codable] = [:]
    ) async throws -> [String: any Sendable] {
        let scriptURL = URL(fileURLWithPath: path)
        let scriptName = scriptURL.deletingPathExtension().lastPathComponent
        let scriptDir = scriptURL.deletingLastPathComponent()
        
        let tempBridge = try NodeJSBridge(scriptsPath: scriptDir, debug: debug)
        return try await tempBridge.executeScript(scriptName, params: params)
    }
}
