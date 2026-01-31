import Foundation

// MARK: - 统一提示词生成引擎
// 根据 m4.txt 规范实现提示词拼装公式：
// Identity + Main_Category_Task + Sub_Category_Style + Global_Constraints

public final class PromptEngine {
    
    // MARK: - 单例
    
    public static let shared = PromptEngine()
    
    private init() {}
    
    // MARK: - 核心提示词组件
    
    private func buildIdentityBlock(_ identity: UserIdentity) -> String {
        var lines: [String] = []
        
        // 用户称呼
        if !identity.displayName.isEmpty {
            lines.append("用户称呼：\(identity.displayName)")
        }
        
        // 性别设定
        if identity.gender != .unspecified {
            lines.append("用户性别：\(identity.gender.rawValue)")
        }
        
        // 身份/角色
        lines.append("用户身份：\(identity.personaDescription)")
        
        // 交往目标
        lines.append("交往目标：\(identity.relationshipGoal.rawValue)")
        
        // 说话风格
        lines.append("说话风格：\(identity.speakingStyle.rawValue)")
        
        // 语言偏好
        lines.append("语言偏好：\(identity.language.rawValue)")
        
        return """
        ## 用户背景
        \(lines.joined(separator: "\n"))
        """
    }
    
    /// 主分类任务模块 (Main_Category_Task)
    private func buildMainCategoryTask(_ slot: CategorySlot) -> String {
        let categoryDesc: String
        
        switch slot.mainCategory {
        case .reply:
            categoryDesc = "你现在是一个社交回复专家，帮助用户针对对方发来的消息生成高情商回复。"
        case .opener:
            categoryDesc = "你现在是一个社交破冰专家，帮助用户主动发起有吸引力的开场对话。"
        case .polish:
            categoryDesc = "你现在是一个文字润色专家，帮助用户把表达优化得更加得体有情商。"
        case .rolePlay:
            categoryDesc = "你现在是一个角色扮演专家，从特定专业身份角度给出回答。"
        case .lifeWiki:
            categoryDesc = "你现在是一个生活百科专家，解答各类知识问题并提供实用建议。"
        }
        
        return """
        ## 角色定位
        \(categoryDesc)
        
        分类：【\(slot.mainCategory.rawValue)】
        """
    }
    
    /// 子分类风格模块 (Sub_Category_Style)
    private func buildSubCategoryStyle(_ slot: CategorySlot) -> String {
        let subCat = slot.selectedSubCategory
        let params = slot.effectiveStyleParams
        
        var styleBlock = """
        ## 风格要求
        子分类：【\(slot.currentSubCategoryName)】
        核心指令：\(subCat.promptCore)
        
        风格参数：
        - 暧昧等级：\(params.ambiguity)/5（0=完全不暧昧，5=明显暧昧）
        - 表情密度：\(params.emojiDensity.promptValue)
        - 字数偏好：\(params.length.promptValue)（最多 \(params.length.maxSentences) 句）
        """
        
        // 添加 V2 配置（如果有）
        if let v2 = slot.configV2 {
            styleBlock += """
            
            ## 扩展配置
            - 字数要求：\(v2.wordCount.promptValue)
            - 表达激进度：\(v2.aggressionLevel.promptValue)
            """
            
            // 添加成人风格配置
            if v2.adultStyle != .none {
                styleBlock += "\n- 成人风格：\(v2.adultStyle.promptValue)"
            }
        }
        
        return styleBlock
    }
    
    /// 全局约束模块 (Global_Constraints)
    private func buildGlobalConstraints(_ identity: UserIdentity, slot: CategorySlot? = nil) -> String {
        var constraints = [
            "直接可用：输出必须是可以直接发送的纯文字，严禁废话",
            "人称一致：严格按照用户性别使用正确称呼",
            "自然得体：像真人说话，不要机械",
            "情绪价值：优先给对方正向情绪"
        ]
        
        // 添加雷区
        if !identity.tabooList.isEmpty {
            constraints.append("严禁提及：\(identity.tabooDescription)")
        }
        
        // 根据风险激进程度调整约束
        if let slot = slot, let v2 = slot.configV2 {
            switch v2.aggressionLevel {
            case .low:
                constraints.append("谨慎表达：避免敏感话题，措辞保守稳妥")
            case .medium:
                break // 默认约束即可
            case .high:
                constraints.append("大胆表达：可以直接表达真实想法，但不要冒犯")
            }
        }
        
        return """
        ## 铁律（必须严格遵守）
        \(constraints.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        ## 禁止事项
        - 油腻话术
        - 过度承诺
        - 越界内容
        - 说教语气
        - 任何 AI 口吻
        - "你可以说"、"建议如下"等解释性文字
        """
    }
    
    // MARK: - 公开 API
    
