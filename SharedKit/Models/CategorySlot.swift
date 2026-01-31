import Foundation

// MARK: - 分类槽位模型 V5
// 5 大主分类的矩阵结构，每个分类包含固定的二级主题和可配置参数

/// 主分类枚举（5个固定分类）
public enum MainCategory: String, Codable, CaseIterable {
    case reply = "帮你回"
    case opener = "帮开场"
    case polish = "帮润色"
    case rolePlay = "角色代入"
    case lifeWiki = "生活百科"
    
    /// 分类图标
    public var icon: String {
        switch self {
        case .reply: return "bubble.left.and.bubble.right.fill"
        case .opener: return "hand.wave.fill"
        case .polish: return "paintbrush.pointed.fill"
        case .rolePlay: return "theatermasks.fill"
        case .lifeWiki: return "book.fill"
        }
    }
    
    /// 分类描述
    public var description: String {
        switch self {
        case .reply: return "在已有对话中，接住对方话，不冷场、不掉地上"
        case .opener: return "在刚加好友/冷场/不知怎么聊时，主动开启对话"
        case .polish: return "用户已经写好一句话，AI帮他提升表达效果"
        case .rolePlay: return "同一问题，从不同专业身份角度回答"
        case .lifeWiki: return "解决关于是什么、怎么做、值不值的各种疑问"
        }
    }
    
    /// 获取该分类的子分类列表
    public var subCategories: [SubCategory] {
        switch self {
        case .reply:
            return [.highEQ, .flirty, .tease, .polite, .praiseReply, .coldCEO, .rational, .humorResolve, .roastMode]
        case .opener:
            return [.humorBreaker, .curiousQuestion, .momentsCutIn, .directBall, .dailyChat, .lightPraise]
        case .polish:
            return [.professional, .deGreasy, .literary, .concise, .moreEmotional, .funnier, .moreFormal, .moreCasual]
        case .rolePlay:
            return [.lawyer, .doctor, .programmer, .accountant, .topSales, .fitnessCoach, .psychologist, .careerMentor, .productManager, .toxicCritic, .philosopher, .loveCoach]
        case .lifeWiki:
            return [.quickExplain, .coreSteps, .mythBuster, .shoppingAdvice, .avoidPitfalls, .prosConsCompare]
        }
    }
    
    /// 获取默认子分类
    public var defaultSubCategory: SubCategory {
        subCategories.first ?? .highEQ
    }
}

/// 子分类枚举
public enum SubCategory: String, Codable, CaseIterable {
    // MARK: - Reply 子分类（9个）
    case highEQ = "高情商"
    case flirty = "暧昧"
    case tease = "撩拨"
    case polite = "礼貌"
    case praiseReply = "夸捧"
    case coldCEO = "高冷霸总"
    case rational = "理性回应"
    case humorResolve = "幽默化解"
    case roastMode = "怼人模式"
    
    // MARK: - Opener 子分类（6个）
    case humorBreaker = "幽默破冰"
    case curiousQuestion = "好奇提问"
    case momentsCutIn = "朋友圈切入"
    case directBall = "直球进击"
    case dailyChat = "日常随聊"
    case lightPraise = "轻赞美开场"
    
    // MARK: - Polish 子分类（8个）
    case professional = "职场精英"
    case deGreasy = "去油腻"
    case literary = "更有文采"
    case concise = "简洁有力"
    case moreEmotional = "更深情"
    case funnier = "更幽默"
    case moreFormal = "更正式"
    case moreCasual = "更随意"
    
    // MARK: - RolePlay 子分类（12个）
    case lawyer = "律师角度"
    case doctor = "医生角度"
    case programmer = "程序员角度"
    case accountant = "会计角度"
    case topSales = "金牌销售"
    case fitnessCoach = "健身教练"
    case psychologist = "心理咨询师"
    case careerMentor = "职场导师"
    case productManager = "产品经理"
    case toxicCritic = "毒舌评审"
    case philosopher = "哲学大师"
    case loveCoach = "情感教练"
    
