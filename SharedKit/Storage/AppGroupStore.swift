import Foundation

// MARK: - App Group 存储管理
// 使用 UserDefaults(suiteName:) 实现主 App 与键盘扩展的数据共享
// 如果 App Group 不可用，降级使用标准 UserDefaults（仅在模拟器/调试时有效）

public final class AppGroupStore {
    
    /// App Group 标识符（需要在 Apple Developer Portal 中创建）
    public static let groupIdentifier = "group.com.forlove.keyboard"
    
    /// App Group UserDefaults（可能为 nil）
    private static let groupDefaults: UserDefaults? = {
        if let defaults = UserDefaults(suiteName: groupIdentifier) {
            print("✅ [AppGroupStore] App Group 初始化成功")
            return defaults
        } else {
            print("⚠️ [AppGroupStore] App Group UserDefaults 初始化失败！")
            print("   请确保在 Apple Developer Portal 中正确创建了 App Group")
            return nil
        }
    }()
    
    /// 备用的标准 UserDefaults（当 App Group 不可用时使用）
    private static let standardDefaults = UserDefaults.standard
    
    /// 共享的 UserDefaults 实例（优先使用 App Group）
    public static let shared: UserDefaults = {
        return groupDefaults ?? standardDefaults
    }()
    
    /// 单例
    public static let store = AppGroupStore()
    
    /// 实际使用的 UserDefaults
    private let defaults: UserDefaults
    
    /// 是否使用 App Group
    public var isUsingAppGroup: Bool {
        return AppGroupStore.groupDefaults != nil
    }
    
    private init() {
        self.defaults = AppGroupStore.shared
        
        // 打印初始化状态
        if AppGroupStore.groupDefaults != nil {
            print("📦 [AppGroupStore] 使用 App Group 存储")
        } else {
            print("📦 [AppGroupStore] 降级使用标准 UserDefaults（配置无法在主App和键盘之间共享）")
        }
    }
    
    // MARK: - 调试方法
    
    /// 打印当前存储状态（用于调试）
    public func debugPrintStatus() {
        print("🔍 [AppGroupStore] 存储状态:")
        print("   使用 App Group: \(isUsingAppGroup)")
        print("   Group ID: \(AppGroupStore.groupIdentifier)")
        
        let config = loadSlotConfiguration()
        print("   槽位配置 - 总槽位: \(config.allSlots.count), 激活: \(config.activeSlotIds.count)")
        for slot in config.activeSlots {
            print("     - \(slot.mainCategory.rawValue): \(slot.selectedSubCategory.rawValue)")
        }
    }
    
    // MARK: - 身份配置
    
    /// 保存用户身份配置
    public func saveIdentity(_ identity: UserIdentity) {
        guard let data = try? JSONEncoder().encode(identity) else {
            print("❌ [AppGroupStore] 身份配置编码失败")
            return
        }
        defaults.set(data, forKey: Keys.userIdentity)
        defaults.synchronize()
        print("✅ [AppGroupStore] 身份配置已保存")
    }
    
    /// 读取用户身份配置
    public func loadIdentity() -> UserIdentity {
        guard let data = defaults.data(forKey: Keys.userIdentity),
              let identity = try? JSONDecoder().decode(UserIdentity.self, from: data) else {
            return .default
        }
        return identity
    }
    
    // MARK: - 风格配置
    
    /// 保存风格配置
    public func saveStyle(_ style: StyleProfile) {
        guard let data = try? JSONEncoder().encode(style) else { return }
        defaults.set(data, forKey: Keys.styleProfile)
        defaults.synchronize()
    }
    
    /// 读取风格配置
    public func loadStyle() -> StyleProfile {
        guard let data = defaults.data(forKey: Keys.styleProfile),
              let style = try? JSONDecoder().decode(StyleProfile.self, from: data) else {
            return .default
        }
        return style
    }
    
    // MARK: - 最近历史
    
