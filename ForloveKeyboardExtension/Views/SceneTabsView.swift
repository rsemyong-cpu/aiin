import UIKit

// MARK: - 场景标签视图
// 横向滚动的场景/风格标签选择

protocol SceneTabsViewDelegate: AnyObject {
    func didSelectTag(_ tag: ToneTag)
}

class SceneTabsView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: SceneTabsViewDelegate?
    private var tags: [ToneTag] = []
    private var selectedTag: ToneTag?
    
    // MARK: - 子视图
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentInset = UIEdgeInsets(top: 0, left: DesignSystem.Spacing.sm, bottom: 0, right: DesignSystem.Spacing.sm)
        return scroll
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.xs
        stack.alignment = .center
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
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - 公开方法
    
    func setTags(_ tags: [ToneTag]) {
        self.tags = tags
        rebuildChips()
    }
    
    func selectTag(_ tag: ToneTag?) {
        selectedTag = tag
        updateSelection()
    }
    
    // MARK: - 私有方法
    
    private func rebuildChips() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in tags {
            let chip = ChipButton(title: tag.rawValue)
            chip.tag = tags.firstIndex(of: tag) ?? 0
            chip.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(chip)
        }
        
        updateSelection()
    }
    
    private func updateSelection() {
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            guard let chip = view as? ChipButton else { continue }
            chip.isSelected = (tags[safe: index] == selectedTag)
        }
    }
    
    @objc private func chipTapped(_ sender: ChipButton) {
        guard let tag = tags[safe: sender.tag] else { return }
        selectedTag = tag
        updateSelection()
        delegate?.didSelectTag(tag)
    }
}

// MARK: - Chip 按钮

class ChipButton: UIButton {
    
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
        titleLabel?.font = DesignSystem.Typography.caption
        layer.cornerRadius = DesignSystem.Radius.chip
        layer.borderWidth = 1
        clipsToBounds = true
        
        // 使用现代 API 设置内边距
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: DesignSystem.Components.chipPaddingV,
            leading: DesignSystem.Components.chipPaddingH,
            bottom: DesignSystem.Components.chipPaddingV,
            trailing: DesignSystem.Components.chipPaddingH
        )
        self.configuration = config
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        UIView.animate(withDuration: DesignSystem.Animation.modeSwitchDuration) {
            if self.isSelected {
                self.backgroundColor = DesignSystem.Colors.goldSelectedBg
                self.layer.borderColor = DesignSystem.Colors.borderGold.cgColor
                self.setTitleColor(DesignSystem.Colors.goldPrimary, for: .normal)
            } else {
                self.backgroundColor = DesignSystem.Colors.bgSubtle
                self.layer.borderColor = UIColor.clear.cgColor
                self.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
            }
        }
    }
}

// MARK: - Array 安全下标

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
