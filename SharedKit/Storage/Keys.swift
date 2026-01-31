import Foundation

// MARK: - 存储键值常量
// 统一管理 App Group 中使用的所有 Key

public enum Keys {
    /// 用户身份配置
    public static let userIdentity = "forlove.user.identity"
    
    /// 风格偏好配置
    public static let styleProfile = "forlove.user.style"
    
    /// 最近生成的候选历史
    public static let recentCandidates = "forlove.history.candidates"
    
    /// 权限引导完成状态
    public static let permissionGuideCompleted = "forlove.permission.guideCompleted"
    
    /// 是否已启动过
    public static let hasLaunched = "forlove.app.hasLaunched"
    
    /// 默认生成模式
    public static let defaultIntent = "forlove.settings.defaultIntent"
    
    /// 每个模式记忆的上次选择标签
    public static let lastSelectedTagReply = "forlove.settings.lastTag.reply"
    public static let lastSelectedTagOpener = "forlove.settings.lastTag.opener"
    public static let lastSelectedTagPolish = "forlove.settings.lastTag.polish"
    
    /// API 配置（占位符）
    public static let apiEndpoint = "forlove.api.endpoint"
    public static let apiKey = "forlove.api.key"
    
    /// 槽位配置（新矩阵结构）
    public static let slotConfiguration = "forlove.slots.configuration"
    
    /// 当前激活的槽位索引（键盘中正在使用的）
    public static let activeSlotIndex = "forlove.slots.activeIndex"
    
    /// 所有键列表（用于清除数据）
    public static let allKeys: [String] = [
        userIdentity,
        styleProfile,
        recentCandidates,
        permissionGuideCompleted,
        hasLaunched,
        defaultIntent,
        lastSelectedTagReply,
        lastSelectedTagOpener,
        lastSelectedTagPolish,
        apiEndpoint,
        apiKey,
        slotConfiguration,
        activeSlotIndex
    ]
}
