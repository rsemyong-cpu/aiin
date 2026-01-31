import UIKit

// MARK: - 权限服务
// 检查键盘启用状态和完全访问权限

public final class PermissionService {
    
    public init() {}
    
    // MARK: - 键盘状态检查
    
    /// 检查键盘状态
    public func checkKeyboardStatus() -> KeyboardStatus {
        let isEnabled = isKeyboardEnabled()
        let hasFullAccess = checkFullAccess()
        
        return KeyboardStatus(
            isKeyboardEnabled: isEnabled,
            hasFullAccess: hasFullAccess
        )
    }
    
    /// 检查键盘是否已启用
    /// 注意：iOS 无法直接检测，这里使用近似方法
    public func isKeyboardEnabled() -> Bool {
        // 方法1：检查 App Group 是否可以写入数据
        // 如果键盘扩展启用且有交互，应该有数据
        let store = AppGroupStore.store
        
        // 如果用户完成过权限引导，假设键盘已启用
        return store.isPermissionGuideCompleted()
    }
    
    /// 检查是否有完全访问权限
    public func checkFullAccess() -> Bool {
        // 在主 App 中检测完全访问的方法有限
        // 通常需要键盘扩展运行时检测
        // 这里使用 App Group 是否可访问作为近似判断
        return AppGroupStore.shared != nil
    }
    
    // MARK: - 打开系统设置
    
    /// 打开系统键盘设置
    public func openKeyboardSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
