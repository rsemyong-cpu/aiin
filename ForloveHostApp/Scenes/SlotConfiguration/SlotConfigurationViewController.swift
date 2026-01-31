import UIKit

// MARK: - 槽位配置页面
// 允许用户配置 6 个主分类的子分类和风格参数，并选择 3 个激活槽位

class SlotConfigurationViewController: UIViewController {
    
    // MARK: - 属性
    
    private var slotConfiguration: UserSlotConfiguration = .default
    private let store = AppGroupStore.store
    
    // MARK: - 子视图
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "分类配置"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = DesignSystem.Colors.textPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择 3 个分类在输入法中使用\n点击卡片编辑子分类和风格参数"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = DesignSystem.Colors.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var activeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = DesignSystem.Colors.goldPrimary
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "保存配置"
        config.baseBackgroundColor = DesignSystem.Colors.goldPrimary
        config.baseForegroundColor = DesignSystem.Colors.textOnGold
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(saveConfiguration), for: .touchUpInside)
        return button
    }()
    
    private var slotCardViews: [SlotCardView] = []
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadConfiguration()
        buildSlotCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        title = "分类配置"
        
        // 导航栏配置
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "重置",
            style: .plain,
            target: self,
            action: #selector(resetConfiguration)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header
        let headerStack = UIStackView(arrangedSubviews: [headerLabel, subtitleLabel, activeCountLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        contentStackView.addArrangedSubview(headerStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func loadConfiguration() {
        slotConfiguration = store.loadSlotConfiguration()
        updateActiveCountLabel()
    }
    
    private func buildSlotCards() {
        // 移除旧的卡片（保留 header）
        slotCardViews.forEach { $0.removeFromSuperview() }
        slotCardViews.removeAll()
        
        // 移除保存按钮容器
        if let buttonContainer = contentStackView.arrangedSubviews.last, buttonContainer != contentStackView.arrangedSubviews.first {
            buttonContainer.removeFromSuperview()
        }
        
        // 添加分类卡片
        for slot in slotConfiguration.allSlots {
            let card = SlotCardView(slot: slot, isActive: slotConfiguration.activeSlotIds.contains(slot.id))
            card.delegate = self
            slotCardViews.append(card)
            contentStackView.addArrangedSubview(card)
        }
        
        // 添加保存按钮
        let buttonContainer = UIView()
        buttonContainer.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(buttonContainer)
    }
    
    private func updateActiveCountLabel() {
        let count = slotConfiguration.activeSlotIds.count
        activeCountLabel.text = "已选择 \(count)/3 个分类"
        activeCountLabel.textColor = count == 3 ? DesignSystem.Colors.goldPrimary : DesignSystem.Colors.textSecondary
        
        // 更新保存按钮状态
        saveButton.isEnabled = count == 3
        saveButton.alpha = count == 3 ? 1.0 : 0.5
    }
    
    private func refreshCardForSlot(_ slot: CategorySlot) {
        // 找到对应的卡片并更新
        if let cardIndex = slotCardViews.firstIndex(where: { $0.slot.id == slot.id }) {
            let card = slotCardViews[cardIndex]
            card.updateSlot(slot)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func saveConfiguration() {
        guard slotConfiguration.activeSlotIds.count == 3 else {
            showAlert(title: "提示", message: "请选择 3 个分类")
            return
        }
        
        store.saveSlotConfiguration(slotConfiguration)
        
        // 震动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        showAlert(title: "保存成功", message: "配置已保存，输入法将使用新的分类设置") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func resetConfiguration() {
        let alert = UIAlertController(title: "重置配置", message: "确定要恢复默认配置吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "重置", style: .destructive) { [weak self] _ in
            self?.slotConfiguration = .default
            self?.buildSlotCards()
            self?.updateActiveCountLabel()
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - SlotCardViewDelegate

extension SlotConfigurationViewController: SlotCardViewDelegate {
    func slotCardDidToggleActive(_ card: SlotCardView, slot: CategorySlot, isActive: Bool) {
        if isActive {
            // 添加到激活列表
            if !slotConfiguration.activeSlotIds.contains(slot.id) {
                if slotConfiguration.activeSlotIds.count >= 3 {
                    // 已满，提示用户
                    showAlert(title: "提示", message: "最多只能选择 3 个分类，请先取消一个")
                    card.setActive(false)
                    return
                }
                slotConfiguration.activeSlotIds.append(slot.id)
            }
        } else {
            // 从激活列表移除
            slotConfiguration.activeSlotIds.removeAll { $0 == slot.id }
        }
        updateActiveCountLabel()
    }
    
    func slotCardDidTapEdit(_ card: SlotCardView, slot: CategorySlot) {
        let editVC = SlotEditViewControllerV2(slot: slot) { [weak self] updatedSlot in
            self?.slotConfiguration.updateSlot(updatedSlot)
            self?.refreshCardForSlot(updatedSlot)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// 保存逻辑已在 V2 闭包中处理

// MARK: - 槽位卡片视图

protocol SlotCardViewDelegate: AnyObject {
    func slotCardDidToggleActive(_ card: SlotCardView, slot: CategorySlot, isActive: Bool)
    func slotCardDidTapEdit(_ card: SlotCardView, slot: CategorySlot)
}

class SlotCardView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: SlotCardViewDelegate?
    private(set) var slot: CategorySlot
    private var isActive: Bool
    
    // MARK: - 子视图
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignSystem.Colors.goldPrimary
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = DesignSystem.Colors.textPrimary
        return label
    }()
    
    private lazy var subCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = DesignSystem.Colors.goldPrimary
        return label
    }()
    
    private lazy var activeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = DesignSystem.Colors.goldPrimary
        toggle.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return toggle
    }()
    
    private lazy var editButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")
        config.baseForegroundColor = DesignSystem.Colors.textDisabled
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 初始化
    
    init(slot: CategorySlot, isActive: Bool) {
        self.slot = slot
        self.isActive = isActive
        super.init(frame: .zero)
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = 12
        DesignSystem.Shadow.applyCard(to: layer)
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subCategoryLabel)
        addSubview(activeSwitch)
        addSubview(editButton)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        activeSwitch.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 72), // 固定高度更整洁
            
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            
            subCategoryLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            subCategoryLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            
            // 开关前移，放在箭头按钮的左侧，增加间距
            activeSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            activeSwitch.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -16),
            
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 使卡片可点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tap)
    }
    
    private func configure() {
        iconView.image = UIImage(systemName: slot.mainCategory.icon)
        titleLabel.text = slot.mainCategory.rawValue
        subCategoryLabel.text = "· \(slot.selectedSubCategory.rawValue)"
        activeSwitch.isOn = isActive
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isActive {
            layer.borderWidth = 2
            layer.borderColor = DesignSystem.Colors.goldPrimary.cgColor
            backgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.05)
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
            backgroundColor = DesignSystem.Colors.bgCard
        }
    }
    
    // MARK: - 公开方法
    
    func setActive(_ active: Bool) {
        isActive = active
        activeSwitch.isOn = active
        updateAppearance()
    }
    
    func updateSlot(_ newSlot: CategorySlot) {
        slot = newSlot
        configure()
    }
    
    // MARK: - 事件处理
    
    @objc private func switchToggled() {
        isActive = activeSwitch.isOn
        updateAppearance()
        delegate?.slotCardDidToggleActive(self, slot: slot, isActive: isActive)
    }
    
    @objc private func editTapped() {
        delegate?.slotCardDidTapEdit(self, slot: slot)
    }
    
    @objc private func cardTapped() {
        delegate?.slotCardDidTapEdit(self, slot: slot)
    }
}

// --- 旧版 SlotEditViewController 已移除 ---
