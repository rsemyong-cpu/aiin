import UIKit

// MARK: - 首页控制器
// 主 App 首页，展示状态和快捷入口

class HomeViewController: UIViewController {
    
    // MARK: - 服务
    
    private let permissionService = PermissionService()
    
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
    
    private lazy var headerView: UIView = {
        let view = UIView()
        
        let iconLabel = UILabel()
        iconLabel.text = "💬"
        iconLabel.font = UIFont.systemFont(ofSize: 48)
        
        let titleLabel = UILabel()
        titleLabel.text = "Forlove Keyboard"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = DesignSystem.Colors.textPrimary
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "帮你回 · 帮开场 · 帮润色"
        subtitleLabel.font = DesignSystem.Typography.bodySecondary
        subtitleLabel.textColor = DesignSystem.Colors.textSecondary
        
        let stack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = DesignSystem.Spacing.xs
        stack.alignment = .center
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: DesignSystem.Spacing.lg),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -DesignSystem.Spacing.lg)
        ])
        
        return view
    }()
    
    private lazy var statusCard: KeyboardStatusCardView = {
        let card = KeyboardStatusCardView()
        card.delegate = self
        return card
    }()
    
    private lazy var menuCards: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DesignSystem.Spacing.sm
        return stack
    }()
    
    private lazy var identityCard: MenuCardView = {
        let card = MenuCardView(icon: "👤", title: "身份设置", subtitle: "设置你的称呼、角色、风格")
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(identityTapped)))
        return card
    }()
    
    private lazy var slotConfigCard: MenuCardView = {
        let card = MenuCardView(icon: "🎯", title: "分类配置", subtitle: "配置 6 大分类，选择 3 个在输入法使用")
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(slotConfigTapped)))
        return card
    }()
    
    private lazy var tutorialCard: MenuCardView = {
        let card = MenuCardView(icon: "📖", title: "使用教程", subtitle: "了解如何使用 Forlove 键盘")
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tutorialTapped)))
        return card
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatusCard()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(statusCard)
        contentStack.addArrangedSubview(menuCards)
        
        menuCards.addArrangedSubview(slotConfigCard)
        menuCards.addArrangedSubview(identityCard)
        menuCards.addArrangedSubview(tutorialCard)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: DesignSystem.Spacing.lg),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -DesignSystem.Spacing.lg),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -DesignSystem.Spacing.lg),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -DesignSystem.Spacing.lg * 2)
        ])
    }
    
    private func updateStatusCard() {
        let status = permissionService.checkKeyboardStatus()
        statusCard.configure(with: status)
    }
    
    // MARK: - 事件处理
    
    @objc private func identityTapped() {
        let vc = IdentitySettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func slotConfigTapped() {
        let vc = SlotConfigurationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tutorialTapped() {
        let vc = PermissionGuideViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - KeyboardStatusCardViewDelegate

extension HomeViewController: KeyboardStatusCardViewDelegate {
    func didTapSetupButton() {
        let vc = PermissionGuideViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 菜单卡片视图

class MenuCardView: UIView {
    
    init(icon: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(icon: String, title: String, subtitle: String) {
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: layer)
        isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystem.Typography.bodyPrimary
        titleLabel.textColor = DesignSystem.Colors.textPrimary
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = DesignSystem.Typography.caption
        subtitleLabel.textColor = DesignSystem.Colors.textSecondary
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = UIFont.systemFont(ofSize: 20)
        arrowLabel.textColor = DesignSystem.Colors.textDisabled
        
        addSubview(iconLabel)
        addSubview(textStack)
        addSubview(arrowLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.md),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textStack.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: DesignSystem.Spacing.sm),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: arrowLabel.leadingAnchor, constant: -DesignSystem.Spacing.sm),
            
            arrowLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.md),
            arrowLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.7
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
}
