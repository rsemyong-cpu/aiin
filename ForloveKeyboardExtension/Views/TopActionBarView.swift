import UIKit

// MARK: - 顶部操作栏视图 V4
// 动态展示用户配置的 3 个激活槽位
// 右侧按钮：切换（备选2/3切换）、选中（选中当前备选）

protocol TopActionBarViewDelegate: AnyObject {
    func didSelectSlot(at index: Int)
    func didSelectIntent(_ intent: GenerationIntent)  // 向后兼容
    func didTapToggleCandidateCount()  // 切换备选展示
    func didTapReplaceWithAlternate()  // 选中备选内容
}

// 添加默认实现
extension TopActionBarViewDelegate {
    func didTapToggleCandidateCount() {}
    func didTapReplaceWithAlternate() {}
}

class TopActionBarView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: TopActionBarViewDelegate?
    private var selectedIndex: Int = 0
    private var slotButtons: [SlotPillButton] = []
    private var slots: [CategorySlot] = []
    
    /// 当前显示候选数量（2 或 3）
    private var candidateDisplayCount: Int = 3
    
    // MARK: - 子视图
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = DesignSystem.Spacing.xs
        return stack
    }()
    
    /// 切换按钮（切换备选2/3展示）
    private lazy var switchAlternateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "切换"
        config.baseBackgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.15)
        config.baseForegroundColor = DesignSystem.Colors.goldPrimary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.addTarget(self, action: #selector(switchAlternateTapped), for: .touchUpInside)
        return button
    }()
    
    /// 选中按钮（选中当前备选内容，替换首选）
    private lazy var selectAlternateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "选中"
        config.baseBackgroundColor = DesignSystem.Colors.bgSubtle
        config.baseForegroundColor = DesignSystem.Colors.textSecondary
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.addTarget(self, action: #selector(selectAlternateTapped), for: .touchUpInside)
        return button
    }()
    
    // moreButton 已删除
    
    /// 右侧操作按钮容器
    private lazy var rightActionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadSlots()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 设置右侧按钮容器（只有切换和选中按钮）
        rightActionsStack.addArrangedSubview(switchAlternateButton)
        rightActionsStack.addArrangedSubview(selectAlternateButton)
        
        addSubview(buttonsStackView)
        addSubview(rightActionsStack)
        
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        rightActionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: rightActionsStack.leadingAnchor, constant: -DesignSystem.Spacing.xs),
            
            rightActionsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightActionsStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - 备选展示切换
    
    /// 当前展示的备选索引（2 或 3）
    private var currentAlternateIndex: Int = 2
    
    /// 获取当前备选索引
    var currentCandidateCount: Int {
        return currentAlternateIndex
    }
    
    // MARK: - 加载槽位配置
    
    private func loadSlots() {
        let config = AppGroupStore.store.loadSlotConfiguration()
        slots = config.activeSlots
        
        print("🎛️ [TopActionBar] 加载槽位:")
        for (index, slot) in slots.enumerated() {
            print("   [\(index)] \(slot.mainCategory.rawValue)")
        }
        
        rebuildButtons()
    }
    
    /// 重新加载槽位（主 App 修改配置后调用）
    public func reloadSlots() {
        loadSlots()
    }
    
    private func rebuildButtons() {
        // 清除旧按钮
        slotButtons.forEach { $0.removeFromSuperview() }
        slotButtons.removeAll()
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 如果没有配置槽位，使用默认值
        if slots.isEmpty {
            let defaultSlots = [
                CategorySlot(id: 0, mainCategory: .reply),
                CategorySlot(id: 1, mainCategory: .opener),
                CategorySlot(id: 2, mainCategory: .polish)
            ]
            slots = defaultSlots
        }
        
        // 创建按钮
        for (index, slot) in slots.enumerated() {
            let button = SlotPillButton(slot: slot, index: index)
            button.addTarget(self, action: #selector(slotButtonTapped(_:)), for: .touchUpInside)
            slotButtons.append(button)
            buttonsStackView.addArrangedSubview(button)
        }
        
        // 选中第一个
        setSelectedIndex(0)
    }
    
    // MARK: - 公开方法
    
    func setSelectedIndex(_ index: Int) {
        guard index >= 0 && index < slotButtons.count else { return }
        selectedIndex = index
        
        for (i, button) in slotButtons.enumerated() {
            button.isSelected = (i == index)
        }
    }
    
    /// 向后兼容：根据 Intent 设置选中（仅在没有使用槽位系统时调用）
    func setSelectedIntent(_ intent: GenerationIntent) {
        // 注意：如果已经通过 setSelectedIndex 选中了槽位，不要重置
        // 这个方法仅用于向后兼容
    }
    
    // MARK: - 事件处理
    
    @objc private func slotButtonTapped(_ sender: SlotPillButton) {
        setSelectedIndex(sender.index)
        delegate?.didSelectSlot(at: sender.index)
        // 注意：不再调用 didSelectIntent，避免 UI 被重置
    }
    
    @objc private func switchAlternateTapped() {
        // 切换备选展示：2 ↔ 3
        currentAlternateIndex = currentAlternateIndex == 2 ? 3 : 2
        
        // 视觉反馈
        UIView.animate(withDuration: 0.1) {
            self.switchAlternateButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.switchAlternateButton.transform = .identity
            }
        }
        
        delegate?.didTapToggleCandidateCount()
    }
    
    @objc private func selectAlternateTapped() {
        // 视觉反馈
        UIView.animate(withDuration: 0.1) {
            self.selectAlternateButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.selectAlternateButton.configuration?.baseBackgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.selectAlternateButton.transform = .identity
                self.selectAlternateButton.configuration?.baseBackgroundColor = DesignSystem.Colors.bgSubtle
            }
        }
        
        delegate?.didTapReplaceWithAlternate()
    }
}

// MARK: - 槽位胶囊按钮

class SlotPillButton: UIButton {
    
    let slot: CategorySlot
    let index: Int
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    init(slot: CategorySlot, index: Int) {
        self.slot = slot
        self.index = index
        super.init(frame: .zero)
        
        // 使用主分类名称作为按钮标题
        setTitle(slot.mainCategory.rawValue, for: .normal)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        titleLabel?.font = DesignSystem.Typography.bodySecondary
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.7
        layer.cornerRadius = DesignSystem.Components.actionButtonHeight / 2
        clipsToBounds = true
        updateAppearance()
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: DesignSystem.Animation.modeSwitchDuration) {
            if self.isSelected {
                self.backgroundColor = DesignSystem.Colors.goldDisabled
                self.setTitleColor(DesignSystem.Colors.goldPrimary, for: .normal)
            } else {
                self.backgroundColor = .clear
                self.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + 16, height: DesignSystem.Components.actionButtonHeight)
    }
}

// MARK: - 向后兼容的 PillButton（保留给其他使用）

class PillButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        titleLabel?.font = DesignSystem.Typography.bodySecondary
        layer.cornerRadius = DesignSystem.Components.actionButtonHeight / 2
        clipsToBounds = true
        updateAppearance()
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: DesignSystem.Animation.modeSwitchDuration) {
            if self.isSelected {
                self.backgroundColor = DesignSystem.Colors.goldDisabled
                self.setTitleColor(DesignSystem.Colors.goldPrimary, for: .normal)
            } else {
                self.backgroundColor = .clear
                self.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + 24, height: DesignSystem.Components.actionButtonHeight)
    }
}