    /// 保存最近生成的候选（本地历史）
    public func saveRecentCandidates(_ candidates: [Candidate]) {
        // 只保留最近 20 条
        let limited = Array(candidates.prefix(20))
        guard let data = try? JSONEncoder().encode(limited) else { return }
        defaults.set(data, forKey: Keys.recentCandidates)
        defaults.synchronize()
    }
    
    /// 读取最近生成的候选
    public func loadRecentCandidates() -> [Candidate] {
        guard let data = defaults.data(forKey: Keys.recentCandidates),
              let candidates = try? JSONDecoder().decode([Candidate].self, from: data) else {
            return []
        }
        return candidates
    }
    
    /// 添加一条候选到历史
    public func addToHistory(_ candidate: Candidate) {
        var history = loadRecentCandidates()
        history.insert(candidate, at: 0)
        saveRecentCandidates(history)
    }
    
    // MARK: - 权限状态（仅用于 UI 展示优化，非真实权限检测）
    
    /// 保存权限引导完成状态
    public func setPermissionGuideCompleted(_ completed: Bool) {
        defaults.set(completed, forKey: Keys.permissionGuideCompleted)
        defaults.synchronize()
    }
    
    /// 读取权限引导完成状态
    public func isPermissionGuideCompleted() -> Bool {
        return defaults.bool(forKey: Keys.permissionGuideCompleted)
    }
    
    // MARK: - 首次启动
    
    /// 检查是否首次启动
    public func isFirstLaunch() -> Bool {
        let hasLaunched = defaults.bool(forKey: Keys.hasLaunched)
        if !hasLaunched {
            defaults.set(true, forKey: Keys.hasLaunched)
            defaults.synchronize()
        }
        return !hasLaunched
    }
    
    // MARK: - 槽位配置（新矩阵结构）
    
    /// 保存槽位配置
    public func saveSlotConfiguration(_ config: UserSlotConfiguration) {
        guard let data = try? JSONEncoder().encode(config) else {
            print("❌ [AppGroupStore] 槽位配置编码失败")
            return
        }
        defaults.set(data, forKey: Keys.slotConfiguration)
        defaults.synchronize()
        
        print("✅ [AppGroupStore] 槽位配置已保存")
        print("   激活槽位: \(config.activeSlotIds)")
        for slot in config.activeSlots {
            print("   - \(slot.mainCategory.rawValue): \(slot.selectedSubCategory.rawValue)")
        }
    }
    
    /// 读取槽位配置
    public func loadSlotConfiguration() -> UserSlotConfiguration {
        guard let data = defaults.data(forKey: Keys.slotConfiguration) else {
            print("📭 [AppGroupStore] 无槽位配置数据，使用默认值")
            return .default
        }
        
        do {
            let config = try JSONDecoder().decode(UserSlotConfiguration.self, from: data)
            print("📖 [AppGroupStore] 已读取槽位配置")
            print("   激活槽位: \(config.activeSlotIds.count) 个")
            return config
        } catch {
            print("❌ [AppGroupStore] 槽位配置解码失败 (格式不兼容)，自动清除并重置为默认值: \(error.localizedDescription)")
            // 格式不兼容时清除现有数据，强制重新初始化
            defaults.removeObject(forKey: Keys.slotConfiguration)
            defaults.synchronize()
            return .default
        }
    }
    
    /// 保存当前激活的槽位索引
    public func saveActiveSlotIndex(_ index: Int) {
        defaults.set(index, forKey: Keys.activeSlotIndex)
        defaults.synchronize()
    }
    
    /// 读取当前激活的槽位索引
    public func loadActiveSlotIndex() -> Int {
        return defaults.integer(forKey: Keys.activeSlotIndex)
    }
    
    /// 获取当前激活的槽位
    public func loadActiveSlot() -> CategorySlot? {
        let config = loadSlotConfiguration()
        let index = loadActiveSlotIndex()
        guard index < config.activeSlots.count else {
            return config.activeSlots.first
        }
        return config.activeSlots[index]
    }
    
    // MARK: - 清除所有数据
    
    public func clearAll() {
        Keys.allKeys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
        print("🗑️ [AppGroupStore] 已清除所有数据")
    }
}
