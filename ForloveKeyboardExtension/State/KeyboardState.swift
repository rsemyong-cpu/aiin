import Foundation

// MARK: - 键盘状态机 V2
// 支持新的槽位矩阵结构

/// 权限状态
public enum PermissionState: Equatable {
    case noKeyboard           // 未启用键盘
    case enabledNoFullAccess  // 已启用但无完全访问
    case enabledFullAccess    // 已启用且有完全访问
}

/// 上下文状态
public enum ContextState: Equatable {
    case empty                // 无上下文
    case hasClipboard         // 有剪贴板内容
    case hasDraftText         // 有输入框草稿
    case hasBoth              // 两者都有
}

/// 加载状态
public enum LoadingState: Equatable {
    case idle                 // 空闲
    case generating(cardId: UUID?)  // 生成中，指定卡片或全部
    case error(message: String)     // 错误
}

/// 键盘主状态（状态机核心）- 支持新槽位系统
public final class KeyboardState: ObservableObject {
    
    // MARK: - 槽位系统（新矩阵结构）
    
    /// 用户槽位配置
    @Published public var slotConfiguration: UserSlotConfiguration = .default
    
    /// 当前激活的槽位索引（在 3 个激活槽位中的索引）
    @Published public var activeSlotIndex: Int = 0
    
    /// 当前激活的槽位
    public var currentSlot: CategorySlot {
        let activeSlots = slotConfiguration.activeSlots
        guard activeSlotIndex >= 0 && activeSlotIndex < activeSlots.count else {
            return activeSlots.first ?? CategorySlot(id: 0, mainCategory: .reply)
        }
        return activeSlots[activeSlotIndex]
    }
    
    // MARK: - 向后兼容（旧模式系统）
    
    /// 当前意图模式（从槽位推导）
    public var currentIntent: GenerationIntent {
        switch currentSlot.mainCategory {
        case .reply: return .reply
        case .opener: return .opener
        case .polish: return .polish
        case .rolePlay: return .reply  // 映射到 reply
        case .lifeWiki: return .reply  // 映射到 reply
        }
    }
    
    /// 每个模式记忆的上次选择标签（向后兼容）
    @Published public var lastSelectedTags: [GenerationIntent: ToneTag] = [
        .reply: .common,
        .opener: .generalOpener,
        .polish: .moreNatural
    ]
    
    /// 当前选中的标签（向后兼容）
    public var currentTag: ToneTag {
        get { lastSelectedTags[currentIntent] ?? ToneTag.tags(for: currentIntent).first ?? .common }
        set { lastSelectedTags[currentIntent] = newValue }
    }
    
    // MARK: - 权限与上下文
    
    /// 权限状态
    @Published public var permissionState: PermissionState = .enabledNoFullAccess
    
    /// 上下文状态
    @Published public var contextState: ContextState = .empty
    
    /// 加载状态
    @Published public var loadingState: LoadingState = .idle
    
    // MARK: - 候选数据
    
    /// 当前候选列表
    @Published public var candidates: [Candidate] = []
    
    /// 剪贴板内容（用户主动粘贴后）
    @Published public var clipboardContent: String?
    
    /// 原话（润色模式）
    @Published public var rawText: String?
    
    // MARK: - UI 状态
    
    /// 是否显示历史抽屉
    @Published public var showingHistory: Bool = false
    
    /// 是否显示设置引导
    @Published public var showingPermissionGuide: Bool = false
    
    /// 当前选中的候选索引（用于填充/替换）
    @Published public var selectedCandidateIndex: Int = 0
    
    // MARK: - 初始化
    
    public init() {
        loadSavedState()
    }
    
    // MARK: - 状态持久化
    
    private func loadSavedState() {
        let store = AppGroupStore.store
        
        // 加载槽位配置
        slotConfiguration = store.loadSlotConfiguration()
        activeSlotIndex = store.loadActiveSlotIndex()
        
        // 加载上次选择的标签（向后兼容）
        if let data = AppGroupStore.shared.data(forKey: Keys.lastSelectedTagReply),
           let tag = try? JSONDecoder().decode(ToneTag.self, from: data) {
            lastSelectedTags[.reply] = tag
        }
        if let data = AppGroupStore.shared.data(forKey: Keys.lastSelectedTagOpener),
           let tag = try? JSONDecoder().decode(ToneTag.self, from: data) {
            lastSelectedTags[.opener] = tag
        }
        if let data = AppGroupStore.shared.data(forKey: Keys.lastSelectedTagPolish),
           let tag = try? JSONDecoder().decode(ToneTag.self, from: data) {
            lastSelectedTags[.polish] = tag
        }
    }
    
    public func saveState() {
        let store = AppGroupStore.store
        
        // 保存槽位索引
        store.saveActiveSlotIndex(activeSlotIndex)
        
        // 保存上次选择的标签（向后兼容）
        for (intent, tag) in lastSelectedTags {
            guard let data = try? JSONEncoder().encode(tag) else { continue }
            let key: String
            switch intent {
            case .reply: key = Keys.lastSelectedTagReply
            case .opener: key = Keys.lastSelectedTagOpener
            case .polish: key = Keys.lastSelectedTagPolish
            }
            AppGroupStore.shared.set(data, forKey: key)
        }
    }
    
    // MARK: - 槽位操作
    
