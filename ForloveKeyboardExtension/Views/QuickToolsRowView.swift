import UIKit

// MARK: - 工具行视图
// 快捷工具按钮：粘贴对方消息 / 删除 / 发送 / 切换键盘

protocol QuickToolsRowViewDelegate: AnyObject {
    func didTapPaste()
    func didTapClear()
    func didTapDelete()
    func didTapSend()
    func didTapHistory()
    func didTapSettings()
    func didTapNextKeyboard()
}

class QuickToolsRowView: UIView {
    
    // MARK: - 属性
    
    weak var delegate: QuickToolsRowViewDelegate?
    
    // MARK: - 子视图
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var nextKeyboardButton: ToolButton = {
        let button = ToolButton(icon: "🌐", title: nil)
        button.addTarget(self, action: #selector(nextKeyboardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pasteButton: ToolButton = {
        let button = ToolButton(icon: "📋", title: "粘贴对方消息")
        button.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: ToolButton = {
        let button = ToolButton(icon: "⌫", title: "删除")
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: ToolButton = {
        let button = ToolButton(icon: "📤", title: "发送")
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: ToolButton = {
        let button = ToolButton(icon: "🧹", title: "清空")
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: ToolButton = {
        let button = ToolButton(icon: "⋯", title: nil)
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
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
        addSubview(stackView)
        
        stackView.addArrangedSubview(nextKeyboardButton)
        stackView.addArrangedSubview(pasteButton)
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(clearButton)
        stackView.addArrangedSubview(settingsButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - 事件处理
    
    @objc private func nextKeyboardTapped() {
        delegate?.didTapNextKeyboard()
    }
    
    @objc private func pasteTapped() {
        delegate?.didTapPaste()
    }
    
    @objc private func deleteTapped() {
        delegate?.didTapDelete()
    }
    
    @objc private func sendTapped() {
        delegate?.didTapSend()
    }
    
    @objc private func clearTapped() {
        delegate?.didTapClear()
    }
    
    @objc private func settingsTapped() {
        delegate?.didTapSettings()
    }
}

// MARK: - 工具按钮

class ToolButton: UIButton {
    
    init(icon: String, title: String?) {
        super.init(frame: .zero)
        
        if let title = title {
            setTitle("\(icon) \(title)", for: .normal)
        } else {
            setTitle(icon, for: .normal)
        }
        
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        titleLabel?.font = DesignSystem.Typography.caption
        setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
        setTitleColor(DesignSystem.Colors.goldPrimary, for: .highlighted)
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}
