import Foundation

// MARK: - 文本工具
// 通用文本处理工具

public enum TextUtils {
    
    /// 清理文本（去除首尾空白、多余换行）
    public static func clean(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
    }
    
    /// 截断文本到指定长度
    public static func truncate(_ text: String, maxLength: Int, suffix: String = "...") -> String {
        guard text.count > maxLength else { return text }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength - suffix.count)
        return String(text[..<endIndex]) + suffix
    }
    
    /// 统计句子数量（简单实现）
    public static func countSentences(_ text: String) -> Int {
        let delimiters = CharacterSet(charactersIn: "。！？!?.;；")
        return text.components(separatedBy: delimiters)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count
    }
    
    /// 解析模型输出为候选列表
    /// 支持格式：1) xxx  2) xxx 或 每行一条
    public static func parseCandidates(from output: String) -> [String] {
        let cleaned = clean(output)
        
        // 尝试按编号格式解析
        let numberedPattern = #"^\d+[)）\.、]\s*(.+)$"#
        if let regex = try? NSRegularExpression(pattern: numberedPattern, options: .anchorsMatchLines) {
            let matches = regex.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned))
            if !matches.isEmpty {
                return matches.compactMap { match in
                    guard let range = Range(match.range(at: 1), in: cleaned) else { return nil }
                    return String(cleaned[range]).trimmingCharacters(in: .whitespaces)
                }.filter { !$0.isEmpty }
            }
        }
        
        // 按行分割
        let lines = cleaned.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        return lines
    }
    
    /// 检查文本是否为空或只有空白
    public static func isBlank(_ text: String?) -> Bool {
        guard let text = text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
