import UIKit

// MARK: - 引导页控制器
// 首次启动时展示的引导流程

class OnboardingViewController: UIViewController {
    
    // MARK: - 子视图
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPage = 0
        control.currentPageIndicatorTintColor = DesignSystem.Colors.goldPrimary
        control.pageIndicatorTintColor = DesignSystem.Colors.goldDisabled
        return control
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("下一步", for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.bodyPrimary
        button.backgroundColor = DesignSystem.Colors.goldPrimary
        button.setTitleColor(DesignSystem.Colors.textOnGold, for: .normal)
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("跳过", for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.caption
        button.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 引导页数据
    
    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("💬", "帮你回", "一键生成高情商回复\n再也不用苦想怎么回"),
        ("👋", "帮开场", "万能开场白\n打破尴尬轻松开聊"),
        ("✨", "帮润色", "让你的话更得体\n情商 UP UP")
    ]
    
    private var currentPage: Int = 0
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI 设置
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.bgMain
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        setupConstraints()
        setupPages()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
            
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    private func setupPages() {
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(icon: page.icon, title: page.title, subtitle: page.subtitle)
            pageView.frame = CGRect(
                x: CGFloat(index) * view.bounds.width,
                y: 0,
                width: view.bounds.width,
                height: scrollView.bounds.height
            )
            scrollView.addSubview(pageView)
        }
        
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(pages.count),
            height: scrollView.bounds.height
        )
    }
    
    private func createPageView(icon: String, title: String, subtitle: String) -> UIView {
        let pageView = UIView()
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 80)
        iconLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        titleLabel.textColor = DesignSystem.Colors.textPrimary
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = DesignSystem.Typography.bodyPrimary
        subtitleLabel.textColor = DesignSystem.Colors.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        
        pageView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: pageView.centerYAnchor)
        ])
        
        return pageView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新页面位置
        for (index, subview) in scrollView.subviews.enumerated() {
            subview.frame = CGRect(
                x: CGFloat(index) * view.bounds.width,
                y: 0,
                width: view.bounds.width,
                height: scrollView.bounds.height
            )
        }
        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(pages.count),
            height: scrollView.bounds.height
        )
    }
    
    // MARK: - 事件处理
    
    @objc private func nextTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGFloat(currentPage) * view.bounds.width
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            pageControl.currentPage = currentPage
            updateButtonTitle()
        } else {
            goToPermissionGuide()
        }
    }
    
    @objc private func skipTapped() {
        goToPermissionGuide()
    }
    
    private func updateButtonTitle() {
        if currentPage == pages.count - 1 {
            nextButton.setTitle("开始设置", for: .normal)
        } else {
            nextButton.setTitle("下一步", for: .normal)
        }
    }
    
    private func goToPermissionGuide() {
        let permissionVC = PermissionGuideViewController()
        navigationController?.pushViewController(permissionVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        if page != currentPage && page >= 0 && page < pages.count {
            currentPage = page
            pageControl.currentPage = page
            updateButtonTitle()
        }
    }
}
