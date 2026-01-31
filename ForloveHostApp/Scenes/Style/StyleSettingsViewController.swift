import UIKit

// MARK: - 风格设置控制器
// 配置生成内容的风格偏好

class StyleSettingsViewController: UIViewController {
    
    // MARK: - 属性
    
    private var style: StyleProfile
    
    // MARK: - 子视图
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = DesignSystem.Colors.bgMain
        table.delegate = self
        table.dataSource = self
        table.register(SliderCell.self, forCellReuseIdentifier: "SliderCell")
        table.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell")
        return table
    }()
    
    // MARK: - 初始化
    
    init() {
        self.style = AppGroupStore.store.loadStyle()
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
        saveStyle()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        title = "风格偏好"
        
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
        saveStyle()
        navigationController?.popViewController(animated: true)
    }
    
    private func saveStyle() {
        AppGroupStore.store.saveStyle(style)
    }
}

// MARK: - UITableViewDataSource

extension StyleSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3  // 表情密度、字数偏好、风险等级
        case 1: return 2  // 暧昧等级、候选数量
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "内容风格"
        case 1: return "生成设置"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "表情密度", value: style.emojiLevel.displayName)
            return cell
            
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "字数偏好", value: style.lengthPreference.rawValue)
            return cell
            
        case (0, 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.configure(title: "风险等级", value: style.riskLevel.rawValue)
            return cell
            
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            cell.configure(
                title: "默认暧昧等级",
                value: Float(style.defaultFlirtLevel),
                minValue: 1,
                maxValue: 5,
                displayFormatter: { "\(Int($0))/5" }
            ) { [weak self] value in
                self?.style.defaultFlirtLevel = Int(value)
            }
            return cell
            
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            cell.configure(
                title: "候选数量",
                value: Float(style.candidateCount),
                minValue: 1,
                maxValue: 5,
                displayFormatter: { "\(Int($0)) 条" }
            ) { [weak self] value in
                self?.style.candidateCount = Int(value)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension StyleSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showPicker(title: "表情密度", options: EmojiLevel.allCases.map { $0.displayName }) { [weak self] selected in
                if let level = EmojiLevel.allCases.first(where: { $0.displayName == selected }) {
                    self?.style.emojiLevel = level
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (0, 1):
            showPicker(title: "字数偏好", options: LengthPreference.allCases.map { $0.rawValue }) { [weak self] selected in
                if let pref = LengthPreference.allCases.first(where: { $0.rawValue == selected }) {
                    self?.style.lengthPreference = pref
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case (0, 2):
            showPicker(title: "风险等级", options: RiskLevel.allCases.map { $0.rawValue }) { [weak self] selected in
                if let level = RiskLevel.allCases.first(where: { $0.rawValue == selected }) {
                    self?.style.riskLevel = level
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 70
        }
        return 44
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

// MARK: - 滑块单元格

class SliderCell: UITableViewCell {
    
    private var onValueChange: ((Float) -> Void)?
    private var displayFormatter: ((Float) -> String)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.textPrimary
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodyPrimary
        label.textColor = DesignSystem.Colors.goldPrimary
        label.textAlignment = .right
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = DesignSystem.Colors.goldPrimary
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
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
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .fill
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, slider])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, value: Float, minValue: Float, maxValue: Float, displayFormatter: @escaping (Float) -> String, onChange: @escaping (Float) -> Void) {
        titleLabel.text = title
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = value
        self.displayFormatter = displayFormatter
        self.onValueChange = onChange
        updateValueLabel()
    }
    
    @objc private func sliderChanged() {
        let roundedValue = round(slider.value)
        slider.value = roundedValue
        updateValueLabel()
        onValueChange?(roundedValue)
    }
    
    private func updateValueLabel() {
        valueLabel.text = displayFormatter?(slider.value) ?? "\(Int(slider.value))"
    }
}
