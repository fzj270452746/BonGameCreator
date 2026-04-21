import UIKit

enum LumosTheme {

    // MARK: - Palette
    enum Pigment {
        static let obsidianBase    = UIColor(hex: "#0D0D1A")
        static let midnightSurface = UIColor(hex: "#14142B")
        static let cardSurface     = UIColor(hex: "#1E1E3A")
        static let elevatedCard    = UIColor(hex: "#252545")
        static let borderGlow      = UIColor(hex: "#3A3A6A")

        static let auroraCyan      = UIColor(hex: "#00F5FF")
        static let auroraViolet    = UIColor(hex: "#9B5DE5")
        static let auroraMagenta   = UIColor(hex: "#F72585")
        static let auroraAmber     = UIColor(hex: "#FFB703")
        static let auroraGreen     = UIColor(hex: "#06D6A0")
        static let auroraOrange    = UIColor(hex: "#FF6B35")

        static let textPrimary     = UIColor(hex: "#F0F0FF")
        static let textSecondary   = UIColor(hex: "#9090BB")
        static let textMuted       = UIColor(hex: "#5A5A8A")
    }

    // MARK: - Gradients
    enum Gradient {
        static let heroTop    = [UIColor(hex: "#9B5DE5"), UIColor(hex: "#F72585")]
        static let cyanPurple = [UIColor(hex: "#00F5FF"), UIColor(hex: "#9B5DE5")]
        static let amberOrange = [UIColor(hex: "#FFB703"), UIColor(hex: "#FF6B35")]
        static let greenCyan  = [UIColor(hex: "#06D6A0"), UIColor(hex: "#00F5FF")]
        static let pickCard   = [UIColor(hex: "#1E1E3A"), UIColor(hex: "#252560")]
        static let wheelSeg: [UIColor] = [
            UIColor(hex: "#FF6B35"), UIColor(hex: "#F72585"),
            UIColor(hex: "#9B5DE5"), UIColor(hex: "#00F5FF"),
            UIColor(hex: "#06D6A0"), UIColor(hex: "#FFB703"),
            UIColor(hex: "#E84855"), UIColor(hex: "#4CC9F0")
        ]
    }

    // MARK: - Typography
    enum Typeface {
        static func headline(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .bold)
        }
        static func subhead(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        static func body(_ size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
        static func mono(_ size: CGFloat) -> UIFont {
            UIFont.monospacedDigitSystemFont(ofSize: size, weight: .medium)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 12
        static let lg: CGFloat  = 16
        static let xl: CGFloat  = 20
        static let pill: CGFloat = 20
    }
}

// MARK: - UIColor hex init
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8)  & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF)          / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - Gradient Layer Helper
extension CAGradientLayer {
    static func lumosGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0),
                               endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors.map { $0.cgColor }
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        return layer
    }
}

// MARK: - UIView Glow
extension UIView {
    func applyLumosGlow(color: UIColor = LumosTheme.Pigment.auroraCyan, radius: CGFloat = 8, opacity: Float = 0.6) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
    }

    func applyGradientBackground(colors: [UIColor], cornerRadius: CGFloat = 0) {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad = CAGradientLayer.lumosGradient(colors: colors)
        grad.frame = bounds
        grad.cornerRadius = cornerRadius
        layer.insertSublayer(grad, at: 0)
    }
}
