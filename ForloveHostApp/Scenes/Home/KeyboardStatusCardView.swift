import UIKit

// MARK: - 键盘状态卡片视图
// 显示键盘启用状态和完全访问状态

protocol KeyboardStatusCardViewDelegate: AnyObject {
    func didTapSetupButton()
}

class KeyboardStatusCardView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: KeyboardStatusCardViewDelegate?
    
    // MARK: - 子视图
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DesignSystem.Spacing.sm
        return stack
    }()
    
    private lazy var keyboardStatusRow: StatusRowView = {
        let row = StatusRowView(title: "键盘已启用")
        return row
    }()
    
    private lazy var fullAccessStatusRow: StatusRowView = {
        let row = StatusRowView(title: "已允许完全访问")
        return row
    }()
    
    private lazy var setupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("去设置", for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.bodySecondary
        button.backgroundColor = DesignSystem.Colors.goldPrimary
        button.setTitleColor(DesignSystem.Colors.textOnGold, for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(setupTapped), for: .touchUpInside)
        button.isHidden = true
        return button
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
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: layer)
        
        addSubview(containerStack)
        containerStack.addArrangedSubview(keyboardStatusRow)
        containerStack.addArrangedSubview(fullAccessStatusRow)
        containerStack.addArrangedSubview(setupButton)
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        setupButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.md),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.md),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.md),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.md),
            
            setupButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - 公开方法
    
    func configure(with status: KeyboardStatus) {
        keyboardStatusRow.setStatus(status.isKeyboardEnabled)
        fullAccessStatusRow.setStatus(status.hasFullAccess)
        
        // 如果未完全设置，显示设置按钮
        setupButton.isHidden = status.isKeyboardEnabled && status.hasFullAccess
    }
    
    // MARK: - 事件处理
    
    @objc private func setupTapped() {
        delegate?.didTapSetupButton()
    }
}

// MARK: - 状态行视图

class StatusRowView: UIView {
    
    private lazy var checkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodySecondary
        label.textColor = DesignSystem.Colors.textSecondary
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [checkLabel, titleLabel])
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.xs
        stack.alignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 28)
        ])
        
        setStatus(false)
    }
    
    func setStatus(_ enabled: Bool) {
        if enabled {
            checkLabel.text = "✅"
            titleLabel.textColor = DesignSystem.Colors.textPrimary
        } else {
            checkLabel.text = "⚪️"
            titleLabel.textColor = DesignSystem.Colors.textSecondary
        }
    }
}

// MARK: - 键盘状态模型

public struct KeyboardStatus {
    public var isKeyboardEnabled: Bool
    public var hasFullAccess: Bool
    
    public init(isKeyboardEnabled: Bool, hasFullAccess: Bool) {
        self.isKeyboardEnabled = isKeyboardEnabled
        self.hasFullAccess = hasFullAccess
    }
    
    public static let notConfigured = KeyboardStatus(isKeyboardEnabled: false, hasFullAccess: false)
    public static let fullAccess = KeyboardStatus(isKeyboardEnabled: true, hasFullAccess: true)
}
