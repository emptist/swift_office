import Foundation

public enum SwiftSlidesError: Error, LocalizedError {
    case nodeNotFound
    case scriptNotFound(path: String)
    case timeout(script: String, seconds: Double)
    case scriptExecutionFailed(script: String, exitCode: Int, output: String, errorOutput: String)
    case dataFormatError(expected: String, actual: String)
    case jsonParseFailed(rawData: String, reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .nodeNotFound:
            return "Node.js not found. Please install Node.js."
        case .scriptNotFound(let path):
            return "Script not found: \(path)"
        case .timeout(let script, let seconds):
            return "Script '\(script)' timed out after \(seconds) seconds"
        case .scriptExecutionFailed(let script, let exitCode, let output, let errorOutput):
            return "Script '\(script)' failed with exit code \(exitCode). Output: \(output). Error: \(errorOutput)"
        case .dataFormatError(let expected, let actual):
            return "Data format error: expected \(expected), got \(actual)"
        case .jsonParseFailed(let rawData, let reason):
            return "Failed to parse JSON: \(reason). Raw data: \(rawData)"
        }
    }
}
