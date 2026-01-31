import UIKit

// MARK: - 剪贴板服务
// 处理剪贴板读取（需用户主动触发）

public final class ClipboardService {
    
    public static let shared = ClipboardService()
    
    private init() {}
    
    // MARK: - 剪贴板读取
    
    /// 读取剪贴板内容（仅在用户主动触发时调用）
    public func readContent() -> String? {
        return UIPasteboard.general.string
    }
    
    /// 检查剪贴板是否有内容
    public func hasContent() -> Bool {
        return UIPasteboard.general.hasStrings
    }
    
    /// 写入剪贴板
    public func write(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    /// 清空剪贴板
    public func clear() {
        UIPasteboard.general.string = ""
    }
}
