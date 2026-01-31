import UIKit

// MARK: - 候选列表视图 V2
// 新的展示逻辑：
// - 第一条：已填入输入区（显示"已填入"状态）
// - 第二条：预览候选（显示"换一条"和"替换"按钮）

protocol CandidateListViewDelegate: AnyObject {
    func didTapInsert(at index: Int, text: String)
    func didTapCopy(at index: Int, text: String)
    func didTapRefresh(at index: Int)
    func didTapReplace(text: String)  // 新增：替换输入区
}

class CandidateListView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: CandidateListViewDelegate?
    private var candidates: [Candidate] = []
    
    /// 显示候选数量（2 或 3）
    private var displayCount: Int = 3
    
    // MARK: - 子视图
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DesignSystem.Spacing.sm
        stack.distribution = .fill
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
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    // MARK: - 公开方法
    
    func setCandidates(_ candidates: [Candidate]) {
        self.candidates = candidates
        rebuildCards()
    }
    
    /// 设置显示候选数量
    func setDisplayCount(_ count: Int) {
        displayCount = max(2, min(3, count))
        rebuildCards()
    }
    
    func setLoading(at index: Int, loading: Bool) {
        // 找到对应的卡片并设置加载状态
        for (i, view) in stackView.arrangedSubviews.enumerated() {
            if i == index {
                if let card = view as? CandidateCardView {
                    card.setLoading(loading)
                } else if let card = view as? SecondaryCandidateCardView {
                    card.setLoading(loading)
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    private func rebuildCards() {
        // 清除现有卡片
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !candidates.isEmpty else { return }
        
        // 根据 displayCount 限制显示数量
        let limitedCandidates = Array(candidates.prefix(displayCount))
        
        // 第一条：主卡片（已填入状态）
        let firstCard = PrimaryCandidateCardView(candidate: limitedCandidates[0], index: 0)
        firstCard.delegate = self
        stackView.addArrangedSubview(firstCard)
        
        // 第二条及以后：预览卡片（换一条/替换）
        for i in 1..<limitedCandidates.count {
            let card = SecondaryCandidateCardView(candidate: limitedCandidates[i], index: i)
            card.delegate = self
            stackView.addArrangedSubview(card)
        }
    }
}

// MARK: - PrimaryCandidateCardViewDelegate

extension CandidateListView: PrimaryCandidateCardViewDelegate {
    func primaryCardDidTapRefresh(_ card: PrimaryCandidateCardView) {
        delegate?.didTapRefresh(at: 0)  // 刷新全部
    }
    
    func primaryCardDidTapCopy(_ card: PrimaryCandidateCardView, text: String) {
        delegate?.didTapCopy(at: 0, text: text)
    }
}

// MARK: - SecondaryCandidateCardViewDelegate

extension CandidateListView: SecondaryCandidateCardViewDelegate {
    func secondaryCardDidTapSwitch(_ card: SecondaryCandidateCardView) {
        delegate?.didTapRefresh(at: 1)  // 换一条（切换显示）
    }
    
    func secondaryCardDidTapReplace(_ card: SecondaryCandidateCardView, text: String) {
        delegate?.didTapReplace(text: text)
    }
    
    func secondaryCardDidTapCopy(_ card: SecondaryCandidateCardView, text: String) {
        delegate?.didTapCopy(at: 1, text: text)
    }
}

// MARK: - 向后兼容

extension CandidateListView: CandidateCardViewDelegate {
    func cardDidTapInsert(_ card: CandidateCardView, index: Int, text: String) {
        delegate?.didTapInsert(at: index, text: text)
    }
    
    func cardDidTapCopy(_ card: CandidateCardView, index: Int, text: String) {
        delegate?.didTapCopy(at: index, text: text)
    }
    
    func cardDidTapRefresh(_ card: CandidateCardView, index: Int) {
        delegate?.didTapRefresh(at: index)
    }
}

// MARK: - 主候选卡片（第一条，已填入）

protocol PrimaryCandidateCardViewDelegate: AnyObject {
    func primaryCardDidTapRefresh(_ card: PrimaryCandidateCardView)
    func primaryCardDidTapCopy(_ card: PrimaryCandidateCardView, text: String)
}

class PrimaryCandidateCardView: UIView {
    
    weak var delegate: PrimaryCandidateCardViewDelegate?
    private let candidate: Candidate
    private let index: Int
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "✓ 已填入输入区"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = DesignSystem.Colors.goldPrimary
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        return stack
    }()
    
    private lazy var refreshButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "重新生成"
        config.baseForegroundColor = DesignSystem.Colors.textSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "复制"
        config.baseForegroundColor = DesignSystem.Colors.textSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        return button
    }()
    
    init(candidate: Candidate, index: Int) {
        self.candidate = candidate
        self.index = index
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.08)
        layer.cornerRadius = DesignSystem.Radius.card
        layer.borderWidth = 1.5
        layer.borderColor = DesignSystem.Colors.goldPrimary.cgColor
        
        addSubview(statusLabel)
        addSubview(contentLabel)
        addSubview(actionsStackView)
        
        actionsStackView.addArrangedSubview(UIView())  // Spacer
        actionsStackView.addArrangedSubview(refreshButton)
        actionsStackView.addArrangedSubview(copyButton)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 14
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            contentLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            actionsStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            actionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            actionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            actionsStackView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        contentLabel.text = candidate.text
    }
    
    @objc private func refreshTapped() {
        delegate?.primaryCardDidTapRefresh(self)
    }
    
    @objc private func copyTapped() {
        delegate?.primaryCardDidTapCopy(self, text: candidate.text)
    }
}

