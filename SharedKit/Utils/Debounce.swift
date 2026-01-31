import Foundation

// MARK: - 防抖工具
// 用于防止快速连续触发操作

public final class Debouncer {
    
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    
    public init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    /// 执行防抖操作
    public func debounce(_ action: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: action)
        workItem = item
        queue.asyncAfter(deadline: .now() + delay, execute: item)
    }
    
    /// 取消等待中的操作
    public func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - 节流工具
public final class Throttler {
    
    private let interval: TimeInterval
    private var lastExecutionTime: Date?
    private let queue: DispatchQueue
    
    public init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    
    /// 执行节流操作
    public func throttle(_ action: @escaping () -> Void) {
        let now = Date()
        
        if let lastTime = lastExecutionTime,
           now.timeIntervalSince(lastTime) < interval {
            return
        }
        
        lastExecutionTime = now
        queue.async(execute: action)
    }
    
    /// 重置节流状态
    public func reset() {
        lastExecutionTime = nil
    }
}