    // MARK: - LifeWiki 子分类（6个）
    case quickExplain = "大概讲解"
    case coreSteps = "核心步骤"
    case mythBuster = "辟谣专家"
    case shoppingAdvice = "购物建议"
    case avoidPitfalls = "避坑指南"
    case prosConsCompare = "优劣对比"
    
    /// 提示词核心描述
    public var promptCore: String {
        switch self {
        // Reply（帮你回）
        case .highEQ:
            return "读懂暗示、顺势回应。理解潜台词，避免生硬回应，保持关系温度。关键词：接话感、顺势、体面"
        case .flirty:
            return "制造轻微情绪波动。模糊表达，留有想象空间，不给确定结论。关键词：拉扯、若即若离"
        case .tease:
            return "打破平淡，增加互动刺激。轻微挑战，幽默反问，不正面顺从。关键词：调侃、反转、轻挑衅"
        case .polite:
            return "正式、安全、不越界。用词严谨，语气克制，无情绪冒进。适用：商务/长辈/半熟关系"
        case .praiseReply:
            return "正向反馈，抬高对方感受。从对方话中找闪光点，真诚、不模板。禁止：无脑吹、假大空"
        case .coldCEO:
            return "极简风格，字少事大，自带威慑力。霸道总裁口吻，简短有力"
        case .rational:
            return "不被情绪带着走。情绪降温，表达清楚立场，理性分析"
        case .humorResolve:
            return "缓解尴尬或紧张。自嘲/情境幽默，不攻击对方"
        case .roastMode:
            return "反击、立边界。不骂人，有逻辑、有分寸。禁止人身攻击，禁止低俗"
            
        // Opener（帮开场）
        case .humorBreaker:
            return "降低社交压力。冷笑话/生活观察，轻松有趣"
        case .curiousQuestion:
            return "激发对方表达欲。开放式问题，不查户口"
        case .momentsCutIn:
            return "模拟看过你动态的感觉。兴趣/场景切入，允许虚拟，不提我看了你朋友圈"
        case .directBall:
            return "明确、不绕。坦诚表达，礼貌不冒犯"
        case .dailyChat:
            return "最低风险开场。天气/近况/状态，自然轻松"
        case .lightPraise:
            return "快速建立好感。点到即止，不油腻"
            
        // Polish（帮润色）
        case .professional:
            return "口语→商务/公文。去情绪化，专业正式"
        case .deGreasy:
            return "删除多余表情，减少感叹号，降低讨好感"
        case .literary:
            return "增强修辞，丰富词汇，偏书面表达"
        case .concise:
            return "长句变短句，合并重复表达，精简有力"
        case .moreEmotional:
            return "强化情绪浓度，更有感染力"
        case .funnier:
            return "增加反差，轻调侃，让表达更有趣"
        case .moreFormal:
            return "适合公告/通知/说明，正式规范"
        case .moreCasual:
            return "更像真人聊天，降低写出来的感觉"
            
        // RolePlay（角色代入）
        case .lawyer:
            return "严谨、逻辑缜密，侧重风险评估"
        case .doctor:
            return "冷静、专业，侧重健康建议与关怀"
        case .programmer:
            return "逻辑化、极简，擅长排查问题"
        case .accountant:
            return "精确、敏感，侧重利益与成本分析"
        case .topSales:
            return "极具说服力，擅长引导需求和赞美"
        case .fitnessCoach:
            return "充满活力，用鼓励和自律的语气说话"
        case .psychologist:
            return "温暖、共情，侧重情绪疏导"
        case .careerMentor:
            return "经验丰富，给出职场发展建议"
        case .productManager:
            return "结构化思维，注重用户体验和需求分析"
        case .toxicCritic:
            return "犀利、直接，适合评价事物或求真相"
        case .philosopher:
            return "深邃、辩证，凡事都要上升到本质"
        case .loveCoach:
            return "洞察人心，侧重社交策略与两性博弈"
            
        // LifeWiki（生活百科）
        case .quickExplain:
            return "200字以内的快速科普"
        case .coreSteps:
            return "针对怎么做的问题，只给1、2、3清单"
        case .mythBuster:
            return "科学分析输入内容的真伪"
        case .shoppingAdvice:
            return "分析优缺点，给出买或不买的逻辑"
        case .avoidPitfalls:
            return "揭露某个行业或场景下的常见套路"
        case .prosConsCompare:
            return "提供A和B的多维度数据/体验对比"
        }
    }
    
