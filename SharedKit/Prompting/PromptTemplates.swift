import Foundation

// MARK: - 提示词模板
// iOS 提示工程：集中管理所有 Prompt 模板

public enum PromptTemplates {
    
    // MARK: - 系统级主提示词（Master Prompt）
    
    /// 全局系统角色定义
    public static let masterSystemPrompt = """
    你是一个中文即时聊天回复助手。你的职责是:
    
    1. 输出"可直接发送"的聊天文本
    2. 不做任何解释、分析、建议
    3. 不使用列表、编号、分析语气
    4. 不提及"AI"、"模型"、"提示词"等技术词汇
    5. 语气自然，像真人在聊天
    
    硬性禁止：
    - 油腻的话术
    - 过度承诺
    - 越界内容
    - 说教语气
    - 任何 AI 口吻
    """
    
    // MARK: - 帮你回 Reply 模板
    
    public static func replyPrompt(
        candidateCount: Int,
        maxSentences: Int,
        userStyle: String,
        flirtLevel: Int,
        riskLevel: String,
        emojiLevel: String,
        myNickname: String,
        myPersona: String,
        relationshipGoal: String,
        tabooList: String,
        chatContext: String?,
        lastMessage: String
    ) -> String {
        return """
        请输出 \(candidateCount) 条"可直接发送"的回复候选。
        
        硬性规则：
        - 每条不超过 \(maxSentences) 句，优先 1-2 句
        - 不要说教，不要解释
        - 语气符合「\(userStyle)」
        - 暧昧等级 \(flirtLevel)/5（0=完全不暧昧，5=明显暧昧但不越界）
        - 风险等级：\(riskLevel)
        - 表情密度：\(emojiLevel)
        
        我的身份：
        - 称呼：\(myNickname.isEmpty ? "（未设置）" : myNickname)
        - 身份/角色：\(myPersona)
        - 交往目标：\(relationshipGoal)
        - 雷区：\(tabooList)
        
        \(chatContext.map { "聊天上下文：\n\($0)\n" } ?? "")
        对方最新一句：
        \(lastMessage)
        
        输出格式（只输出文本，不要编号）：
        """
    }
    
    // MARK: - 帮开场 Opener 模板
    
    public static func openerPrompt(
        candidateCount: Int,
        openerScene: String,
        userStyle: String,
        emojiLevel: String,
        flirtLevel: Int,
        myPersona: String,
        relationshipGoal: String,
        theirProfile: String?
    ) -> String {
        return """
        请根据"开场场景"输出 \(candidateCount) 条开场白，要求自然、不尴尬、可继续聊。
        
        场景标签：\(openerScene)
        风格：\(userStyle)
        表情密度：\(emojiLevel)
        暧昧等级：\(flirtLevel)/5（场景不适合时自动降级到 1）
        
        我的身份：\(myPersona)
        交往目标：\(relationshipGoal)
        \(theirProfile.map { "对方信息：\($0)" } ?? "")
        
        输出：每条 1-2 句，最好带一个轻问题。
        """
    }
    
    // MARK: - 帮润色 Polish 模板
    
    public static func polishPrompt(
        candidateCount: Int,
        polishStyle: String,
        lengthPref: String,
        emojiLevel: String,
        rawText: String
    ) -> String {
        return """
        请把"原话"润色成 \(candidateCount) 个版本，意思不变，但更符合「\(polishStyle)」。
        
        硬性规则：
        - 不改变事实信息
        - 不添加过度情绪/承诺
        - 字数控制：\(lengthPref)
        - 表情密度：\(emojiLevel)
        
        原话：
        \(rawText)
        
        输出格式（只输出润色后的文本）：
        """
    }
}
