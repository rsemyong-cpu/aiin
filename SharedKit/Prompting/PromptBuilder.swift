import Foundation

// MARK: - 提示词构建器
// 根据用户配置和操作动态拼装最终 Prompt

public final class PromptBuilder {
    
    private let identity: UserIdentity
    private let style: StyleProfile
    
    public init(identity: UserIdentity, style: StyleProfile) {
        self.identity = identity
        self.style = style
    }
    
    /// 从 AppGroupStore 加载配置创建构建器
    public convenience init() {
        let store = AppGroupStore.store
        self.init(
            identity: store.loadIdentity(),
            style: store.loadStyle()
        )
    }
    
    // MARK: - 构建完整提示词
    
    /// 构建完整的提示词（System + User）
    public func build(spec: GenSpec) -> (system: String, user: String) {
        let systemPrompt = PromptTemplates.masterSystemPrompt
        let userPrompt: String
        
        switch spec.intent {
        case .reply:
            userPrompt = buildReplyPrompt(spec: spec)
        case .opener:
            userPrompt = buildOpenerPrompt(spec: spec)
        case .polish:
            userPrompt = buildPolishPrompt(spec: spec)
        }
        
        return (systemPrompt, userPrompt)
    }
    
    // MARK: - 私有构建方法
    
    private func buildReplyPrompt(spec: GenSpec) -> String {
        return PromptTemplates.replyPrompt(
            candidateCount: spec.candidateCount,
            maxSentences: spec.lengthPreference.maxSentences,
            userStyle: buildStyleDescription(spec: spec),
            flirtLevel: spec.flirtLevel,
            riskLevel: spec.riskLevel.promptValue,
            emojiLevel: spec.emojiLevel.displayName,
            myNickname: identity.displayName,
            myPersona: identity.personaDescription,
            relationshipGoal: identity.relationshipGoal.rawValue,
            tabooList: identity.tabooDescription,
            chatContext: spec.chatContext,
            lastMessage: spec.lastMessage ?? "（未提供）"
        )
    }
    
    private func buildOpenerPrompt(spec: GenSpec) -> String {
        return PromptTemplates.openerPrompt(
            candidateCount: spec.candidateCount,
            openerScene: spec.toneTag.rawValue,
            userStyle: buildStyleDescription(spec: spec),
            emojiLevel: spec.emojiLevel.displayName,
            flirtLevel: spec.flirtLevel,
            myPersona: identity.personaDescription,
            relationshipGoal: identity.relationshipGoal.rawValue,
            theirProfile: nil // 占位符，后续可扩展
        )
    }
    
    private func buildPolishPrompt(spec: GenSpec) -> String {
        return PromptTemplates.polishPrompt(
            candidateCount: spec.candidateCount,
            polishStyle: spec.toneTag.rawValue,
            lengthPref: spec.lengthPreference.rawValue,
            emojiLevel: spec.emojiLevel.displayName,
            rawText: spec.rawText ?? "（未提供原话）"
        )
    }
    
    /// 构建风格描述
    private func buildStyleDescription(spec: GenSpec) -> String {
        var styles: [String] = []
        
        // 基于标签添加风格
        switch spec.toneTag {
        case .highEQ:
            styles.append("高情商")
        case .flirty:
            styles.append("暧昧")
        case .politeRefuse:
            styles.append("礼貌")
        case .professional:
            styles.append("职业化")
        case .moreHumorous:
            styles.append("幽默")
        case .moreFormal:
            styles.append("正式")
        case .heartfelt:
            styles.append("走心")
        default:
            break
        }
        
        // 基于用户偏好添加
        styles.append(identity.speakingStyle.rawValue)
        
        return styles.joined(separator: "、")
    }
}

// MARK: - 便捷方法
public extension PromptBuilder {
    
    /// 快速构建帮你回提示词
    static func replyPrompt(
        lastMessage: String,
        toneTag: ToneTag = .common,
        context: String? = nil
    ) -> (system: String, user: String) {
        let builder = PromptBuilder()
        var spec = GenSpec.from(
            identity: builder.identity,
            style: builder.style,
            intent: .reply,
            toneTag: toneTag
        )
        spec.lastMessage = lastMessage
        spec.chatContext = context
        return builder.build(spec: spec)
    }
    
    /// 快速构建帮开场提示词
    static func openerPrompt(
        scene: ToneTag = .generalOpener
    ) -> (system: String, user: String) {
        let builder = PromptBuilder()
        let spec = GenSpec.from(
            identity: builder.identity,
            style: builder.style,
            intent: .opener,
            toneTag: scene
        )
        return builder.build(spec: spec)
    }
    
    /// 快速构建帮润色提示词
    static func polishPrompt(
        rawText: String,
        style: ToneTag = .moreNatural
    ) -> (system: String, user: String) {
        let builder = PromptBuilder()
        var spec = GenSpec.from(
            identity: builder.identity,
            style: builder.style,
            intent: .polish,
            toneTag: style
        )
        spec.rawText = rawText
        return builder.build(spec: spec)
    }
}
