import Foundation

// MARK: - 安全规则
// 内容安全检查与风险标记（占位符实现）

public final class SafetyRules {
    
    /// 单例
    public static let shared = SafetyRules()
    
    private init() {}
    
    // MARK: - 禁止词列表（占位符）
    
    private let bannedPatterns: [String] = [
        "油腻", "亲爱的", "宝贝儿",  // 过于亲密
        "一定", "保证", "承诺",      // 过度承诺
        "AI", "人工智能", "模型",    // AI 相关
    ]
    
    // MARK: - 内容检查
    
    /// 检查生成内容是否安全
    /// - Returns: (是否安全, 修正后的内容, 风险说明)
    public func check(_ text: String) -> (safe: Bool, corrected: String, reason: String?) {
        let corrected = text
        var reasons: [String] = []
        
        // 检查禁止词
        for pattern in bannedPatterns {
            if corrected.contains(pattern) {
                // 这里只做标记，不做自动替换
                // 实际实现可能需要调用模型重新生成
                reasons.append("包含不推荐用语")
                break
            }
        }
        
        // 检查长度
        if corrected.count > 200 {
            reasons.append("内容过长")
        }
        
        // 检查是否包含网址/联系方式（可选）
        if containsContactInfo(corrected) {
            reasons.append("包含联系方式")
        }
        
        let isSafe = reasons.isEmpty
        return (isSafe, corrected, reasons.isEmpty ? nil : reasons.joined(separator: "、"))
    }
    
    /// 检查是否包含联系方式
    private func containsContactInfo(_ text: String) -> Bool {
        // 简单的正则检查（占位符）
        let patterns = [
            "\\d{11}",  // 手机号
            "\\d{5,}@", // 邮箱数字部分
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
                return true
            }
        }
        return false
    }
    
    // MARK: - 候选过滤
    
    /// 过滤候选列表，标记风险内容
    public func filter(_ candidates: [Candidate]) -> [Candidate] {
        return candidates.map { candidate in
            let (safe, _, _) = check(candidate.text)
            var filtered = candidate
            filtered.riskFlagged = !safe
            return filtered
        }
    }
}
