import Foundation

// MARK: - 生成规格模型
// 定义每次生成请求的完整参数规格

/// 生成意图（主模式）
public enum GenerationIntent: String, Codable {
    case reply = "reply"       // 帮你回
    case opener = "opener"     // 帮开场
    case polish = "polish"     // 帮润色
}

/// 语气/风格标签
public enum ToneTag: String, Codable, CaseIterable {
    // Reply 模式标签
    case common = "常用回法"
    case highEQ = "高情商"
    case flirty = "暧昧"
    case politeRefuse = "礼貌拒绝"
    case professional = "职场"
    
    // Opener 模式标签
    case generalOpener = "万能开场"
    case newFriend = "刚加好友"
    case whatUp = "在干嘛"
    case askOut = "想约人"
    case afterDate = "相亲后"
    
    // Polish 模式标签
    case moreNatural = "更自然"
    case moreHumorous = "更幽默"
    case moreFormal = "更正式"
    case shorter = "更短"
    case heartfelt = "更走心"
    
    /// 获取适用于指定意图的标签列表
    public static func tags(for intent: GenerationIntent) -> [ToneTag] {
        switch intent {
        case .reply:
            return [.common, .highEQ, .flirty, .politeRefuse, .professional]
        case .opener:
            return [.generalOpener, .newFriend, .whatUp, .askOut, .afterDate]
        case .polish:
            return [.moreNatural, .moreHumorous, .moreFormal, .shorter, .heartfelt]
        }
    }
}

/// 生成规格（每次生成请求的完整参数）
public struct GenSpec: Codable, Equatable {
    /// 生成意图
    public var intent: GenerationIntent
    
    /// 选中的语气标签
    public var toneTag: ToneTag
    
    /// 暧昧等级 (1-5)
    public var flirtLevel: FlirtLevel
    
    /// 风险等级
    public var riskLevel: RiskLevel
    
    /// 表情密度
    public var emojiLevel: EmojiLevel
    
    /// 字数偏好
    public var lengthPreference: LengthPreference
    
    /// 生成候选数量
    public var candidateCount: Int
    
    /// 聊天上下文（最近几条消息）
    public var chatContext: String?
    
    /// 对方最新一句话
    public var lastMessage: String?
    
    /// 原话（润色模式使用）
    public var rawText: String?
    
    public init(
        intent: GenerationIntent,
        toneTag: ToneTag? = nil,
        flirtLevel: FlirtLevel = 2,
        riskLevel: RiskLevel = .natural,
        emojiLevel: EmojiLevel = .few,
        lengthPreference: LengthPreference = .medium,
        candidateCount: Int = 3,
        chatContext: String? = nil,
        lastMessage: String? = nil,
        rawText: String? = nil
    ) {
        self.intent = intent
        self.toneTag = toneTag ?? ToneTag.tags(for: intent).first ?? .common
        self.flirtLevel = min(5, max(1, flirtLevel))
        self.riskLevel = riskLevel
        self.emojiLevel = emojiLevel
        self.lengthPreference = lengthPreference
        self.candidateCount = min(5, max(1, candidateCount))
        self.chatContext = chatContext
        self.lastMessage = lastMessage
        self.rawText = rawText
    }
    
    /// 从用户配置创建生成规格
    public static func from(
        identity: UserIdentity,
        style: StyleProfile,
        intent: GenerationIntent,
        toneTag: ToneTag? = nil
    ) -> GenSpec {
        return GenSpec(
            intent: intent,
            toneTag: toneTag,
            flirtLevel: style.defaultFlirtLevel,
            riskLevel: style.riskLevel,
            emojiLevel: style.emojiLevel,
            lengthPreference: style.lengthPreference,
            candidateCount: style.candidateCount
        )
    }
}
