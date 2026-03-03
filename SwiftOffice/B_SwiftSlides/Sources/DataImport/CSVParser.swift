import Foundation

@available(macOS 10.15, *)
public enum CSV解析器: 数据导入器 {
    case shared
    
    public func 导入(路径: String) throws -> 表格数据 {
        let 内容 = try String(contentsOfFile: 路径, encoding: .utf8)
        return try 解析CSV(内容)
    }
    
    public func 导入(内容: String, 格式: 数据格式) throws -> 表格数据 {
        switch 格式 {
        case .csv:
            return try 解析CSV(内容)
        case .tsv:
            return try 解析TSV(内容)
        case .json:
            return try 解析JSON(内容)
        }
    }
    
    private func 解析CSV(_ 内容: String) throws -> 表格数据 {
        let 行 = 内容.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !行.isEmpty else {
            throw 数据导入错误.空文件
        }
        
        let 列名 = 解析行(行[0])
        let 行数据 = 行.dropFirst().map { 解析行($0) }
        
        return 表格数据(列名: 列名, 行数据: 行数据)
    }
    
    private func 解析TSV(_ 内容: String) throws -> 表格数据 {
        let 行 = 内容.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !行.isEmpty else {
            throw 数据导入错误.空文件
        }
        
        let 列名 = 行[0].components(separatedBy: "\t")
        let 行数据 = 行.dropFirst().map { $0.components(separatedBy: "\t") }
        
        return 表格数据(列名: 列名, 行数据: 行数据)
    }
    
    private func 解析JSON(_ 内容: String) throws -> 表格数据 {
        guard let 数据 = try JSONSerialization.jsonObject(with: 内容.data(using: .utf8)!) as? [[String: Any]] else {
            throw 数据导入错误.无效格式
        }
        
        guard !数据.isEmpty else {
            throw 数据导入错误.空文件
        }
        
        let 列名 = Array(数据[0].keys)
        let 行数据 = 数据.map { 行 in
            列名.map { 列 in
                (行[列] as? String) ?? "\(行[列] ?? "")"
            }
        }
        
        return 表格数据(列名: 列名, 行数据: 行数据)
    }
    
    private func 解析行(_ 行: String) -> [String] {
        var 结果: [String] = []
        var 当前 = ""
        var 在引号内 = false
        
        for 字符 in 行 {
            if 字符 == "\"" {
                在引号内.toggle()
            } else if 字符 == "," && !在引号内 {
                结果.append(当前.trimmingCharacters(in: .whitespaces))
                当前 = ""
            } else {
                当前.append(字符)
            }
        }
        结果.append(当前.trimmingCharacters(in: .whitespaces))
        
        return 结果
    }
}

@available(macOS 10.15, *)
public enum 数据导入错误: Error, LocalizedError {
    case 空文件
    case 无效格式
    case 文件不存在
    case 编码错误
    
    public var errorDescription: String? {
        switch self {
        case .空文件: return "文件为空"
        case .无效格式: return "文件格式无效"
        case .文件不存在: return "文件不存在"
        case .编码错误: return "文件编码错误"
        }
    }
}

@available(macOS 10.15, *)
public extension 表格数据 {
    static func 从CSV(路径: String) throws -> 表格数据 {
        try CSV解析器.shared.导入(路径: 路径)
    }
    
    static func 从CSV内容(_ 内容: String) throws -> 表格数据 {
        try CSV解析器.shared.导入(内容: 内容, 格式: .csv)
    }
    
    static func 从TSV(路径: String) throws -> 表格数据 {
        let 内容 = try String(contentsOfFile: 路径, encoding: .utf8)
        return try CSV解析器.shared.导入(内容: 内容, 格式: .tsv)
    }
    
    static func 从JSON(路径: String) throws -> 表格数据 {
        let 内容 = try String(contentsOfFile: 路径, encoding: .utf8)
        return try CSV解析器.shared.导入(内容: 内容, 格式: .json)
    }
}
