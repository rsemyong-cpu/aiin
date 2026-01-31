import UIKit

// MARK: - 润色对照视图
// 展示原话和润色后的推荐对比

protocol PolishCompareViewDelegate: AnyObject {
    func didTapInsert(text: String)
    func didTapCopy(text: String)
    func didTapNextStyle()
}

class PolishCompareView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: PolishCompareViewDelegate?
    private var candidates: [Candidate] = []
    private var currentIndex: Int = 0
    
    // MARK: - 子视图
    
    private lazy var originalView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.bgSubtle
        view.layer.cornerRadius = DesignSystem.Radius.chip
        return view
    }()
    
    private lazy var originalLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textDisabled
        label.text = "原话"
        return label
    }()
    
    private lazy var originalTextLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodySecondary
        label.textColor = DesignSystem.Colors.textSecondary
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var recommendedCard: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystem.Colors.bgCard
        view.layer.cornerRadius = DesignSystem.Radius.card
        DesignSystem.Shadow.applyCard(to: view.layer)
        return view
    }()
    
    private lazy var recommendedLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.goldPrimary
        label.text = "推荐"
        return label
    }()
    
    private lazy var recommendedTextLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = DesignSystem.Spacing.sm
        stack.alignment = .center
        return stack
    }()
    
    private lazy var switchStyleButton: ActionButton = {
        let button = ActionButton(title: "换个风格", style: .secondary)
        button.addTarget(self, action: #selector(switchStyleTapped), for: .touchUpInside)
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
        addSubview(originalView)
        originalView.addSubview(originalLabel)
        originalView.addSubview(originalTextLabel)
        
        addSubview(recommendedCard)
        recommendedCard.addSubview(recommendedLabel)
        recommendedCard.addSubview(recommendedTextLabel)
        recommendedCard.addSubview(actionsStackView)
        
        actionsStackView.addArrangedSubview(switchStyleButton)
        actionsStackView.addArrangedSubview(UIView()) // Spacer
        actionsStackView.addArrangedSubview(copyButton)
        actionsStackView.addArrangedSubview(insertButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        originalView.translatesAutoresizingMaskIntoConstraints = false
        originalLabel.translatesAutoresizingMaskIntoConstraints = false
        originalTextLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedCard.translatesAutoresizingMaskIntoConstraints = false
        recommendedLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding = DesignSystem.Spacing.sm
        
        NSLayoutConstraint.activate([
            // Original View
            originalView.topAnchor.constraint(equalTo: topAnchor),
            originalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            originalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            originalLabel.topAnchor.constraint(equalTo: originalView.topAnchor, constant: padding),
            originalLabel.leadingAnchor.constraint(equalTo: originalView.leadingAnchor, constant: padding),
            
            originalTextLabel.topAnchor.constraint(equalTo: originalLabel.bottomAnchor, constant: DesignSystem.Spacing.xxs),
            originalTextLabel.leadingAnchor.constraint(equalTo: originalView.leadingAnchor, constant: padding),
            originalTextLabel.trailingAnchor.constraint(equalTo: originalView.trailingAnchor, constant: -padding),
            originalTextLabel.bottomAnchor.constraint(equalTo: originalView.bottomAnchor, constant: -padding),
            
            // Recommended Card
            recommendedCard.topAnchor.constraint(equalTo: originalView.bottomAnchor, constant: DesignSystem.Spacing.xs),
            recommendedCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            recommendedCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            recommendedCard.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            recommendedLabel.topAnchor.constraint(equalTo: recommendedCard.topAnchor, constant: padding),
            recommendedLabel.leadingAnchor.constraint(equalTo: recommendedCard.leadingAnchor, constant: padding),
            
            recommendedTextLabel.topAnchor.constraint(equalTo: recommendedLabel.bottomAnchor, constant: DesignSystem.Spacing.xxs),
            recommendedTextLabel.leadingAnchor.constraint(equalTo: recommendedCard.leadingAnchor, constant: padding),
            recommendedTextLabel.trailingAnchor.constraint(equalTo: recommendedCard.trailingAnchor, constant: -padding),
            
            actionsStackView.topAnchor.constraint(equalTo: recommendedTextLabel.bottomAnchor, constant: DesignSystem.Spacing.sm),
            actionsStackView.leadingAnchor.constraint(equalTo: recommendedCard.leadingAnchor, constant: padding),
            actionsStackView.trailingAnchor.constraint(equalTo: recommendedCard.trailingAnchor, constant: -padding),
            actionsStackView.bottomAnchor.constraint(equalTo: recommendedCard.bottomAnchor, constant: -padding),
            actionsStackView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    // MARK: - 公开方法
    
    func configure(originalText: String, candidates: [Candidate]) {
        self.candidates = candidates
        self.currentIndex = 0
        
        originalTextLabel.text = originalText
        updateRecommendedText()
    }
    
    // MARK: - 私有方法
    
    private func updateRecommendedText() {
        guard let candidate = candidates[safe: currentIndex] else {
            recommendedTextLabel.text = "（无推荐）"
            return
        }
        recommendedTextLabel.text = candidate.text
    }
    
    // MARK: - 事件处理
    
    @objc private func switchStyleTapped() {
        guard candidates.count > 1 else { return }
        currentIndex = (currentIndex + 1) % candidates.count
        
        UIView.transition(with: recommendedTextLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.updateRecommendedText()
        }
        
        delegate?.didTapNextStyle()
    }
    
    @objc private func copyTapped() {
        guard let candidate = candidates[safe: currentIndex] else { return }
        delegate?.didTapCopy(text: candidate.text)
    }
    
    @objc private func insertTapped() {
        guard let candidate = candidates[safe: currentIndex] else { return }
        delegate?.didTapInsert(text: candidate.text)
    }
}
