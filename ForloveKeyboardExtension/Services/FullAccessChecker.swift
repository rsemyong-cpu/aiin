import UIKit

// MARK: - 完全访问检查器
// 检查键盘扩展是否有"允许完全访问"权限

public final class FullAccessChecker {
    
    public init() {}
    
    /// 检查是否有完全访问权限
    public var hasFullAccess: Bool {
        // iOS 检测完全访问权限的方式：
        // 只有拥有完全访问权限才能访问剪贴板和网络
        
        // 最可靠的方法：尝试访问剪贴板
        // 没有完全访问权限时，hasStrings 和 string 都会失败
        if UIPasteboard.general.hasStrings {
            return true
        }
        
        // 备用检查：检查 App Group 是否工作
        // 通过写入和读取来验证
        let testKey = "forlove.fullaccess.test"
        let testValue = UUID().uuidString
        AppGroupStore.shared.set(testValue, forKey: testKey)
        AppGroupStore.shared.synchronize()
        
        let readValue = AppGroupStore.shared.string(forKey: testKey)
        return readValue == testValue
    }
    
    /// 检查键盘是否已启用
    public var isKeyboardEnabled: Bool {
        // 这个检查需要在主 App 中进行
        // 键盘扩展中无法直接检测
        return true
    }
    
    /// 获取权限状态
    public func getPermissionState() -> PermissionState {
        if hasFullAccess {
            return .enabledFullAccess
        } else {
            return .enabledNoFullAccess
        }
    }
}
