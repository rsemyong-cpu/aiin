import UIKit

// MARK: - 二级分类九宫格视图
// 根据用户需求：展示二级分类备选内容，3x3 九宫格布局

protocol SubCategoryGridViewDelegate: AnyObject {
    /// 选中二级分类
    func didSelectSubCategory(at index: Int)
    /// 长按二级分类（触发生成）
    func didLongPressSubCategory(at index: Int)
}

class SubCategoryGridView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: SubCategoryGridViewDelegate?
    private var subCategories: [(name: String, emoji: String)] = []
    private var selectedIndex: Int = 0
    
    // MARK: - 子视图
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SubCategoryCell.self, forCellWithReuseIdentifier: SubCategoryCell.reuseId)
        return collectionView
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
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                delegate?.didLongPressSubCategory(at: indexPath.item)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let columns: CGFloat = 3
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (columns - 1)
        let availableWidth = bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / columns)
        let itemHeight: CGFloat = 38
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.invalidateLayout()
    }
    
    // MARK: - 公开方法
    
    /// 设置二级分类列表
    func setSubCategories(_ categories: [(name: String, emoji: String)]) {
        self.subCategories = categories
        collectionView.reloadData()
    }
    
    /// 设置选中的索引
    func setSelectedIndex(_ index: Int) {
        self.selectedIndex = index
        collectionView.reloadData()
    }
    
    /// 从槽位配置加载二级分类
    func loadFromSlot(_ slot: CategorySlot) {
        var categories: [(name: String, emoji: String)] = []
        
        // 加载系统预设的二级分类（固定列表）
        for subCategory in slot.mainCategory.subCategories {
            let emoji = getDefaultEmoji(for: subCategory)
            categories.append((name: subCategory.rawValue, emoji: emoji))
        }
        
        // 限制最多 9 个（九宫格）
        let limitedCategories = Array(categories.prefix(9))
        setSubCategories(limitedCategories)
        
        // 设置当前选中的索引
        setSelectedIndex(slot.selectedSubIndex)
    }
    
    /// 获取默认表情
    private func getDefaultEmoji(for subCategory: SubCategory) -> String {
        switch subCategory {
        // Reply（帮你回）- 9个
        case .highEQ: return "🌊"
        case .flirty: return "💕"
        case .tease: return "😏"
        case .polite: return "🤝"
        case .praiseReply: return "👏"
        case .coldCEO: return "🧊"
        case .rational: return "🧠"
        case .humorResolve: return "😂"
        case .roastMode: return "🔥"
        
        // Opener（帮开场）- 6个
        case .humorBreaker: return "😄"
        case .curiousQuestion: return "🤔"
        case .momentsCutIn: return "📱"
        case .directBall: return "⚡️"
        case .dailyChat: return "☀️"
        case .lightPraise: return "✨"
        
        // Polish（帮润色）- 8个
        case .professional: return "💼"
        case .deGreasy: return "🧹"
        case .literary: return "📖"
        case .concise: return "⚡️"
        case .moreEmotional: return "💗"
        case .funnier: return "🎭"
        case .moreFormal: return "📋"
        case .moreCasual: return "💬"
        
        // RolePlay（角色代入）- 12个
        case .lawyer: return "⚖️"
        case .doctor: return "🩺"
        case .programmer: return "💻"
        case .accountant: return "🧮"
        case .topSales: return "🎯"
        case .fitnessCoach: return "💪"
        case .psychologist: return "🧘"
        case .careerMentor: return "📈"
        case .productManager: return "🎨"
        case .toxicCritic: return "🔍"
        case .philosopher: return "🌌"
        case .loveCoach: return "❤️"
        
        // LifeWiki（生活百科）- 6个
        case .quickExplain: return "💡"
        case .coreSteps: return "📝"
        case .mythBuster: return "🔬"
        case .shoppingAdvice: return "🛒"
        case .avoidPitfalls: return "⚠️"
        case .prosConsCompare: return "⚖️"
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SubCategoryGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubCategoryCell.reuseId, for: indexPath) as? SubCategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = subCategories[indexPath.item]
        cell.configure(emoji: category.emoji, name: category.name, isSelected: indexPath.item == selectedIndex)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SubCategoryGridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        
        delegate?.didSelectSubCategory(at: indexPath.item)
    }
}

// MARK: - 二级分类单元格

class SubCategoryCell: UICollectionViewCell {
    static let reuseId = "SubCategoryCell"
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = DesignSystem.Colors.textPrimary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emojiLabel, nameLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = DesignSystem.Colors.bgCard
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(emoji: String, name: String, isSelected: Bool) {
        emojiLabel.text = emoji
        nameLabel.text = name
        
        if isSelected {
            contentView.backgroundColor = DesignSystem.Colors.goldPrimary.withAlphaComponent(0.15)
            contentView.layer.borderWidth = 1.5
            contentView.layer.borderColor = DesignSystem.Colors.goldPrimary.cgColor
            nameLabel.textColor = DesignSystem.Colors.goldPrimary
        } else {
            contentView.backgroundColor = DesignSystem.Colors.bgCard
            contentView.layer.borderWidth = 0
            nameLabel.textColor = DesignSystem.Colors.textPrimary
        }
    }
}
