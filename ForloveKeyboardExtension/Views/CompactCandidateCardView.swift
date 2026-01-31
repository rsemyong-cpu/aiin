import UIKit

// MARK: - 紧凑候选卡片视图
// 用于展示第 2、3 项候选（只显示前 30 字预览）

protocol CompactCandidateCardViewDelegate: AnyObject {
    func compactCardDidTap(_ card: CompactCandidateCardView, index: Int, text: String)
}

class CompactCandidateCardView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: CompactCandidateCardViewDelegate?
    private let candidate: Candidate
    private let index: Int
    private var isSelected: Bool = false
    
    // MARK: - 子视图
    
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = DesignSystem.Colors.textDisabled
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 1
        label.layer.borderColor = DesignSystem.Colors.textDisabled.cgColor
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var previewLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodySecondary
        label.textColor = DesignSystem.Colors.textSecondary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var expandIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = DesignSystem.Colors.textDisabled
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        backgroundColor = DesignSystem.Colors.bgCard.withAlphaComponent(0.6)
        layer.cornerRadius = DesignSystem.Radius.card / 2
        layer.borderWidth = 1
        layer.borderColor = DesignSystem.Colors.divider.cgColor
        
        addSubview(indexLabel)
        addSubview(previewLabel)
        addSubview(expandIcon)
        
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        expandIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            indexLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            indexLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: 20),
            indexLabel.heightAnchor.constraint(equalToConstant: 20),
            
            previewLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 8),
            previewLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: expandIcon.leadingAnchor, constant: -8),
            
            expandIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            expandIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandIcon.widthAnchor.constraint(equalToConstant: 12),
            expandIcon.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        // 添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        // 添加触摸反馈
        isUserInteractionEnabled = true
    }
    
    private func configure(with candidate: Candidate) {
        indexLabel.text = "\(index + 1)"
        
        // 生成预览（前 30 字）
        let preview = generatePreview(candidate.text)
        previewLabel.text = preview
    }
    
    private func generatePreview(_ text: String) -> String {
        if text.count <= 30 {
            return text
        }
        return String(text.prefix(30)) + "..."
    }
    
    // MARK: - 公开方法
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        
        if selected {
            backgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.15)
            layer.borderColor = DesignSystem.Colors.goldPrimary.cgColor
            indexLabel.backgroundColor = DesignSystem.Colors.goldPrimary
            indexLabel.textColor = DesignSystem.Colors.textOnGold
            indexLabel.layer.borderColor = DesignSystem.Colors.goldPrimary.cgColor
            previewLabel.textColor = DesignSystem.Colors.textPrimary
        } else {
            backgroundColor = DesignSystem.Colors.bgCard.withAlphaComponent(0.6)
            layer.borderColor = DesignSystem.Colors.divider.cgColor
            indexLabel.backgroundColor = .clear
            indexLabel.textColor = DesignSystem.Colors.textDisabled
            indexLabel.layer.borderColor = DesignSystem.Colors.textDisabled.cgColor
            previewLabel.textColor = DesignSystem.Colors.textSecondary
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap() {
        // 震动反馈
        if FeatureFlags.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        delegate?.compactCardDidTap(self, index: index, text: candidate.text)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.alpha = 0.8
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}
