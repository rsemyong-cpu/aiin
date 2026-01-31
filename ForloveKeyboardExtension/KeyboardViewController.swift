import UIKit

// MARK: - 键盘主控制器 V2
// 支持新的槽位矩阵系统和候选展示逻辑

class KeyboardViewController: UIInputViewController {
    
    // MARK: - 状态
    
    private let state = KeyboardState()
    private let settingsReader = SharedSettingsReader()
    private let fullAccessChecker = FullAccessChecker()
    
    /// 防止重复请求的标志
    private var isGenerating = false
    
    /// 上次请求时间（用于限流）
    private var lastRequestTime: Date?
    private let minRequestInterval: TimeInterval = 1.0  // 最小请求间隔 1 秒
    
    /// 当前显示的候选（最多 3 个）
    private var allCandidates: [Candidate] = []
    
    /// 当选显示的候选数量 (2 或 3)
    private var candidateDisplayCount: Int = 3
    
    /// 当前显示的次席候选索引 (默认为 1)
    private var alternateDisplayIndex: Int = 1
    
    // MARK: - UI 组件
    
    private lazy var rootView: KeyboardRootView = {
        let view = KeyboardRootView(state: state)
        view.delegate = self
        return view
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkPermissions()
        loadSlotConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        state.saveState()
        // 取消未完成的请求
        ExtensionNetworkClient.shared.cancelCurrentRequest()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 设置背景色
        view.backgroundColor = DesignSystem.Colors.bgMain
        
        // 添加根视图
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootView.heightAnchor.constraint(equalToConstant: 280).withPriority(.almostRequired)
        ])
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension UILayoutPriority {
    static let almostRequired = UILayoutPriority(999)
}

extension KeyboardViewController {
    
    // MARK: - 权限检查
    
    private func checkPermissions() {
        // 仅在 state 中记录权限，UI 已简化
        if fullAccessChecker.hasFullAccess {
            state.permissionState = .enabledFullAccess
        } else {
            state.permissionState = .enabledNoFullAccess
        }
    }
    
    // MARK: - 槽位配置加载
    
    private func loadSlotConfiguration() {
        // 从 App Group 加载用户配置的槽位
        state.reloadSlotConfiguration()
        
        // 更新 UI 显示当前槽位
        updateUIForCurrentSlot()
        
        // 打印配置信息用于调试
        print("🎯 [KeyboardVC] 加载槽位配置:")
        print("   激活槽位数量: \(state.slotConfiguration.activeSlots.count)")
        for (index, slot) in state.slotConfiguration.activeSlots.enumerated() {
            print("   [\(index)] \(slot.mainCategory.rawValue) - \(slot.selectedSubCategory.rawValue)")
        }
    }
    
    private func updateUIForCurrentSlot() {
        let intent = state.currentIntent
        
        // 更新 UI 显示
        rootView.updateIntent(intent)
        
        // 如果有离线模板，显示它们
        if FeatureFlags.enableOfflineTemplates && state.candidates.isEmpty {
            let templates = Candidate.offlineTemplates(for: intent)
            state.setCandidates(templates)
            rootView.updateCandidates(templates)
        }
    }
    
    // MARK: - 配置加载
    
    private func reloadSettings() {
        // 重新加载槽位配置
        state.reloadSlotConfiguration()
        
        // 强制一级主题默认到第一个（满足用户需求）
        state.activeSlotIndex = 0
        
        // 刷新顶部操作栏和槽位显示
        rootView.reloadSlots()
        updateUIForCurrentSlot()
        
        // 打印调试信息
        print("🔄 [KeyboardVC] 重新加载设置，一级主题已重置为: \(state.currentSlot.mainCategory.rawValue)")
        
        // 清空之前的候选和备选状态
        allCandidates = []
        alternateDisplayIndex = 1
        state.setCandidates([])
        rootView.clearAlternates()
    }
    
    // MARK: - 文本插入
    
    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
        
