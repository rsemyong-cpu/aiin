import UIKit

// MARK: - 空状态视图
// 权限引导和无内容提示

protocol EmptyStateViewDelegate: AnyObject {
    func didTapPrimaryAction()
    func didTapSecondaryAction()
}

class EmptyStateView: UIView {
    
    // MARK: - 空状态类型
    
    enum EmptyType {
        case noKeyboard      // 未启用键盘
        case noFullAccess    // 未开启完全访问
        case noContext       // 无上下文
    }
    
    // MARK: - 属性
    
    weak var delegate: EmptyStateViewDelegate?
    private var currentType: EmptyType = .noContext
    
    // MARK: - 子视图
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.bgCard
        view.layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: view.layer)
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    
    private lazy var primaryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = DesignSystem.Colors.goldPrimary
        config.baseForegroundColor = DesignSystem.Colors.textOnGold
        config.background.cornerRadius = 18
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24)
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyHintLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textDisabled
        label.textAlignment = .center
        label.text = "我们不会收集敏感信息"
        return label
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
        addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(primaryButton)
        containerView.addSubview(secondaryButton)
        containerView.addSubview(privacyHintLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        privacyHintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding = DesignSystem.Components.cardPadding
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: DesignSystem.Spacing.xs),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xxs),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            primaryButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignSystem.Spacing.sm),
            primaryButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: DesignSystem.Spacing.xs),
            secondaryButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            privacyHintLabel.topAnchor.constraint(equalTo: secondaryButton.bottomAnchor, constant: DesignSystem.Spacing.xs),
            privacyHintLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            privacyHintLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -padding)
        ])
    }
    
    // MARK: - 公开方法
    
    func configure(for type: EmptyType) {
        currentType = type
        
        switch type {
        case .noKeyboard:
            iconLabel.text = "⌨️"
            titleLabel.text = "还没启用 Forlove 键盘"
            subtitleLabel.text = "需要在系统设置中启用"
            updatePrimaryButtonTitle("去系统设置")
            secondaryButton.setTitle("查看教程", for: .normal)
            privacyHintLabel.isHidden = true
            secondaryButton.isHidden = false
            
        case .noFullAccess:
            iconLabel.text = "🔒"
            titleLabel.text = "需要开启\"允许完全访问\""
            subtitleLabel.text = "才能生成内容"
            updatePrimaryButtonTitle("去主 App 看教程")
            secondaryButton.setTitle("先用离线话术", for: .normal)
            privacyHintLabel.isHidden = false
            secondaryButton.isHidden = false
            
        case .noContext:
            iconLabel.text = "💬"
            titleLabel.text = "点\"粘贴对方消息\""
            subtitleLabel.text = "生成更准确的回复"
            updatePrimaryButtonTitle("粘贴对方消息")
            secondaryButton.isHidden = true
            privacyHintLabel.isHidden = true
        }
    }
    
    private func updatePrimaryButtonTitle(_ title: String) {
        var config = primaryButton.configuration ?? UIButton.Configuration.filled()
        config.title = title
        primaryButton.configuration = config
    }
    
    // MARK: - 事件处理
    
    @objc private func primaryTapped() {
        delegate?.didTapPrimaryAction()
    }
    
    @objc private func secondaryTapped() {
        delegate?.didTapSecondaryAction()
    }
}
