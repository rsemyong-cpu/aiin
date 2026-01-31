import UIKit

// MARK: - 权限引导控制器
// 引导用户启用键盘和开启完全访问

class PermissionGuideViewController: UIViewController {
    
    // MARK: - 子视图
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DesignSystem.Spacing.lg
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "开启 Forlove 键盘"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = DesignSystem.Colors.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var step1Card: StepCardView = {
        let card = StepCardView(
            step: 1,
            title: "打开系统设置",
            description: "设置 → 通用 → 键盘 → 键盘"
        )
        return card
    }()
    
    private lazy var step2Card: StepCardView = {
        let card = StepCardView(
            step: 2,
            title: "添加 Forlove 键盘",
            description: "点击「添加新键盘...」，找到并选择「Forlove」"
        )
        return card
    }()
    
    private lazy var step3Card: StepCardView = {
        let card = StepCardView(
            step: 3,
            title: "允许完全访问",
            description: "点击「Forlove」→ 开启「允许完全访问」"
        )
        return card
    }()
    
    private lazy var privacyCard: UIView = {
        let card = UIView()
        card.backgroundColor = DesignSystem.Colors.bgSubtle
        card.layer.cornerRadius = DesignSystem.Radius.chip
        
        let iconLabel = UILabel()
        iconLabel.text = "🔒"
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        
        let textLabel = UILabel()
        textLabel.text = "我们承诺不收集您的聊天内容和个人敏感信息"
        textLabel.font = DesignSystem.Typography.caption
        textLabel.textColor = DesignSystem.Colors.textSecondary
        textLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [iconLabel, textLabel])
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: DesignSystem.Spacing.sm),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: DesignSystem.Spacing.sm),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -DesignSystem.Spacing.sm),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -DesignSystem.Spacing.sm)
        ])
        
        return card
    }()
    
    private lazy var pasteHintCard: UIView = {
        let card = UIView()
        card.backgroundColor = DesignSystem.Colors.goldSelectedBg
        card.layer.cornerRadius = DesignSystem.Radius.chip
        card.layer.borderWidth = 1
        card.layer.borderColor = DesignSystem.Colors.borderGold.cgColor
        
        let textLabel = UILabel()
        textLabel.text = "💡 关于「粘贴提示框」：开启完全访问后，系统会在读取剪贴板时显示提示。这是 iOS 的隐私保护功能，不影响使用。"
        textLabel.font = DesignSystem.Typography.caption
        textLabel.textColor = DesignSystem.Colors.goldPrimary
        textLabel.numberOfLines = 0
        
        card.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: DesignSystem.Spacing.sm),
            textLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: DesignSystem.Spacing.sm),
            textLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -DesignSystem.Spacing.sm),
            textLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -DesignSystem.Spacing.sm)
        ])
        
        return card
    }()
    
    private lazy var openSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("去系统设置", for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.bodyPrimary
        button.backgroundColor = DesignSystem.Colors.goldPrimary
        button.setTitleColor(DesignSystem.Colors.textOnGold, for: .normal)
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var laterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("稍后再说", for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
        button.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        title = "设置键盘"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(headerLabel)
        contentStack.addArrangedSubview(step1Card)
        contentStack.addArrangedSubview(step2Card)
        contentStack.addArrangedSubview(step3Card)
        contentStack.addArrangedSubview(privacyCard)
        contentStack.addArrangedSubview(pasteHintCard)
        contentStack.addArrangedSubview(openSettingsButton)
        contentStack.addArrangedSubview(laterButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        openSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: DesignSystem.Spacing.lg),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: DesignSystem.Spacing.lg),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -DesignSystem.Spacing.lg),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -DesignSystem.Spacing.lg),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -DesignSystem.Spacing.lg * 2),
            
            openSettingsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - 事件处理
    
    @objc private func openSettingsTapped() {
        // 打开系统设置
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func laterTapped() {
        AppGroupStore.store.setPermissionGuideCompleted(true)
        goToHome()
    }
    
    private func goToHome() {
        let homeVC = HomeViewController()
        navigationController?.setViewControllers([homeVC], animated: true)
    }
}

// MARK: - 步骤卡片视图

class StepCardView: UIView {
    
    init(step: Int, title: String, description: String) {
        super.init(frame: .zero)
        setupUI(step: step, title: title, description: description)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(step: Int, title: String, description: String) {
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: layer)
        
        let stepLabel = UILabel()
        stepLabel.text = "\(step)"
        stepLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        stepLabel.textColor = DesignSystem.Colors.textOnGold
        stepLabel.textAlignment = .center
        stepLabel.backgroundColor = DesignSystem.Colors.goldPrimary
        stepLabel.layer.cornerRadius = 14
        stepLabel.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystem.Typography.bodyPrimary
        titleLabel.textColor = DesignSystem.Colors.textPrimary
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = DesignSystem.Typography.caption
        descLabel.textColor = DesignSystem.Colors.textSecondary
        descLabel.numberOfLines = 0
        
        addSubview(stepLabel)
        addSubview(titleLabel)
        addSubview(descLabel)
        
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stepLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.md),
            stepLabel.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.md),
            stepLabel.widthAnchor.constraint(equalToConstant: 28),
            stepLabel.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: stepLabel.trailingAnchor, constant: DesignSystem.Spacing.sm),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.md),
            
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xxs),
            descLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.md),
            descLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.md)
        ])
    }
}