        // 可选：插入后震动反馈
        if FeatureFlags.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        // 保存到历史
        if FeatureFlags.enableHistory {
            let candidate = Candidate(text: text, tags: [state.currentSlot.selectedSubCategory.rawValue])
            AppGroupStore.store.addToHistory(candidate)
        }
    }
    
    /// 清空输入区并填入新内容
    private func replaceInputText(with text: String) {
        // 先删除当前内容
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            textDocumentProxy.deleteBackward()
        }
        
        // 插入新内容
        insertText(text)
    }
    
    // MARK: - 候选展示逻辑
    // 首选：直接录入输入区
    // 备选2/3：展示在备选展示区（前30字符预览）
    // 点击"切换"：在备选2和备选3之间切换
    // 点击"选中"：用当前备选内容替换首选
    
    private func handleCandidatesReceived(_ candidates: [Candidate]) {
        allCandidates = candidates
        alternateDisplayIndex = 1  // 初始显示备选2
        
        guard !candidates.isEmpty else { return }
        
        // 首选内容直接插入到输入框
        let firstText = candidates[0].text
        insertText(firstText)
        
        // 更新备选展示区（显示备选2的前30字符）
        rootView.updateCandidates(candidates)
        
        rootView.showToast("首选已录入，可切换/选中备选")
    }
    
    /// 更新候选展示
    private func updateCandidateDisplay() {
        // 根据 candidateDisplayCount 决定显示多少个候选
        var displayCandidates: [Candidate] = []
        
        if allCandidates.isEmpty {
            state.setCandidates([])
            rootView.updateCandidates([])
            return
        }
        
        // 始终添加第一条
        displayCandidates.append(allCandidates[0])
        
        // 如果设置为显示 3 个，且有足够候选，则添加第 2 和第 3 条
        if candidateDisplayCount == 3 {
            if allCandidates.count > 1 { displayCandidates.append(allCandidates[1]) }
            if allCandidates.count > 2 { displayCandidates.append(allCandidates[2]) }
        } else {
            // 如果设置为显示 2 个，显示第一条和当前选中的“备选”条
            if allCandidates.count > alternateDisplayIndex {
                displayCandidates.append(allCandidates[alternateDisplayIndex])
            }
        }
        
        state.setCandidates(displayCandidates)
        rootView.updateCandidates(displayCandidates)
    }
    
    /// 换一条（在 2 候选模式下切换备选内容）
    private func switchAlternateCandidate() {
        guard allCandidates.count >= 3 else {
            rootView.showToast("没有更多候选了")
            return
        }
        
        alternateDisplayIndex = (alternateDisplayIndex == 1) ? 2 : 1
        let text = (alternateDisplayIndex == 1) ? "第二条" : "第三条"
        rootView.showToast("已切换到 \(text)")
        
        updateCandidateDisplay()
        
        if FeatureFlags.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    /// 用当前备选候选内容替换输入区
    private func replaceWithAlternateCandidate() {
        // 找到当前正在显示的非首位候选
        let targetIndex = (candidateDisplayCount == 3) ? 1 : alternateDisplayIndex
        
        guard targetIndex < allCandidates.count else {
            rootView.showToast("无可替换内容")
            return
        }
        
        let text = allCandidates[targetIndex].text
        replaceInputText(with: text)
        
        rootView.showToast("已替换")
        
        if FeatureFlags.enableHapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    // MARK: - 键盘控制
    
    override func textWillChange(_ textInput: UITextInput?) {
        // 文本即将变化时调用
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // 文本变化后更新 UI
    }
}

// MARK: - KeyboardRootViewDelegate

extension KeyboardViewController: KeyboardRootViewDelegate {
    
    func didTapInsert(text: String) {
        insertText(text)
    }
    
    func didTapCopy(text: String) {
        UIPasteboard.general.string = text
        
        // 震动反馈
        if FeatureFlags.enableHapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        rootView.showToast("已复制")
    }
    
    func didTapPaste() {
        if let content = UIPasteboard.general.string, !content.isEmpty {
            state.setClipboard(content)
            rootView.showToast("读取成功，请点击二级主题生成回复")
            
            // 不再自动生成，等待用户点击二级主题
        } else {
            rootView.showToast("剪贴板为空")
        }
    }
    
    func didTapClear() {
        // 清空输入区（删除输入框中的所有内容）
        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            textDocumentProxy.deleteBackward()
        }
        
        // 清空状态
        state.clearAll()
        allCandidates = []
        alternateDisplayIndex = 1
        state.setCandidates([])
        
        // 清空展示区
        rootView.clearAlternates()
        
        rootView.showToast("已清空")
    }
    
    func didTapDelete() {
        // 删除输入框中的内容（向前删除一个字符）
        textDocumentProxy.deleteBackward()
        
        // 震动反馈
        if FeatureFlags.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func didTapSend() {
        // 检查输入框是否有内容
        if let context = textDocumentProxy.documentContextBeforeInput, !context.isEmpty {
            // 插入换行符尝试触发发送
            textDocumentProxy.insertText("\n")
            
            // 震动反馈
            if FeatureFlags.enableHapticFeedback {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            rootView.showToast("已发送")
        } else {
            rootView.showToast("请先填入内容")
        }
    }
    
    func didTapHistory() {
        state.showingHistory = true
    }
    
    func didTapSettings() {
        state.showingPermissionGuide = true
    }
    
    func didTapRefresh(at index: Int) {
        if index == 0 {
            generateCandidatesWithSlot()
        } else {
            switchAlternateCandidate()
        }
    }
    
    func didToggleCandidateCount(to count: Int) {
        // 切换备选展示（在备选2和备选3之间切换）
        rootView.switchAlternateDisplay()
    }
    
    func didReplaceWithAlternate() {
        // 获取当前展示的备选内容，并替换到输入区
        guard let alternateText = rootView.getCurrentAlternateText() else {
            rootView.showToast("无可替换内容")
            return
        }
        
        replaceInputText(with: alternateText)
        rootView.showToast("已选中并录入")
        
        if FeatureFlags.enableHapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func didSelectSubCategory(at index: Int) {
        // 更新选中的二级分类
        state.selectSubCategory(at: index)
        
        // 核心逻辑：如果是“帮开场”，即使内容为空也直接提交 API
        if state.currentSlot.mainCategory == .opener {
            generateCandidatesWithSlot()
            return
        }
        
        // 其他模式逻辑：如果剪贴板有内容或文本框有内容，直接提交
        let content = state.inputContent
        if !content.isEmpty {
            generateCandidatesWithSlot()
        } else {
            rootView.showToast("请先在下方点击[粘贴]读取内容")
        }
    }
    
    func didSwitchIntent(to intent: GenerationIntent) {
        state.switchIntent(to: intent)
        rootView.updateIntent(intent)
        
        // 清空候选
        allCandidates = []
        alternateDisplayIndex = 1
        
        // 更新候选
        if FeatureFlags.enableOfflineTemplates && state.candidates.isEmpty {
            let templates = Candidate.offlineTemplates(for: intent)
            state.setCandidates(templates)
            rootView.updateCandidates(templates)
        }
    }
    
    func didSelectTag(_ tag: ToneTag) {
        state.selectTag(tag)
    }
    
    func didTapGenerate() {
        generateCandidatesWithSlot()
    }
    
    func didTapReplace(text: String) {
        replaceInputText(with: text)
    }
    
    func didTapNextKeyboard() {
        advanceToNextInputMode()
    }
}

// MARK: - 生成逻辑（使用槽位系统）

extension KeyboardViewController {
    
    /// 网络客户端
    private var networkClient: ExtensionNetworkClient {
        return ExtensionNetworkClient.shared
    }
    
    /// 使用槽位系统生成候选列表
    private func generateCandidatesWithSlot() {
        // 1. 权限与状态检查
        let hasAccess = fullAccessChecker.hasFullAccess
        print("🔍 [KeyboardVC] 预检 - Full Access: \(hasAccess)")
        
        if !hasAccess {
            rootView.showToast("请求失败：请开启[允许完全访问]")
            return
        }

        // 限流：防止频繁请求
        if let lastTime = lastRequestTime, Date().timeIntervalSince(lastTime) < minRequestInterval {
            rootView.showToast("请稍后再试")
            return
        }
        
        // 防止重复请求
        guard !isGenerating else { return }
        
        isGenerating = true
        lastRequestTime = Date()
        state.startGenerating()
        
        // 获取当前配置
        let currentSlot = state.currentSlot
        let identity = settingsReader.loadIdentity()
        let inputContent = state.inputContent
        
        print("📤 [KeyboardVC] 尝试调用 API: \(currentSlot.mainCategory.rawValue)[\(currentSlot.selectedSubCategory.rawValue)]")
        print("   用户身份: \(identity.displayName), 角色: \(identity.persona.rawValue)")
        
        // 调用新的槽位 API
        networkClient.generate(
            slot: currentSlot,
            content: inputContent,
            identity: identity,
            chatContext: nil
        ) { [weak self] result in
            guard let self = self else { return }
            self.isGenerating = false
            
            switch result {
            case .success(let candidates):
                print("✅ [KeyboardVC] API 返回成功")
                self.handleCandidatesReceived(candidates)
                self.state.loadingState = .idle
                
            case .failure(let error):
                print("❌ [KeyboardVC] API 请求失败: \(error.localizedDescription)")
                
                // 只有在非取消导致的错误时才显示 Toast
                if case .networkError(let nsError as NSError) = error, nsError.code == NSURLErrorCancelled {
                    // Ignore cancellation
                } else {
                    self.rootView.showToast("网络不稳定，已切换本地备选")
                }
                
                // 降级：使用本地智能生成
                let fallbackCandidates = self.generateLocalFallback(for: currentSlot)
                self.handleCandidatesReceived(fallbackCandidates)
                self.state.loadingState = .idle
            }
        }
    }
    
    /// 本地降级生成
    private func generateLocalFallback(for slot: CategorySlot) -> [Candidate] {
        let inputContent = state.inputContent
        let tag = slot.selectedSubCategory.rawValue
        
        switch slot.mainCategory {
        case .reply:
            return generateReplyToMessage(inputContent, tag: tag)
        case .opener:
            return generateOpeners(tag: tag)
        case .polish:
            return polishText(inputContent, tag: tag)
        case .rolePlay:
            return generateRolePlay(inputContent, tag: tag)
        case .lifeWiki:
            return generateLifeWiki(inputContent, tag: tag)
        }
    }
    
    /// 根据对方消息生成回复
    private func generateReplyToMessage(_ message: String, tag: String) -> [Candidate] {
        guard !message.isEmpty else {
            return [
                Candidate(text: "我在想怎么开个好头呢...", tags: [tag]),
                Candidate(text: "准备开启话题挑战！", tags: [tag]),
                Candidate(text: "在呢，咱们聊点什么有意思的？", tags: [tag])
            ]
        }
        
        var replies: [String] = []
        
        if message.contains("你好") || message.contains("在吗") {
            replies = ["在呢在呢～", "嗨！在的", "来啦来啦！怎么了"]
        } else if message.contains("最近") || message.contains("怎么样") {
            replies = ["还不错呀，就是有点忙", "挺好的～你呢", "一般般吧"]
        } else if message.contains("吃饭") || message.contains("出来") {
            replies = ["好呀！什么时候", "可以啊，你想去哪", "看情况诶"]
        } else {
            replies = ["好滴，我再想想怎么回你更好", "确实是这样，我也在考虑这个问题", "你说的很有道理，我完全赞同"]
        }
        
        return replies.map { Candidate(text: $0, tags: [tag]) }
    }
    
    /// 生成开场白
    private func generateOpeners(tag: String) -> [Candidate] {
        let openers = [
            "嗨～在忙什么呢",
            "好久不见！最近有什么新鲜事吗",
            "刚看到你的动态，挺有趣的"
        ]
        return openers.map { Candidate(text: $0, tags: [tag]) }
    }
    
    /// 润色文本
    private func polishText(_ text: String, tag: String) -> [Candidate] {
        guard !text.isEmpty else {
            return [Candidate(text: "（请先输入需要润色的内容）", tags: ["提示"])]
        }
        
        return [
            Candidate(text: text + "～", tags: [tag]),
            Candidate(text: "其实呢，" + text, tags: [tag]),
            Candidate(text: text + " 😊", tags: [tag])
        ]
    }
    
    /// 角色代入回复
    private func generateRolePlay(_ question: String, tag: String) -> [Candidate] {
        return [
            Candidate(text: "既然你问到我了，那我肯定得给你点真本事看看...", tags: [tag]),
            Candidate(text: "这事儿落我手里，那就是找对人了，听好...", tags: [tag]),
            Candidate(text: "这波操作我熟，看我怎么给你秀翻全场...", tags: [tag])
        ]
    }
    
    /// 生成生活百科
    private func generateLifeWiki(_ question: String, tag: String) -> [Candidate] {
        return [
            Candidate(text: "这个问题的核心在于...", tags: [tag]),
            Candidate(text: "简单来说，你可以这样做...", tags: [tag]),
            Candidate(text: "根据实际经验，建议您...", tags: [tag])
        ]
    }
}

// MARK: - 扩展委托：处理第二栏替换

extension KeyboardViewController {
    /// 用备选内容替换输入区（供 UI 调用）
    func didTapReplaceWithAlternate() {
        replaceWithAlternateCandidate()
    }
}
