import Foundation

// MARK: - 候选文本模型
// 表示生成的候选回复/开场白/润色结果

/// 候选文本
public struct Candidate: Codable, Identifiable, Equatable {
    /// 唯一标识符
    public let id: UUID
    
    /// 生成的文本内容
    public var text: String
    
    /// 评分 (0-100)
    public var score: Int
    
    /// 标签（来源于生成时的配置）
    public var tags: [String]
    
    /// 生成时间
    public let createdAt: Date
    
    /// 是否为离线模板
    public var isOfflineTemplate: Bool
    
    /// 风险标记（如果内容被判定需要保守处理）
    public var riskFlagged: Bool
    
    public init(
        id: UUID = UUID(),
        text: String,
        score: Int = 50,
        tags: [String] = [],
        createdAt: Date = Date(),
        isOfflineTemplate: Bool = false,
        riskFlagged: Bool = false
    ) {
        self.id = id
        self.text = text
        self.score = min(100, max(0, score))
        self.tags = tags
        self.createdAt = createdAt
        self.isOfflineTemplate = isOfflineTemplate
        self.riskFlagged = riskFlagged
    }
}

// MARK: - 候选列表
public struct CandidateList: Codable, Equatable {
    /// 候选列表
    public var candidates: [Candidate]
    
    /// 生成规格
    public var spec: GenSpec
    
    /// 生成时间
    public let generatedAt: Date
    
    public init(
        candidates: [Candidate],
        spec: GenSpec,
        generatedAt: Date = Date()
    ) {
        self.candidates = candidates
        self.spec = spec
        self.generatedAt = generatedAt
    }
    
    /// 空列表
    public static var empty: CandidateList {
        return CandidateList(
            candidates: [],
            spec: GenSpec(intent: .reply)
        )
    }
}

// MARK: - 离线模板候选（占位符）
public extension Candidate {
    /// 获取离线模板候选（用于无网络/无权限时）
    static func offlineTemplates(for intent: GenerationIntent) -> [Candidate] {
        switch intent {
        case .reply:
            return [
                Candidate(text: "好的呀～", tags: ["常用"], isOfflineTemplate: true),
                Candidate(text: "哈哈确实是这样", tags: ["常用"], isOfflineTemplate: true),
                Candidate(text: "那你加油呀！", tags: ["鼓励"], isOfflineTemplate: true)
            ]
        case .opener:
            return [
                Candidate(text: "嗨～在忙什么呢？", tags: ["万能开场"], isOfflineTemplate: true),
                Candidate(text: "好久不见，最近怎么样？", tags: ["刚加好友"], isOfflineTemplate: true),
                Candidate(text: "今天天气不错呀～", tags: ["万能开场"], isOfflineTemplate: true)
            ]
        case .polish:
            return [
                Candidate(text: "（请先输入你想润色的内容）", tags: ["提示"], isOfflineTemplate: true)
            ]
        }
    }
}