    /// 构建完整的系统提示词
    public func buildSystemPrompt(
        identity: UserIdentity,
        slot: CategorySlot
    ) -> String {
        let identityBlock = buildIdentityBlock(identity)
        let taskBlock = buildMainCategoryTask(slot)
        let styleBlock = buildSubCategoryStyle(slot)
        let constraintsBlock = buildGlobalConstraints(identity, slot: slot)
        
        return """
        你是 Forlove 输入法的 AI 内核，专门帮助用户在社交场景中生成得体、有情商的回复。
        
        \(identityBlock)
        
        \(taskBlock)
        
        \(styleBlock)
        
        \(constraintsBlock)
        
        ## 输出格式
        必须返回严格的 JSON 格式：
        {
          "candidates": [
            {"text": "回复内容1", "preview": "前30字预览"},
            {"text": "回复内容2", "preview": "前30字预览"},
            {"text": "回复内容3", "preview": "前30字预览"}
          ]
        }
        """
    }
    
    /// 构建用户提示词（帮你回模式）
    public func buildReplyUserPrompt(
        lastMessage: String,
        slot: CategorySlot,
        chatContext: String? = nil
    ) -> String {
        var prompt = """
        对方刚发来一条消息：
        「\(lastMessage)」
        
        请按照【\(slot.selectedSubCategory.rawValue)】的风格，生成 3 条不同的回复。
        """
        
        if let context = chatContext {
            prompt += "\n\n聊天上下文：\n\(context)"
        }
        
        return prompt
    }
    
    /// 构建用户提示词（帮开场模式）
    public func buildOpenerUserPrompt(
        slot: CategorySlot,
        theirProfile: String? = nil
    ) -> String {
        var prompt = """
        我想主动找对方聊天，请按照【\(slot.selectedSubCategory.rawValue)】的方式，生成 3 条不同的开场白。
        要求自然不尬聊，能够引起对方回复的兴趣。
        """
        
        if let profile = theirProfile {
            prompt += "\n\n对方信息：\n\(profile)"
        }
        
        return prompt
    }
    
    /// 构建用户提示词（帮润色模式）
    public func buildPolishUserPrompt(
        rawText: String,
        slot: CategorySlot
    ) -> String {
        return """
        我想发这句话：
        「\(rawText)」
        
        请帮我润色，使其变得【\(slot.selectedSubCategory.rawValue)】，生成 3 个不同版本。
        保持原意不变，但表达方式更加得体有情商。
        """
    }
    
    /// 构建用户提示词（夸捆模式 - 已合并到帮你回的复捆子分类）
    /// 保留向后兼容
    public func buildPraiseUserPrompt(
        targetMessage: String,
        slot: CategorySlot
    ) -> String {
        return """
        对方说了：
        「\(targetMessage)」
        
        请按照【\(slot.selectedSubCategory.rawValue)】的方式，生成 3 条真诚的夸赞回复。
        要发自内心，不要假大空。
        """
    }
    
    /// 构建用户提示词（角色代入模式）
    public func buildRolePlayUserPrompt(
        question: String,
        slot: CategorySlot
    ) -> String {
        return """
        我需要你从【\(slot.selectedSubCategory.rawValue)】的角度来回答：
        「\(question)」
        
        请给我 3 条不同角度的解答，保持专业身份的语气和特点。
        """
    }
    
    /// 构建用户提示词（生活百科模式）
    public func buildLifeWikiUserPrompt(
        question: String,
        slot: CategorySlot
    ) -> String {
        return """
        我想了解：
        「\(question)」
        
        请按照【\(slot.selectedSubCategory.rawValue)】的方式，给我 3 条不同的回答。
        简洁实用，直接可用。
        """
    }
    
    // MARK: - 便捷方法
    
    /// 根据槽位自动选择构建方法
    public func buildUserPrompt(
        slot: CategorySlot,
        content: String,
        chatContext: String? = nil
    ) -> String {
        switch slot.mainCategory {
        case .reply:
            return buildReplyUserPrompt(lastMessage: content, slot: slot, chatContext: chatContext)
        case .opener:
            return buildOpenerUserPrompt(slot: slot, theirProfile: content.isEmpty ? nil : content)
        case .polish:
            return buildPolishUserPrompt(rawText: content, slot: slot)
        case .rolePlay:
            return buildRolePlayUserPrompt(question: content, slot: slot)
        case .lifeWiki:
            return buildLifeWikiUserPrompt(question: content, slot: slot)
        }
    }
    
    /// 完整构建系统提示词和用户提示词
    public func build(
        identity: UserIdentity,
        slot: CategorySlot,
        content: String,
        chatContext: String? = nil
    ) -> (system: String, user: String) {
        let systemPrompt = buildSystemPrompt(identity: identity, slot: slot)
        let userPrompt = buildUserPrompt(slot: slot, content: content, chatContext: chatContext)
        return (systemPrompt, userPrompt)
    }
}
