import Foundation

// MARK: - 风格偏好模型
// 定义生成内容的风格参数

/// 表情密度
public enum EmojiLevel: Int, Codable, CaseIterable {
    case none = 0      // 无表情
    case few = 1       // 少量
    case normal = 2    // 适中
    case many = 3      // 较多
    
    public var displayName: String {
        switch self {
        case .none: return "无"
        case .few: return "少"
        case .normal: return "适中"
        case .many: return "多"
        }
    }
}

/// 字数偏好
public enum LengthPreference: String, Codable, CaseIterable {
    case short = "短"
    case medium = "中"
    case long = "长"
    
    public var maxSentences: Int {
        switch self {
        case .short: return 1
        case .medium: return 2
        case .long: return 3
        }
    }
}

/// 风险等级（内容大胆程度）
public enum RiskLevel: String, Codable, CaseIterable {
    case conservative = "保守"
    case natural = "自然"
    case daring = "敢一点"
    
    public var promptValue: String {
        switch self {
        case .conservative: return "low"
        case .natural: return "medium"
        case .daring: return "high"
        }
    }
}

/// 暧昧等级 (1-5)
public typealias FlirtLevel = Int

/// 风格配置
public struct StyleProfile: Codable, Equatable {
    /// 表情密度
    public var emojiLevel: EmojiLevel
    
    /// 字数偏好
    public var lengthPreference: LengthPreference
    
    /// 风险等级
    public var riskLevel: RiskLevel
    
    /// 默认暧昧等级 (1-5)
    public var defaultFlirtLevel: FlirtLevel
    
    /// 默认生成候选数量
    public var candidateCount: Int
    
    public init(
        emojiLevel: EmojiLevel = .few,
        lengthPreference: LengthPreference = .medium,
        riskLevel: RiskLevel = .natural,
        defaultFlirtLevel: FlirtLevel = 2,
        candidateCount: Int = 3
    ) {
        self.emojiLevel = emojiLevel
        self.lengthPreference = lengthPreference
        self.riskLevel = riskLevel
        self.defaultFlirtLevel = min(5, max(1, defaultFlirtLevel))
        self.candidateCount = min(5, max(1, candidateCount))
    }
    
    /// 默认风格配置
    public static let `default` = StyleProfile()
}