    /// 切换到指定槽位（在激活的 3 个槽位中切换）
    public func switchToSlot(index: Int) {
        guard index >= 0 && index < slotConfiguration.activeSlots.count else { return }
        activeSlotIndex = index
        saveState()
    }
    
    /// 切换到下一个槽位
    public func switchToNextSlot() {
        let nextIndex = (activeSlotIndex + 1) % slotConfiguration.activeSlots.count
        switchToSlot(index: nextIndex)
    }
    
    /// 切换到上一个槽位
    public func switchToPreviousSlot() {
        let prevIndex = (activeSlotIndex - 1 + slotConfiguration.activeSlots.count) % slotConfiguration.activeSlots.count
        switchToSlot(index: prevIndex)
    }
    
    /// 更新槽位配置（从主 App 同步）
    public func reloadSlotConfiguration() {
        slotConfiguration = AppGroupStore.store.loadSlotConfiguration()
        // 确保索引有效
        if activeSlotIndex >= slotConfiguration.activeSlots.count {
            activeSlotIndex = 0
        }
    }
    
    /// 选中当前槽位的二级分类
    public func selectSubCategory(at index: Int) {
        // 更新当前槽位的子分类选中索引
        var currentSlot = self.currentSlot
        
        // 使用 CategorySlot 的 selectSubCategory 方法
        currentSlot.selectSubCategory(at: index)
        
        // 更新并保存配置
        updateCurrentSlot(currentSlot)
    }
    
    private func updateCurrentSlot(_ updatedSlot: CategorySlot) {
        // 更新 slotConfiguration 中的对应槽位
        var config = slotConfiguration
        config.updateSlot(updatedSlot)
        slotConfiguration = config
        // 保存配置到持久化存储
        AppGroupStore.store.saveSlotConfiguration(config)
    }
    
    // MARK: - 向后兼容的状态转换
    
    /// 切换模式（向后兼容）
    public func switchIntent(to intent: GenerationIntent) {
        // 找到对应的槽位
        let targetCategory: MainCategory
        switch intent {
        case .reply: targetCategory = .reply
        case .opener: targetCategory = .opener
        case .polish: targetCategory = .polish
        }
        
        // 在激活槽位中查找
        if let index = slotConfiguration.activeSlots.firstIndex(where: { $0.mainCategory == targetCategory }) {
            switchToSlot(index: index)
        }
    }
    
    /// 选择标签（向后兼容）
    public func selectTag(_ tag: ToneTag) {
        currentTag = tag
    }
    
    /// 设置剪贴板内容
    public func setClipboard(_ content: String?) {
        clipboardContent = content
        updateContextState()
    }
    
    /// 设置原话（润色模式）
    public func setRawText(_ text: String?) {
        rawText = text
        updateContextState()
    }
    
    /// 更新上下文状态
    private func updateContextState() {
        let hasClipboard = !(clipboardContent?.isEmpty ?? true)
        let hasDraft = !(rawText?.isEmpty ?? true)
        
        switch (hasClipboard, hasDraft) {
        case (true, true): contextState = .hasBoth
        case (true, false): contextState = .hasClipboard
        case (false, true): contextState = .hasDraftText
        case (false, false): contextState = .empty
        }
    }
    
    /// 设置候选列表
    public func setCandidates(_ newCandidates: [Candidate]) {
        candidates = newCandidates
        loadingState = .idle
        // 自动选中第一个候选
        selectedCandidateIndex = 0
    }
    
    /// 替换单个候选
    public func replaceCandidate(at index: Int, with candidate: Candidate) {
        guard index >= 0 && index < candidates.count else { return }
        candidates[index] = candidate
    }
    
    /// 选择候选（第 2、3 项时替换输入区）
    public func selectCandidate(at index: Int) {
        guard index >= 0 && index < candidates.count else { return }
        selectedCandidateIndex = index
    }
    
    /// 获取当前选中的候选文本
    public var selectedCandidateText: String? {
        guard selectedCandidateIndex >= 0 && selectedCandidateIndex < candidates.count else {
            return nil
        }
        return candidates[selectedCandidateIndex].text
    }
    
    /// 开始生成
    public func startGenerating(cardId: UUID? = nil) {
        loadingState = .generating(cardId: cardId)
    }
    
    /// 设置错误
    public func setError(_ message: String) {
        loadingState = .error(message: message)
    }
    
    /// 清空所有
    public func clearAll() {
        candidates = []
        clipboardContent = nil
        rawText = nil
        contextState = .empty
        loadingState = .idle
        selectedCandidateIndex = 0
    }
    
    /// 是否可以生成
    public var canGenerate: Bool {
        switch currentSlot.mainCategory {
        case .reply, .rolePlay:
            return contextState != .empty || permissionState == .enabledFullAccess
        case .opener:
            return permissionState == .enabledFullAccess
        case .polish:
            return contextState == .hasDraftText || contextState == .hasBoth
        case .lifeWiki:
            return contextState != .empty || permissionState == .enabledFullAccess
        }
    }
    
    /// 是否有候选
    public var hasCandidates: Bool {
        return !candidates.isEmpty
    }
    
    /// 获取输入内容（用于生成）
    public var inputContent: String {
        switch currentSlot.mainCategory {
        case .reply, .rolePlay, .lifeWiki:
            return clipboardContent ?? ""
        case .opener:
            return ""  // 开场模式不需要输入
        case .polish:
            return rawText ?? ""
        }
    }
}
