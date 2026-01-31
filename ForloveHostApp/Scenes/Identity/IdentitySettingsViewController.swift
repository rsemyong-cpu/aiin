import UIKit

// MARK: - 身份设置控制器
// 配置用户身份信息

class IdentitySettingsViewController: UIViewController {
    
    // MARK: - 属性
    
    private var identity: UserIdentity
    
    // MARK: - 子视图
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = DesignSystem.Colors.bgMain
        table.delegate = self
        table.dataSource = self
        table.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        table.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell")
        return table
    }()
    
    // MARK: - 初始化
    
    init() {
        self.identity = AppGroupStore.store.loadIdentity()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveIdentity()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        title = "身份设置"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "保存",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - 数据保存
    
    @objc private func saveTapped() {
        saveIdentity()
        navigationController?.popViewController(animated: true)
    }
    
    private func saveIdentity() {
        AppGroupStore.store.saveIdentity(identity)
    }
}

// MARK: - UITableViewDataSource

extension IdentitySettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1  // 称呼
        case 1: return 3  // 性别、交往目标、身份角色
        case 2: return 2  // 说话风格、语言偏好
        case 3: return 1  // 雷区
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "基本信息"
        case 1: return "身份角色"
        case 2: return "表达风格"
        case 3: return "雷区设置"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3: return "添加你不想被提及的话题，用逗号分隔"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.configure(title: "称呼", value: identity.displayName, placeholder: "希望别人怎么称呼你") { [weak self] value in
                self?.identity.displayName = value
            }
            return cell
            
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "性别", value: identity.gender.rawValue)
            return cell
            
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "交往目标", value: identity.relationshipGoal.rawValue)
            return cell
            
        case (1, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "身份角色", value: identity.personaDescription)
            return cell
            
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "说话风格", value: identity.speakingStyle.rawValue)
            return cell
            
        case (2, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "语言偏好", value: identity.language.rawValue)
            return cell
            
        case (3, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.configure(title: "雷区", value: identity.tabooList.joined(separator: ", "), placeholder: "如：不要太油, 不要提钱") { [weak self] value in
                self?.identity.tabooList = value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension IdentitySettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            showPicker(title: "性别", options: Gender.allCases.map { $0.rawValue }) { [weak self] selected in
                if let gender = Gender.allCases.first(where: { $0.rawValue == selected }) {
                    self?.identity.gender = gender
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (1, 1):
            showPicker(title: "交往目标", options: RelationshipGoal.allCases.map { $0.rawValue }) { [weak self] selected in
                if let goal = RelationshipGoal.allCases.first(where: { $0.rawValue == selected }) {
                    self?.identity.relationshipGoal = goal
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (1, 2):
            showPicker(title: "身份角色", options: PersonaPreset.allCases.map { $0.rawValue }) { [weak self] selected in
                if let persona = PersonaPreset.allCases.first(where: { $0.rawValue == selected }) {
                    self?.identity.persona = persona
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (2, 0):
            showPicker(title: "说话风格", options: SpeakingStyle.allCases.map { $0.rawValue }) { [weak self] selected in
                if let style = SpeakingStyle.allCases.first(where: { $0.rawValue == selected }) {
                    self?.identity.speakingStyle = style
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (2, 1):
            showPicker(title: "语言偏好", options: LanguagePreference.allCases.map { $0.rawValue }) { [weak self] selected in
                if let lang = LanguagePreference.allCases.first(where: { $0.rawValue == selected }) {
                    self?.identity.language = lang
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        default:
            break
        }
    }
    
    private func showPicker(title: String, options: [String], completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in
                completion(option)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - 文本输入单元格

class TextFieldCell: UITableViewCell {
    
    private var onValueChange: ((String) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.font = DesignSystem.Typography.bodyPrimary
        field.textColor = DesignSystem.Colors.textSecondary
        field.textAlignment = .right
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, value: String, placeholder: String, onChange: @escaping (String) -> Void) {
        titleLabel.text = title
        textField.text = value
        textField.placeholder = placeholder
        onValueChange = onChange
    }
    
    @objc private func textChanged() {
        onValueChange?(textField.text ?? "")
    }
}

// MARK: - 选择单元格

class SelectionCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, value: String) {
        textLabel?.text = title
        textLabel?.font = DesignSystem.Typography.bodyPrimary
        textLabel?.textColor = DesignSystem.Colors.textPrimary
        
        detailTextLabel?.text = value
        detailTextLabel?.font = DesignSystem.Typography.bodyPrimary
        detailTextLabel?.textColor = DesignSystem.Colors.goldPrimary
    }
}
