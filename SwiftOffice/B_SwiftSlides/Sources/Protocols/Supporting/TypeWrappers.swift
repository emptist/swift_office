import Foundation

// MARK: - Lightweight Type Wrappers
// These wrappers allow users to write simple property declarations
// while providing semantic type information for the rendering system.

public struct SlideImage: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let path: String
    
    public init(stringLiteral value: String) {
        self.path = value
    }
    
    public init(_ path: String) {
        self.path = path
    }
}

public struct SlideVideo: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let path: String
    
    public init(stringLiteral value: String) {
        self.path = value
    }
    
    public init(_ path: String) {
        self.path = path
    }
}

public struct SlideAudio: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let path: String
    
    public init(stringLiteral value: String) {
        self.path = value
    }
    
    public init(_ path: String) {
        self.path = path
    }
}

public struct SlideURL: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let urlString: String
    
    public init(stringLiteral value: String) {
        self.urlString = value
    }
    
    public init(_ string: String) {
        self.urlString = string
    }
    
    public var url: URL? {
        URL(string: urlString)
    }
}

public struct SlideHexColor: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let hex: String
    
    public init(stringLiteral value: String) {
        self.hex = value
    }
    
    public init(_ hex: String) {
        self.hex = hex
    }
}

public struct SlideSimpleChart: Sendable, Codable, Hashable {
    public let type: ChartType
    public let data: [[String]]
    
    public init(type: ChartType, data: [[String]]) {
        self.type = type
        self.data = data
    }
}

public struct SlideQRCode: ExpressibleByStringLiteral, Sendable, Codable, Hashable {
    public let content: String
    
    public init(stringLiteral value: String) {
        self.content = value
    }
    
    public init(_ content: String) {
        self.content = content
    }
}

// MARK: - Convenience Type Aliases

public typealias Image = SlideImage
public typealias Video = SlideVideo
public typealias Audio = SlideAudio
public typealias URLString = SlideURL
public typealias HexColor = SlideHexColor
public typealias QRCode = SlideQRCode
