import Foundation

// MARK: - 功能开关
// 集中管理所有功能开关配置

public enum FeatureFlags {
    
    // MARK: - 功能开关
    
    /// 是否启用历史记录功能
    public static var enableHistory: Bool = true
    
    /// 是否启用离线模板
    public static var enableOfflineTemplates: Bool = true
    
    /// 是否在粘贴后自动触发生成
    public static var autoGenerateOnPaste: Bool = true
    
    /// 是否在填入后自动收起键盘
    public static var dismissKeyboardOnInsert: Bool = false
    
    /// 是否启用震动反馈
    public static var enableHapticFeedback: Bool = true
    
    /// 是否显示风险标记提示
    public static var showRiskFlaggedHint: Bool = true
    
    // MARK: - 调试开关
    
    /// 是否启用调试模式
    public static var debugMode: Bool = false
    
    /// 是否打印 Prompt 日志
    public static var logPrompts: Bool = false
    
    // MARK: - 限制配置
    
    /// 最大候选数量
    public static let maxCandidateCount: Int = 5
    
    /// 历史记录最大条数
    public static let maxHistoryCount: Int = 20
    
    /// 候选文本最大字数
    public static let maxCandidateLength: Int = 200
    
    // MARK: - 动画配置
    
    /// 模式切换动画时长（毫秒）
    public static let modeSwitchAnimationDuration: Double = 0.15
    
    /// 候选生成 loading 动画时长（毫秒）
    public static let loadingAnimationDuration: Double = 0.3
}
