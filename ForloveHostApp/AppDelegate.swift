import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 检查是否首次启动
        let isFirstLaunch = AppGroupStore.store.isFirstLaunch()
        
        // 创建主窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if isFirstLaunch {
            // 首次启动显示引导页
            let onboardingVC = OnboardingViewController()
            window?.rootViewController = UINavigationController(rootViewController: onboardingVC)
        } else {
            // 正常启动显示首页
            let homeVC = HomeViewController()
            window?.rootViewController = UINavigationController(rootViewController: homeVC)
        }
        
        window?.makeKeyAndVisible()
        
        // 设置导航栏外观
        setupNavigationBarAppearance()
        
        return true
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = DesignSystem.Colors.bgMain
        appearance.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.titleSmall
        ]
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = DesignSystem.Colors.goldPrimary
    }
}
