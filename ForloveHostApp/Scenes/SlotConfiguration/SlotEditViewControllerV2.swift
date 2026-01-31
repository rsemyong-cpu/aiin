import UIKit

// MARK: - V5 槽位编辑器 (极致精修版)
// 1. 彻底移除 UITableView
// 2. 界面采用浅色卡片化布局，背景微紫色调
// 3. 二级分类列表完全铺开，直接展示，不再支持点击选中
// 4. 更新参数文案：激进风险指数、成人风格（含详细分级描述）

class SlotEditViewControllerV2: UIViewController {
    
    // MARK: - 属性
    
    private let slot: CategorySlot
    private let onSave: (CategorySlot) -> Void
    
    // MARK: - UI 组件
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        // 使用非常淡的紫色背景，确保您能看出区别
        sv.backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.0, alpha: 1.0)
        return sv
    }()
    
    private lazy var contentView = UIView()
    
    /// 1. 主分类头部
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var headerDescLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    /// 2. 二级分类容器
    private lazy var subCategoryContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    /// 3. 字数偏好
    private lazy var wordCountSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["短", "中", "长"])
        segment.selectedSegmentTintColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return segment
    }()
    
    /// 4. 激进风险指数
    private lazy var aggressionSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["低 🛡", "中 ✨", "高 🔥"])
        segment.selectedSegmentTintColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(paramChanged), for: .valueChanged)
        return segment
    }()
    
    private lazy var aggressionDescLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.text = "低：非常保守的回复\n中：保守与前沿平衡\n高：前卫激进敢说，不怕犯错"
        return label
    }()
    
    /// 5. 成人风格
    private lazy var adultStyleSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["无 ❤️", "轻 💕", "重 🔥"])
        segment.selectedSegmentTintColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(paramChanged), for: .valueChanged)
        return segment
    }()
    
    private lazy var adultStyleDescLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.text = "无：不涉及成人话题\n轻：可以加入成人暗示\n重：放开成人话题，但不要色情"
        return label
    }()
    
    // MARK: - 初始化
    
    init(slot: CategorySlot, onSave: @escaping (CategorySlot) -> Void) {
        self.slot = slot
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        // 加上 V5 标记，确保您能看到新版生效
        title = "编辑 " + slot.mainCategory.rawValue + " (V5)"
        view.backgroundColor = .white
        
        // 导航栏保存按钮
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("保存更改", for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        saveBtn.backgroundColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.layer.cornerRadius = 14
        saveBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // --- 1. 头部卡片 ---
        let headerCard = createWhiteCard()
        let headerStack = UIStackView(arrangedSubviews: [headerTitleLabel, headerDescLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 24),
            headerStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            headerStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -24)
        ])
        mainStack.addArrangedSubview(headerCard)
        
        // --- 2. 二级分类铺开列表 ---
        mainStack.addArrangedSubview(createSectionTitle("📋 包含主题（直接展现）"))
        
        let subCard = createWhiteCard()
        subCard.addSubview(subCategoryContainer)
        subCategoryContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subCategoryContainer.topAnchor.constraint(equalTo: subCard.topAnchor, constant: 16),
            subCategoryContainer.leadingAnchor.constraint(equalTo: subCard.leadingAnchor, constant: 16),
            subCategoryContainer.trailingAnchor.constraint(equalTo: subCard.trailingAnchor, constant: -16),
            subCategoryContainer.bottomAnchor.constraint(equalTo: subCard.bottomAnchor, constant: -16)
        ])
        mainStack.addArrangedSubview(subCard)
        
        // --- 3. 参数配置 ---
        mainStack.addArrangedSubview(createSectionTitle("⚙️ AI 特性控制"))
        
        mainStack.addArrangedSubview(createParamRow(title: "📝 字数偏好", segment: wordCountSegment, desc: aggressionDescLabel))
        mainStack.addArrangedSubview(createParamRow(title: "⚡ 激进风险指数", segment: aggressionSegment, desc: aggressionDescLabel))
        mainStack.addArrangedSubview(createParamRow(title: "💋 成人风格", segment: adultStyleSegment, desc: adultStyleDescLabel))
    }
    
    private func createWhiteCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0).cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        return v
    }
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        return l
    }
    
    private func createParamRow(title: String, segment: UISegmentedControl, desc: UILabel) -> UIView {
        let card = createWhiteCard()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        let tl = UILabel()
        tl.text = title
        tl.font = .systemFont(ofSize: 17, weight: .semibold)
        
        stack.addArrangedSubview(tl)
        stack.addArrangedSubview(segment)
        stack.addArrangedSubview(desc)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    // MARK: - 数据处理
    
    private func loadData() {
        headerTitleLabel.text = slot.mainCategory.rawValue
        headerDescLabel.text = slot.mainCategory.description
        
        // 加载二级分类列表
        subCategoryContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for sub in slot.mainCategory.subCategories {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .top
            
            let icon = UILabel()
            icon.text = "🔹"
            icon.font = .systemFont(ofSize: 12)
            
            let vStack = UIStackView()
            vStack.axis = .vertical
            vStack.spacing = 2
            
            let nameL = UILabel()
            nameL.text = sub.rawValue
            nameL.font = .systemFont(ofSize: 16, weight: .semibold)
            nameL.textColor = .black
            
            let descL = UILabel()
            descL.text = sub.promptCore
            descL.font = .systemFont(ofSize: 13)
            descL.textColor = .systemGray
            descL.numberOfLines = 0
            
            vStack.addArrangedSubview(nameL)
            vStack.addArrangedSubview(descL)
            
            row.addArrangedSubview(icon)
            row.addArrangedSubview(vStack)
            
            subCategoryContainer.addArrangedSubview(row)
        }
        
        // 加载配置
        if let config = slot.configV2 {
            let wordCounts: [WordCount] = [.few, .medium, .many]
            wordCountSegment.selectedSegmentIndex = wordCounts.firstIndex(of: config.wordCount) ?? 1
            
            let levels: [AggressionLevel] = [.low, .medium, .high]
            aggressionSegment.selectedSegmentIndex = levels.firstIndex(of: config.aggressionLevel) ?? 1
            
            let adultStyles: [AdultStyle] = [.none, .light, .heavy]
            adultStyleSegment.selectedSegmentIndex = adultStyles.firstIndex(of: config.adultStyle) ?? 0
        }
    }
    
    @objc private func paramChanged() {
        // 更新文案或触发反馈（可选）
    }
    
    @objc private func saveTapped() {
        let wordCounts: [WordCount] = [.few, .medium, .many]
        let levels: [AggressionLevel] = [.low, .medium, .high]
        let adultStyles: [AdultStyle] = [.none, .light, .heavy]
        
        let newConfig = SlotConfigV2(
            wordCount: wordCounts[wordCountSegment.selectedSegmentIndex],
            aggressionLevel: levels[aggressionSegment.selectedSegmentIndex],
            adultStyle: adultStyles[adultStyleSegment.selectedSegmentIndex]
        )
        
        var updatedSlot = slot
        updatedSlot.configV2 = newConfig
        
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
        
        onSave(updatedSlot)
        navigationController?.popViewController(animated: true)
    }
}
