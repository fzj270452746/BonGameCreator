import UIKit

enum LumosTheme {

    // MARK: - Palette
    enum Pigment {
        // Backgrounds — clean white to light gray
        static let obsidianBase    = UIColor(hex: "#F5F7FA")   // page background
        static let midnightSurface = UIColor(hex: "#FFFFFF")   // nav / tab bar
        static let cardSurface     = UIColor(hex: "#FFFFFF")   // card fill
        static let elevatedCard    = UIColor(hex: "#EEF1F6")   // stepper / badge bg
        static let borderGlow      = UIColor(hex: "#D8DDE8")   // subtle border

        // Accent palette — deep indigo + coral/amber
        static let auroraCyan      = UIColor(hex: "#3B6FE8")   // primary indigo blue
        static let auroraViolet    = UIColor(hex: "#7C5CDB")   // soft purple
        static let auroraMagenta   = UIColor(hex: "#F05F7A")   // coral pink
        static let auroraAmber     = UIColor(hex: "#F59E0B")   // warm amber
        static let auroraGreen     = UIColor(hex: "#10B981")   // teal green
        static let auroraOrange    = UIColor(hex: "#F97316")   // orange

        // Text — dark on light
        static let textPrimary     = UIColor(hex: "#111827")   // near-black
        static let textSecondary   = UIColor(hex: "#6B7280")   // medium gray
        static let textMuted       = UIColor(hex: "#9CA3AF")   // muted gray
    }

    // MARK: - Gradients
    enum Gradient {
        static let heroTop     = [UIColor(hex: "#3B6FE8"), UIColor(hex: "#7C5CDB")]
        static let cyanPurple  = [UIColor(hex: "#3B6FE8"), UIColor(hex: "#60A5FA")]
        static let amberOrange = [UIColor(hex: "#F59E0B"), UIColor(hex: "#F97316")]
        static let greenCyan   = [UIColor(hex: "#10B981"), UIColor(hex: "#3B6FE8")]
        static let pickCard    = [UIColor(hex: "#EEF2FF"), UIColor(hex: "#E0E7FF")]
        static let wheelSeg: [UIColor] = [
            UIColor(hex: "#3B6FE8"), UIColor(hex: "#F05F7A"),
            UIColor(hex: "#7C5CDB"), UIColor(hex: "#10B981"),
            UIColor(hex: "#F59E0B"), UIColor(hex: "#F97316"),
            UIColor(hex: "#60A5FA"), UIColor(hex: "#34D399")
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
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 12
        static let lg: CGFloat   = 16
        static let xl: CGFloat   = 20
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

// MARK: - UIView helpers
extension UIView {
    func applyLumosGlow(color: UIColor = LumosTheme.Pigment.auroraCyan, radius: CGFloat = 8, opacity: Float = 0.18) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    func applyGradientBackground(colors: [UIColor], cornerRadius: CGFloat = 0) {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad = CAGradientLayer.lumosGradient(colors: colors)
        grad.frame = bounds
        grad.cornerRadius = cornerRadius
        layer.insertSublayer(grad, at: 0)
    }
}
