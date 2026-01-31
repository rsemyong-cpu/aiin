import UIKit

// MARK: - 槽位标签栏视图
// 显示用户激活的 3 个槽位，支持切换

protocol SlotTabsViewDelegate: AnyObject {
    func didSelectSlot(at index: Int)
}

class SlotTabsView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: SlotTabsViewDelegate?
    private var slots: [CategorySlot] = []
    private var selectedIndex: Int = 0
    private var tabButtons: [SlotTabButton] = []
    
    // MARK: - 子视图
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: DesignSystem.Spacing.sm),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -DesignSystem.Spacing.sm),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - 公开方法
    
    /// 设置槽位列表
    func setSlots(_ slots: [CategorySlot], selectedIndex: Int = 0) {
        self.slots = slots
        self.selectedIndex = selectedIndex
        
        // 清除现有按钮
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        // 创建新按钮
        for (index, slot) in slots.enumerated() {
            let button = SlotTabButton(slot: slot, index: index)
            button.delegate = self
            button.setSelected(index == selectedIndex)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    /// 选择槽位
    func selectSlot(at index: Int) {
        guard index >= 0 && index < tabButtons.count else { return }
        
        // 取消之前选中
        tabButtons[selectedIndex].setSelected(false)
        
        // 选中新的
        selectedIndex = index
        tabButtons[index].setSelected(true)
        
        // 滚动到可见区域
        let button = tabButtons[index]
        scrollView.scrollRectToVisible(button.frame.insetBy(dx: -20, dy: 0), animated: true)
    }
}

// MARK: - SlotTabButtonDelegate

extension SlotTabsView: SlotTabButtonDelegate {
    func slotTabButtonDidTap(_ button: SlotTabButton, index: Int) {
        guard index != selectedIndex else { return }
        selectSlot(at: index)
        delegate?.didSelectSlot(at: index)
    }
}

// MARK: - 槽位标签按钮

protocol SlotTabButtonDelegate: AnyObject {
    func slotTabButtonDidTap(_ button: SlotTabButton, index: Int)
}

class SlotTabButton: UIView {
    
    // MARK: - 属性
    
    weak var delegate: SlotTabButtonDelegate?
    private let slot: CategorySlot
    private let index: Int
    private var isSelectedState: Bool = false
    
    // MARK: - 子视图
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignSystem.Colors.textSecondary
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        label.textColor = DesignSystem.Colors.textDisabled
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.goldPrimary
        view.layer.cornerRadius = 1.5
        view.isHidden = true
        return view
    }()
    
    // MARK: - 初始化
    
    init(slot: CategorySlot, index: Int) {
        self.slot = slot
        self.index = index
        super.init(frame: .zero)
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subLabel)
        addSubview(selectionIndicator)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 宽度约束
            widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            subLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            selectionIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectionIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        // 添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    private func configure() {
        iconView.image = UIImage(systemName: slot.mainCategory.icon)
        titleLabel.text = slot.mainCategory.rawValue
        subLabel.text = slot.selectedSubCategory.rawValue
    }
    
    // MARK: - 公开方法
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        
        UIView.animate(withDuration: 0.2) {
            if selected {
                self.iconView.tintColor = DesignSystem.Colors.goldPrimary
                self.titleLabel.textColor = DesignSystem.Colors.goldPrimary
                self.titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
                self.subLabel.textColor = DesignSystem.Colors.goldSecondary
                self.selectionIndicator.isHidden = false
            } else {
                self.iconView.tintColor = DesignSystem.Colors.textSecondary
                self.titleLabel.textColor = DesignSystem.Colors.textSecondary
                self.titleLabel.font = DesignSystem.Typography.caption
                self.subLabel.textColor = DesignSystem.Colors.textDisabled
                self.selectionIndicator.isHidden = true
            }
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap() {
        // 震动反馈
        if FeatureFlags.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        delegate?.slotTabButtonDidTap(self, index: index)
    }
}
