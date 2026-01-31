import Foundation

// MARK: - 共享配置读取器
// 从 App Group 读取主 App 保存的配置

public final class SharedSettingsReader {
    
    private let store = AppGroupStore.store
    
    public init() {}
    
    // MARK: - 身份配置
    
    /// 读取用户身份配置
    public func loadIdentity() -> UserIdentity {
        return store.loadIdentity()
    }
    
    // MARK: - 风格配置
    
    /// 读取风格配置
    public func loadStyle() -> StyleProfile {
        return store.loadStyle()
    }
    
    // MARK: - 历史记录
    
    /// 读取最近候选历史
    public func loadRecentCandidates() -> [Candidate] {
        return store.loadRecentCandidates()
    }
    
    // MARK: - 权限状态
    
    /// 检查权限引导是否已完成
    public func isPermissionGuideCompleted() -> Bool {
        return store.isPermissionGuideCompleted()
    }
}
