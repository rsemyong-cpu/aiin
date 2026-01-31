import Foundation

// MARK: - 用户身份模型
// 存储用户的基本身份信息，用于提示工程个性化

/// 性别选项
public enum Gender: String, Codable, CaseIterable {
    case male = "男"
    case female = "女"
    case unspecified = "不透露"
}

/// 交往目标
public enum RelationshipGoal: String, Codable, CaseIterable {
    case friendship = "交友"
    case dating = "相亲"
    case romance = "恋爱"
    case professional = "职场"
}

/// 预设身份/角色
public enum PersonaPreset: String, Codable, CaseIterable {
    case student = "学生"
    case engineer = "工程师"
    case sales = "销售"
    case boss = "老板"
    case mother = "宝妈"
    case freelancer = "自由职业"
    case custom = "自定义"
}

/// 说话风格
public enum SpeakingStyle: String, Codable, CaseIterable {
    case brief = "简短"
    case emojiLover = "爱表情"
    case restrained = "克制"
    case outgoing = "外向"
}

/// 语言偏好
public enum LanguagePreference: String, Codable, CaseIterable {
    case chinese = "中文"
    case english = "英文"
    case mixed = "中英混"
}

/// 用户身份配置
public struct UserIdentity: Codable, Equatable {
    /// 用户希望被称呼的名字
    public var displayName: String
    
    /// 性别
    public var gender: Gender
    
    /// 交往目标
    public var relationshipGoal: RelationshipGoal
    
    /// 身份/角色预设
    public var persona: PersonaPreset
    
    /// 自定义身份描述（当 persona == .custom 时使用）
    public var customPersona: String?
    
    /// 说话风格
    public var speakingStyle: SpeakingStyle
    
    /// 雷区列表（禁止提及的话题）
    public var tabooList: [String]
    
    /// 语言偏好
    public var language: LanguagePreference
    
    public init(
        displayName: String = "",
        gender: Gender = .unspecified,
        relationshipGoal: RelationshipGoal = .friendship,
        persona: PersonaPreset = .student,
        customPersona: String? = nil,
        speakingStyle: SpeakingStyle = .restrained,
        tabooList: [String] = [],
        language: LanguagePreference = .chinese
    ) {
        self.displayName = displayName
        self.gender = gender
        self.relationshipGoal = relationshipGoal
        self.persona = persona
        self.customPersona = customPersona
        self.speakingStyle = speakingStyle
        self.tabooList = tabooList
        self.language = language
    }
    
    /// 获取用于提示词的身份描述
    public var personaDescription: String {
        if persona == .custom, let custom = customPersona, !custom.isEmpty {
            return custom
        }
        return persona.rawValue
    }
    
    /// 获取用于提示词的雷区描述
    public var tabooDescription: String {
        guard !tabooList.isEmpty else { return "无" }
        return tabooList.joined(separator: "、")
    }
    
    /// 默认身份配置
    public static let `default` = UserIdentity()
}
