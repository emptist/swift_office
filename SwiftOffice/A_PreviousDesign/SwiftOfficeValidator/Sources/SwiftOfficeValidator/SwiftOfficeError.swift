import Foundation

public enum SwiftOfficeError: Error, CustomStringConvertible, LocalizedError {
    case nodeNotFound(searchPaths: [String])
    case scriptNotFound(path: String)
    case invalidConfig(reason: String)
    case scriptExecutionFailed(script: String, exitCode: Int, output: String, errorOutput: String)
    case timeout(script: String, seconds: Double)
    case jsonParseFailed(rawData: String, reason: String)
    case dataFormatError(expected: String, actual: String)
    case nodeError(message: String, stack: String?)
    
    public var description: String {
        switch self {
        case .nodeNotFound(let paths):
            return "❌ Node.js not found, searched paths: \(paths.joined(separator: ", "))"
        case .scriptNotFound(let path):
            return "❌ Script not found: \(path)"
        case .invalidConfig(let reason):
            return "❌ Invalid config: \(reason)"
        case .scriptExecutionFailed(let script, let code, let output, let error):
            return """
            ❌ Script execution failed: \(script)
               Exit code: \(code)
               Output: \(output)
               Error: \(error)
            """
        case .timeout(let script, let seconds):
            return "❌ Script timeout: \(script) (\(seconds)s)"
        case .jsonParseFailed(let raw, let reason):
            let preview = String(raw.prefix(200))
            return """
            ❌ JSON parse failed
               Reason: \(reason)
               Raw data (first 200 chars): \(preview)
            """
        case .dataFormatError(let expected, let actual):
            return "❌ Data format error, expected: \(expected), actual: \(actual)"
        case .nodeError(let message, let stack):
            var result = "❌ Node.js error: \(message)"
            if let stack = stack {
                result += "\nStack:\n\(stack)"
            }
            return result
        }
    }
    
    public var errorDescription: String? {
        description
    }
    
    public var reportTemplate: String {
        """
        ## SwiftOffice Error Report
        
        **Error Type**: \(Self.self)
        **Details**: \(self)
        
        **Environment**:
        - OS: \(ProcessInfo.processInfo.operatingSystemVersionString)
        
        **Steps to Reproduce**:
        1. ...
        2. ...
        
        **Expected Behavior**:
        ...
        """
    }
}