// MARK: - 次候选卡片（第二条，预览）

protocol SecondaryCandidateCardViewDelegate: AnyObject {
    func secondaryCardDidTapSwitch(_ card: SecondaryCandidateCardView)
    func secondaryCardDidTapReplace(_ card: SecondaryCandidateCardView, text: String)
    func secondaryCardDidTapCopy(_ card: SecondaryCandidateCardView, text: String)
}

class SecondaryCandidateCardView: UIView {
    
    weak var delegate: SecondaryCandidateCardViewDelegate?
    private let candidate: Candidate
    private let index: Int
    private var isLoading = false
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "备选方案"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = DesignSystem.Colors.textSecondary
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        return stack
    }()
    
    private lazy var switchButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "换一条"
        config.baseForegroundColor = DesignSystem.Colors.textSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.addTarget(self, action: #selector(switchTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "复制"
        config.baseForegroundColor = DesignSystem.Colors.textSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var replaceButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "替换"
        config.baseBackgroundColor = DesignSystem.Colors.goldPrimary
        config.baseForegroundColor = DesignSystem.Colors.textOnGold
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(replaceTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = DesignSystem.Colors.goldPrimary
        return indicator
    }()
    
    init(candidate: Candidate, index: Int) {
        self.candidate = candidate
        self.index = index
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = DesignSystem.Colors.bgCard
        layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: layer)
        
        addSubview(statusLabel)
        addSubview(contentLabel)
        addSubview(actionsStackView)
        addSubview(loadingIndicator)
        
        actionsStackView.addArrangedSubview(switchButton)
        actionsStackView.addArrangedSubview(UIView())  // Spacer
        actionsStackView.addArrangedSubview(copyButton)
        actionsStackView.addArrangedSubview(replaceButton)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 14
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 8),
            
            contentLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            actionsStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            actionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            actionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            actionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            actionsStackView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        contentLabel.text = candidate.text
    }
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
        switchButton.isEnabled = !loading
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    @objc private func switchTapped() {
        guard !isLoading else { return }
        delegate?.secondaryCardDidTapSwitch(self)
    }
    
    @objc private func copyTapped() {
        delegate?.secondaryCardDidTapCopy(self, text: candidate.text)
    }
    
    @objc private func replaceTapped() {
        delegate?.secondaryCardDidTapReplace(self, text: candidate.text)
    }
}
