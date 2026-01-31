import UIKit

// MARK: - 轻黑金设计系统
// 严格遵循「轻黑金视觉规范 v1.0」

public enum DesignSystem {
    
    // MARK: - 1. 色彩系统 (Color Tokens)
    
    public enum Colors {
        
        // MARK: 1.1 主色 (Primary - Gold)
        
        /// 主金色（偏暖、低饱和）#C8A46A
        public static let goldPrimary = UIColor(hex: "#C8A46A")
        
        /// 高光金（仅用于强调）#E6CFA3
        public static let goldHighlight = UIColor(hex: "#E6CFA3")
        
        /// 禁用/弱金 #EADFCB
        public static let goldDisabled = UIColor(hex: "#EADFCB")
        
        /// 选中态浅金背景 #FFF8EC
        public static let goldSelectedBg = UIColor(hex: "#FFF8EC")
        
        // MARK: 1.2 背景色 (Background)
        
        /// 输入法整体背景（暖灰白）#F7F6F4
        public static let bgMain = UIColor(hex: "#F7F6F4")
        
        /// 卡片背景 #FFFFFF
        public static let bgCard = UIColor.white
        
        /// 次级背景（对照区/原话区）#F1EFEA
        public static let bgSubtle = UIColor(hex: "#F1EFEA")
        
        // MARK: 1.3 文字色 (Text)
        
        /// 主文字 #1F1F1F
        public static let textPrimary = UIColor(hex: "#1F1F1F")
        
        /// 次要说明 #6F6F6F
        public static let textSecondary = UIColor(hex: "#6F6F6F")
        
        /// 禁用/提示 #B5B5B5
        public static let textDisabled = UIColor(hex: "#B5B5B5")
        
        /// 金色按钮上的文字 #FFFFFF
        public static let textOnGold = UIColor.white
        
        // MARK: 1.4 分割 & 描边
        
        /// 卡片描边 #E7E3DA
        public static let borderLight = UIColor(hex: "#E7E3DA")
        
        /// 分割线 (同 borderLight)
        public static let divider = UIColor(hex: "#E7E3DA")
        
        /// 选中态描边（慎用）#D6C19A
        public static let borderGold = UIColor(hex: "#D6C19A")
        
        /// 次金色（用于辅助强调）
        public static let goldSecondary = UIColor(hex: "#D6C19A")
    }
    
    // MARK: - 2. 字体系统 (Typography)
    
    public enum Typography {
        
        /// 模块标题（少用）16pt Semibold
        public static let titleSmall = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        /// 候选内容 14pt Regular
        public static let bodyPrimary = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        /// 辅助说明 13pt Regular
        public static let bodySecondary = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        /// 标签/提示 12pt Regular
        public static let caption = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // 行高配置
        public static let bodyPrimaryLineHeight: CGFloat = 20    // 14pt → 20pt
        public static let bodySecondaryLineHeight: CGFloat = 18  // 13pt → 18pt
        public static let captionLineHeight: CGFloat = 16        // 12pt → 16pt
    }
    
    // MARK: - 3. 圆角 & 阴影 (Radius & Shadow)
    
    public enum Radius {
        /// 卡片圆角
        public static let card: CGFloat = 16
        
        /// 胶囊按钮
        public static let button: CGFloat = 999
        
        /// Chip 标签
        public static let chip: CGFloat = 14
        
        /// 弹出层
        public static let popover: CGFloat = 18
    }
    
    public enum Shadow {
        /// 卡片阴影
        public static func applyCard(to layer: CALayer) {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.06
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 8
        }
    }
    
    // MARK: - 4. 间距系统
    
    public enum Spacing {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }
    
    // MARK: - 5. 组件规格
    
    public enum Components {
        
        // Scene Tabs (场景标签)
        public static let chipHeight: CGFloat = 30
        public static let chipPaddingH: CGFloat = 12
        public static let chipPaddingV: CGFloat = 8
        
        // Candidate Card (候选卡片)
        public static let cardPadding: CGFloat = 14
        public static let cardMinHeight: CGFloat = 60
        public static let cardMaxLines: Int = 3
        
        // Top Action Bar (顶部胶囊栏)
        public static let actionBarHeight: CGFloat = 40
        public static let actionButtonHeight: CGFloat = 32
        
        // Quick Tools Row (工具行)
        public static let toolsRowHeight: CGFloat = 36
        
        // Candidate List (候选列表)
        public static let candidateListHeight: CGFloat = 110
        public static let candidateListPaddingH: CGFloat = 16
    }
    
    // MARK: - 6. 动效
    
    public enum Animation {
        /// 模式切换淡入淡出
        public static let modeSwitchDuration: TimeInterval = 0.15
        
        /// 标准动画曲线
        public static let easeOut = UIView.AnimationOptions.curveEaseOut
    }
}

// MARK: - UIColor Hex 扩展

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}
