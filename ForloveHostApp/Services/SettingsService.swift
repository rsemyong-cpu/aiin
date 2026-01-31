import Foundation

// MARK: - 设置服务
// 主 App 读写配置到 App Group

public final class SettingsService {
    
    private let store = AppGroupStore.store
    
    public init() {}
    
    // MARK: - 身份配置
    
    /// 保存用户身份
    public func saveIdentity(_ identity: UserIdentity) {
        store.saveIdentity(identity)
    }
    
    /// 读取用户身份
    public func loadIdentity() -> UserIdentity {
        return store.loadIdentity()
    }
    
    // MARK: - 风格配置
    
    /// 保存风格配置
    public func saveStyle(_ style: StyleProfile) {
        store.saveStyle(style)
    }
    
    /// 读取风格配置
    public func loadStyle() -> StyleProfile {
        return store.loadStyle()
    }
    
    // MARK: - 重置
    
    /// 重置所有设置为默认值
    public func resetToDefaults() {
        store.saveIdentity(.default)
        store.saveStyle(.default)
    }
    
    /// 清除所有数据
    public func clearAllData() {
        store.clearAll()
    }
}