    /// 默认风格参数
    public var defaultStyleParams: StyleParams {
        switch self {
        // Reply
        case .highEQ:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .medium)
        case .flirty:
            return StyleParams(ambiguity: 5, emojiDensity: .high, length: .short)
        case .tease:
            return StyleParams(ambiguity: 4, emojiDensity: .medium, length: .short)
        case .polite:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .praiseReply:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .medium)
        case .coldCEO:
            return StyleParams(ambiguity: 1, emojiDensity: .none, length: .short)
        case .rational:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .humorResolve:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .short)
        case .roastMode:
            return StyleParams(ambiguity: 1, emojiDensity: .none, length: .medium)
            
        // Opener
        case .humorBreaker:
            return StyleParams(ambiguity: 1, emojiDensity: .medium, length: .short)
        case .curiousQuestion:
            return StyleParams(ambiguity: 1, emojiDensity: .low, length: .short)
        case .momentsCutIn:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .short)
        case .directBall:
            return StyleParams(ambiguity: 3, emojiDensity: .low, length: .short)
        case .dailyChat:
            return StyleParams(ambiguity: 1, emojiDensity: .low, length: .short)
        case .lightPraise:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .short)
            
        // Polish
        case .professional:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .deGreasy:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .literary:
            return StyleParams(ambiguity: 1, emojiDensity: .low, length: .long)
        case .concise:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .short)
        case .moreEmotional:
            return StyleParams(ambiguity: 3, emojiDensity: .medium, length: .medium)
        case .funnier:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .medium)
        case .moreFormal:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .long)
        case .moreCasual:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .medium)
            
        // RolePlay
        case .lawyer, .doctor, .accountant, .productManager:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .long)
        case .programmer:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .topSales:
            return StyleParams(ambiguity: 2, emojiDensity: .medium, length: .medium)
        case .fitnessCoach:
            return StyleParams(ambiguity: 1, emojiDensity: .medium, length: .medium)
        case .psychologist:
            return StyleParams(ambiguity: 1, emojiDensity: .low, length: .long)
        case .careerMentor:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .toxicCritic:
            return StyleParams(ambiguity: 1, emojiDensity: .none, length: .medium)
        case .philosopher:
            return StyleParams(ambiguity: 1, emojiDensity: .none, length: .long)
        case .loveCoach:
            return StyleParams(ambiguity: 3, emojiDensity: .low, length: .medium)
            
        // LifeWiki
        case .quickExplain:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .coreSteps:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .mythBuster:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .medium)
        case .shoppingAdvice:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .long)
        case .avoidPitfalls:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .long)
        case .prosConsCompare:
            return StyleParams(ambiguity: 0, emojiDensity: .none, length: .long)
        }
    }
    
    /// 所属的主分类
    public var mainCategory: MainCategory {
        switch self {
        case .highEQ, .flirty, .tease, .polite, .praiseReply, .coldCEO, .rational, .humorResolve, .roastMode:
            return .reply
        case .humorBreaker, .curiousQuestion, .momentsCutIn, .directBall, .dailyChat, .lightPraise:
            return .opener
        case .professional, .deGreasy, .literary, .concise, .moreEmotional, .funnier, .moreFormal, .moreCasual:
            return .polish
        case .lawyer, .doctor, .programmer, .accountant, .topSales, .fitnessCoach, .psychologist, .careerMentor, .productManager, .toxicCritic, .philosopher, .loveCoach:
            return .rolePlay
        case .quickExplain, .coreSteps, .mythBuster, .shoppingAdvice, .avoidPitfalls, .prosConsCompare:
            return .lifeWiki
        }
    }
}

// MARK: - 风格参数

/// 表情密度枚举
public enum EmojiDensity: String, Codable, CaseIterable {
    case none = "无"
    case low = "少"
    case medium = "适中"
    case high = "多"
    
    public var promptValue: String {
        rawValue
    }
}

