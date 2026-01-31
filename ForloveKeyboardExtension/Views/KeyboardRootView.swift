import UIKit

// MARK: - 键盘根视图 V4 (严格匹配参考图)
// 布局：顶部胶囊栏 -> 中间粘贴区卡片 -> 下方(左侧3x3九宫格 + 右侧垂直工具栏)

protocol KeyboardRootViewDelegate: AnyObject {
    func didTapInsert(text: String)
    func didTapCopy(text: String)
    func didTapPaste()
    func didTapClear()
    func didTapDelete()
    func didTapSend()
    func didTapHistory()
    func didTapSettings()
    func didTapRefresh(at index: Int)
    func didTapReplace(text: String)
    func didSwitchIntent(to intent: GenerationIntent)
    func didTapGenerate()
    func didTapNextKeyboard()
    func didToggleCandidateCount(to count: Int)
    func didReplaceWithAlternate()
    func didSelectSubCategory(at index: Int)
}

class KeyboardRootView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: KeyboardRootViewDelegate?
    private var state: KeyboardState
    
    // MARK: - 子视图
    
    private let topActionBar = TopActionBarView()
    
    /// 中间备选展示区卡片
    private lazy var alternateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 备选内容展示标签（显示备选2或3的前30字符）
    private lazy var alternateLabel: UILabel = {
        let label = UILabel()
        label.text = ""  // 默认空白
        label.textColor = .systemGray3
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("粘贴", for: .normal)
        button.backgroundColor = UIColor(red: 0.45, green: 0.42, blue: 0.95, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        return button
    }()
    
    /// 存储所有候选内容
    private var allCandidates: [Candidate] = []
    /// 当前展示的备选索引 (1 = 第2个, 2 = 第3个)
    private var currentAlternateDisplayIndex: Int = 1
    
    /// 下方布局容器
    private let bottomContainer = UIView()
    
    private lazy var subCategoryGridView: SubCategoryGridView = {
        let view = SubCategoryGridView()
        view.delegate = self
        return view
    }()
    
    /// 右侧垂直工具栏
    private lazy var sideToolStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "delete.left"), for: .normal)
        btn.backgroundColor = .white
        btn.tintColor = .black
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var clearBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("清空", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sendBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return btn
    }()
    
    private let toastLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        label.alpha = 0
        return label
    }()
    
    // MARK: - 初始化
    
    init(state: KeyboardState) {
        self.state = state
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        // 背景设为淡紫色
        backgroundColor = UIColor(red: 0.92, green: 0.91, blue: 1.0, alpha: 1.0)
        
        topActionBar.delegate = self
        
        addSubview(topActionBar)
        addSubview(alternateContainer)
        alternateContainer.addSubview(alternateLabel)
        alternateContainer.addSubview(pasteButton)
        
        addSubview(bottomContainer)
        bottomContainer.addSubview(subCategoryGridView)
        bottomContainer.addSubview(sideToolStack)
        
        sideToolStack.addArrangedSubview(deleteBtn)
        sideToolStack.addArrangedSubview(clearBtn)
        sideToolStack.addArrangedSubview(sendBtn)
        
        addSubview(toastLabel)
        
        topActionBar.reloadSlots()
        subCategoryGridView.loadFromSlot(state.currentSlot)
    }
    
    private func setupLayout() {
        [topActionBar, alternateContainer, alternateLabel, pasteButton, bottomContainer, subCategoryGridView, sideToolStack, toastLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // 顶部胶囊栏
            topActionBar.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            topActionBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topActionBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            topActionBar.heightAnchor.constraint(equalToConstant: 38),
            
            // 中间备选展示卡片
            alternateContainer.topAnchor.constraint(equalTo: topActionBar.bottomAnchor, constant: 6),
            alternateContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            alternateContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            alternateContainer.heightAnchor.constraint(equalToConstant: 52),
            
            alternateLabel.centerYAnchor.constraint(equalTo: alternateContainer.centerYAnchor),
            alternateLabel.leadingAnchor.constraint(equalTo: alternateContainer.leadingAnchor, constant: 16),
            alternateLabel.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -8),
            
            pasteButton.centerYAnchor.constraint(equalTo: alternateContainer.centerYAnchor),
            pasteButton.trailingAnchor.constraint(equalTo: alternateContainer.trailingAnchor, constant: -12),
            pasteButton.widthAnchor.constraint(equalToConstant: 64),
            pasteButton.heightAnchor.constraint(equalToConstant: 36),
            
            // 下方区域
            bottomContainer.topAnchor.constraint(equalTo: alternateContainer.bottomAnchor, constant: 10),
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            // 九宫格占左侧大部
            subCategoryGridView.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            subCategoryGridView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            subCategoryGridView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
            subCategoryGridView.trailingAnchor.constraint(equalTo: sideToolStack.leadingAnchor, constant: -12),
            
            // 工具栏占右侧
            sideToolStack.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            sideToolStack.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            sideToolStack.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
            sideToolStack.widthAnchor.constraint(equalToConstant: 68),
            
            // Toast
            toastLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            toastLabel.topAnchor.constraint(equalTo: alternateContainer.bottomAnchor, constant: 8),
            toastLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func pasteTapped() { delegate?.didTapPaste() }
    @objc private func deleteTapped() { delegate?.didTapDelete() }
    @objc private func clearTapped() { delegate?.didTapClear() }
    @objc private func sendTapped() { delegate?.didTapSend() }
    
    // MARK: - 公开更新方法
    
    /// 更新备选展示区内容（显示当前备选的前30字符）
    func updateAlternateDisplay() {
        guard allCandidates.count > currentAlternateDisplayIndex else {
            alternateLabel.text = "暂无备选"
            alternateLabel.textColor = .systemGray3
            return
        }
        
        let alternateText = allCandidates[currentAlternateDisplayIndex].text
        let displayText = String(alternateText.prefix(30))
        alternateLabel.text = alternateText.count > 30 ? displayText + "..." : displayText
        alternateLabel.textColor = .black
    }
    
    /// 切换备选展示（在第2个和第3个候选之间切换）
    func switchAlternateDisplay() {
        guard allCandidates.count >= 3 else {
            showToast("没有更多备选")
            return
        }
        
        currentAlternateDisplayIndex = (currentAlternateDisplayIndex == 1) ? 2 : 1
        updateAlternateDisplay()
        
        let text = (currentAlternateDisplayIndex == 1) ? "备选2" : "备选3"
        showToast("已切换到 \(text)")
    }
    
    /// 获取当前展示的备选内容
    func getCurrentAlternateText() -> String? {
        guard allCandidates.count > currentAlternateDisplayIndex else { return nil }
        return allCandidates[currentAlternateDisplayIndex].text
    }
    
    /// 接收候选结果并更新展示
    func updateCandidates(_ candidates: [Candidate]) {
        allCandidates = candidates
        currentAlternateDisplayIndex = 1  // 默认展示备选2
        
        // 更新备选展示区
        updateAlternateDisplay()
    }
    
    /// 清空备选展示
    func clearAlternates() {
        allCandidates = []
        currentAlternateDisplayIndex = 1
        alternateLabel.text = ""  // 清空为空白
        alternateLabel.textColor = .systemGray3
    }
    
    func showToast(_ message: String) {
        toastLabel.text = " \(message) "
        UIView.animate(withDuration: 0.2) { self.toastLabel.alpha = 1 }
        UIView.animate(withDuration: 0.2, delay: 1.5, options: [], animations: { self.toastLabel.alpha = 0 }, completion: nil)
    }
    
    func reloadSlots() {
        topActionBar.reloadSlots()
        subCategoryGridView.loadFromSlot(state.currentSlot)
    }
    
    func updateIntent(_ intent: GenerationIntent) {
        topActionBar.setSelectedIntent(intent)
    }
}

extension KeyboardRootView: TopActionBarViewDelegate {
    func didSelectSlot(at index: Int) {
        state.switchToSlot(index: index)
        subCategoryGridView.loadFromSlot(state.currentSlot)
        updateIntent(state.currentIntent)
    }
    func didSelectIntent(_ intent: GenerationIntent) {
        updateIntent(intent)
        delegate?.didSwitchIntent(to: intent)
    }
    func didTapToggleCandidateCount() {
        // 切换备选展示，直接调用 delegate
        delegate?.didToggleCandidateCount(to: 0)  // 参数不再使用，由rootView内部管理切换
    }
    func didTapReplaceWithAlternate() { delegate?.didReplaceWithAlternate() }
}

extension KeyboardRootView: SubCategoryGridViewDelegate {
    func didSelectSubCategory(at index: Int) { delegate?.didSelectSubCategory(at: index) }
    func didLongPressSubCategory(at index: Int) {
        delegate?.didSelectSubCategory(at: index)
        delegate?.didTapGenerate()
    }
}
