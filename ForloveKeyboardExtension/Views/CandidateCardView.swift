import UIKit

// MARK: - 候选卡片视图
// 单个候选文本的卡片展示

protocol CandidateCardViewDelegate: AnyObject {
    func cardDidTapInsert(_ card: CandidateCardView, index: Int, text: String)
    func cardDidTapCopy(_ card: CandidateCardView, index: Int, text: String)
    func cardDidTapRefresh(_ card: CandidateCardView, index: Int)
}

class CandidateCardView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: CandidateCardViewDelegate?
    private let candidate: Candidate
    private let index: Int
    private var isLoading: Bool = false
    
    // MARK: - 子视图
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        label.numberOfLines = DesignSystem.Components.cardMaxLines
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var riskHintLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textDisabled
        label.text = "已为你更保守表达"
        label.isHidden = true
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        return stack
    }()
    
    private lazy var refreshButton: ActionButton = {
        let button = ActionButton(title: "换一条", style: .secondary)
        button.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: ActionButton = {
        let button = ActionButton(title: "复制", style: .secondary)
        button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var insertButton: ActionButton = {
        let button = ActionButton(title: "填入", style: .primary)
        button.addTarget(self, action: #selector(insertTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = DesignSystem.Colors.goldPrimary
        return indicator
    }()
    
    // MARK: - 初始化
    
    init(candidate: Candidate, index: Int) {
        self.candidate = candidate
        self.index = index
        super.init(frame: .zero)
        setupUI()
        configure(with: candidate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: layer)
        
        addSubview(contentLabel)
        addSubview(riskHintLabel)
        addSubview(actionsStackView)
        addSubview(loadingIndicator)
        
        actionsStackView.addArrangedSubview(UIView()) // Spacer
        actionsStackView.addArrangedSubview(refreshButton)
        actionsStackView.addArrangedSubview(copyButton)
        actionsStackView.addArrangedSubview(insertButton)
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        riskHintLabel.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let padding = DesignSystem.Components.cardPadding
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            riskHintLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: DesignSystem.Spacing.xxs),
            riskHintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            actionsStackView.topAnchor.constraint(equalTo: riskHintLabel.bottomAnchor, constant: DesignSystem.Spacing.xs),
            actionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            actionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            actionsStackView.heightAnchor.constraint(equalToConstant: 28),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -DesignSystem.Spacing.xs)
        ])
        
        // 添加长按手势（复制）
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    private func configure(with candidate: Candidate) {
        contentLabel.text = candidate.text
        riskHintLabel.isHidden = !candidate.riskFlagged
    }
    
    // MARK: - 公开方法
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
        refreshButton.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func refreshTapped() {
        guard !isLoading else { return }
        delegate?.cardDidTapRefresh(self, index: index)
    }
    
    @objc private func copyTapped() {
        delegate?.cardDidTapCopy(self, index: index, text: candidate.text)
    }
    
    @objc private func insertTapped() {
        delegate?.cardDidTapInsert(self, index: index, text: candidate.text)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // 震动反馈
            if FeatureFlags.enableHapticFeedback {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            delegate?.cardDidTapCopy(self, index: index, text: candidate.text)
        }
    }
}

// MARK: - 操作按钮

class ActionButton: UIButton {
    
    enum Style {
        case primary
        case secondary
    }
    
    private let style: Style
    
    init(title: String, style: Style) {
        self.style = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        switch style {
        case .primary:
            config.background.backgroundColor = DesignSystem.Colors.goldPrimary
            config.baseForegroundColor = DesignSystem.Colors.textOnGold
            config.background.cornerRadius = 14
        case .secondary:
            config.background.backgroundColor = .clear
            config.baseForegroundColor = DesignSystem.Colors.textSecondary
        }
        
        self.configuration = config
        self.titleLabel?.font = DesignSystem.Typography.caption
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}