/// 字数长度枚举
public enum ContentLength: String, Codable, CaseIterable {
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
    
    public var promptValue: String {
        rawValue
    }
}

/// 字数偏好（短/中/长）
public enum WordCount: String, Codable, CaseIterable {
    case few = "短"
    case medium = "中"
    case many = "长"
    
    public var promptValue: String {
        switch self {
        case .few: return "简短精炼，1-2句话"
        case .medium: return "适中篇幅，2-3句话"
        case .many: return "详细充分，3-5句话"
        }
    }
    
    public var icon: String {
        switch self {
        case .few: return "text.alignleft"
        case .medium: return "text.aligncenter"
        case .many: return "text.justify"
        }
    }
}

/// 激进风险指数（低/中/高）
public enum AggressionLevel: String, Codable, CaseIterable {
    case low = "低"
    case medium = "中"
    case high = "高"
    
    public var promptValue: String {
        switch self {
        case .low: return "非常保守的回复，措辞谨慎，绝对安全"
        case .medium: return "保守与前沿平衡，适度表达"
        case .high: return "前卫激进敢说，不怕犯错，大胆表达"
        }
    }
    
    public var icon: String {
        switch self {
        case .low: return "shield.fill"
        case .medium: return "sparkles"
        case .high: return "flame.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

/// 成人风格（无/轻/重）
public enum AdultStyle: String, Codable, CaseIterable {
    case none = "无"
    case light = "轻"
    case heavy = "重"
    
    public var promptValue: String {
        switch self {
        case .none: return "不涉及成人话题，保持纯净"
        case .light: return "可以加入成人暗示，轻微挑逗"
        case .heavy: return "可以放开成人话题，但不要色情"
        }
    }
    
    public var icon: String {
        switch self {
        case .none: return "heart"
        case .light: return "heart.fill"
        case .heavy: return "flame"
        }
    }
    
    public var color: String {
        switch self {
        case .none: return "gray"
        case .light: return "pink"
        case .heavy: return "red"
        }
    }
}

/// 风格参数结构
public struct StyleParams: Codable, Equatable {
    /// 暧昧等级 (0-5)
    public var ambiguity: Int
    
    /// 表情密度
    public var emojiDensity: EmojiDensity
    
    /// 字数长度
    public var length: ContentLength
    
    public init(
        ambiguity: Int = 2,
        emojiDensity: EmojiDensity = .medium,
        length: ContentLength = .medium
    ) {
        self.ambiguity = min(5, max(0, ambiguity))
        self.emojiDensity = emojiDensity
        self.length = length
    }
}

// MARK: - 分类槽位（Slot）

/// 槽位配置 V2 - 简化版（分类固定，只有参数可调）
public struct SlotConfigV2: Codable, Equatable {
    /// 字数偏好
    public var wordCount: WordCount
    
    /// 激进风险指数
    public var aggressionLevel: AggressionLevel
    
    /// 成人风格
    public var adultStyle: AdultStyle
    
    public init(
        wordCount: WordCount = .medium,
        aggressionLevel: AggressionLevel = .medium,
        adultStyle: AdultStyle = .none
    ) {
        self.wordCount = wordCount
        self.aggressionLevel = aggressionLevel
        self.adultStyle = adultStyle
    }
}

/// 分类槽位配置
public struct CategorySlot: Codable, Equatable, Identifiable {
    public var id: Int
    
    /// 主分类（固定，不可修改）
    public var mainCategory: MainCategory
    
    /// 选中的子分类
    public var selectedSubCategory: SubCategory
    
    /// 自定义风格参数（覆盖默认值）
    public var customStyleParams: StyleParams?
    
    /// 是否启用（在键盘中生效）
    public var isEnabled: Bool
    
    /// 排序顺序
    public var order: Int
    
    /// V2 配置（参数设置）
    public var configV2: SlotConfigV2?
    
    /// 当前选中的二级分类索引（在 subCategories 数组中的位置）
    public var selectedSubIndex: Int
    
    public init(
        id: Int,
        mainCategory: MainCategory,
        selectedSubCategory: SubCategory? = nil,
        customStyleParams: StyleParams? = nil,
        isEnabled: Bool = true,
        order: Int = 0,
        configV2: SlotConfigV2? = nil,
        selectedSubIndex: Int = 0
    ) {
        self.id = id
        self.mainCategory = mainCategory
        self.selectedSubCategory = selectedSubCategory ?? mainCategory.defaultSubCategory
        self.customStyleParams = customStyleParams
        self.isEnabled = isEnabled
        self.order = order
        self.configV2 = configV2 ?? SlotConfigV2()
        self.selectedSubIndex = selectedSubIndex
    }
    
    /// 获取生效的风格参数
    public var effectiveStyleParams: StyleParams {
        customStyleParams ?? selectedSubCategory.defaultStyleParams
    }
    
    /// 获取显示名称（固定为主分类名称）
    public var displayName: String {
        mainCategory.rawValue
    }
    
    /// 获取当前选中的二级分类名称
    public var currentSubCategoryName: String {
        selectedSubCategory.rawValue
    }
    
    /// 获取所有可用的二级分类
    public var allAvailableSubCategories: [SubCategory] {
        mainCategory.subCategories
    }
    
    /// 获取完整的提示词核心
    public var fullPromptCore: String {
        var core = """
        【\(displayName) - \(currentSubCategoryName)】
        \(selectedSubCategory.promptCore)
        """
        
        // 添加 V2 配置信息
        if let v2 = configV2 {
            core += "\n\n字数要求：\(v2.wordCount.promptValue)"
            core += "\n表达风格：\(v2.aggressionLevel.promptValue)"
            if v2.adultStyle != .none {
                core += "\n成人风格：\(v2.adultStyle.promptValue)"
            }
        }
        
        return core
    }
    
    /// 获取用于 API 的结构化配置
    public var apiConfig: [String: Any] {
        var config: [String: Any] = [
            "main_category": mainCategory.rawValue,
            "sub_category": selectedSubCategory.rawValue,
            "display_name": displayName,
            "current_sub_name": currentSubCategoryName
        ]
        
        if let v2 = configV2 {
            config["word_count"] = v2.wordCount.rawValue
            config["aggression_level"] = v2.aggressionLevel.rawValue
            config["adult_style"] = v2.adultStyle.rawValue
        }
        
        return config
    }
    
    /// 选择二级分类
    public mutating func selectSubCategory(at index: Int) {
        let subs = mainCategory.subCategories
        guard index >= 0 && index < subs.count else { return }
        selectedSubIndex = index
        selectedSubCategory = subs[index]
    }
}

// MARK: - 用户槽位配置

/// 用户的槽位配置（可选 3 个激活）
public struct UserSlotConfiguration: Codable, Equatable {
    /// 所有可用的槽位配置（固定5个）
    public var allSlots: [CategorySlot]
    
    /// 激活的槽位 ID（最多 3 个）
    public var activeSlotIds: [Int]
    
    public init(
        allSlots: [CategorySlot]? = nil,
        activeSlotIds: [Int]? = nil
    ) {
        // 初始化固定的 5 个槽位
        if let slots = allSlots {
            self.allSlots = slots
        } else {
            self.allSlots = MainCategory.allCases.enumerated().map { index, category in
                CategorySlot(id: index, mainCategory: category, order: index)
            }
        }
        
        // 默认激活前 3 个（帮你回、帮开场、帮润色）
        self.activeSlotIds = activeSlotIds ?? [0, 1, 2]
    }
    
    /// 获取激活的槽位列表
    public var activeSlots: [CategorySlot] {
        activeSlotIds.compactMap { id in
            allSlots.first { $0.id == id }
        }
    }
    
    /// 更新槽位配置
    public mutating func updateSlot(_ slot: CategorySlot) {
        if let index = allSlots.firstIndex(where: { $0.id == slot.id }) {
            allSlots[index] = slot
        }
    }
    
    /// 设置激活的槽位（最多 3 个）
    public mutating func setActiveSlots(_ ids: [Int]) {
        activeSlotIds = Array(ids.prefix(3))
    }
    
    /// 默认配置
    public static let `default` = UserSlotConfiguration()
}
