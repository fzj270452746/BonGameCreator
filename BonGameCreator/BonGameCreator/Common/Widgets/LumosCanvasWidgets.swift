import UIKit

// MARK: - Padded TextField
final class PaddedTextField: UITextField {
    var insets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
}

// MARK: - Toast
final class LumosToast {
    static func show(message: String, in view: UIView, duration: TimeInterval = 2.0) {
        let toast = UILabel()
        toast.text = message
        toast.font = LumosTheme.Typeface.subhead(14)
        toast.textColor = LumosTheme.Pigment.textPrimary
        toast.backgroundColor = LumosTheme.Pigment.elevatedCard
        toast.textAlignment = .center
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.alpha = 0

        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toast.heightAnchor.constraint(equalToConstant: 40),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])

        UIView.animate(withDuration: 0.3) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: { toast.alpha = 0 }) { _ in toast.removeFromSuperview() }
        }
    }
}

// MARK: - Spin Wheel Canvas (Try Play)
final class SpinWheelCanvas: UIView {

    private var config = CrystalWheelConfig()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(config: CrystalWheelConfig) {
        self.config = config
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 6
        let total = config.totalWeight
        guard total > 0 else { return }

        var startAngle: CGFloat = -.pi / 2
        for seg in config.segments {
            let sweep = CGFloat(seg.weightFraction / total) * 2 * .pi
            let endAngle = startAngle + sweep
            ctx.setFillColor(UIColor(hex: seg.hexColor).cgColor)
            ctx.move(to: center)
            ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx.closePath()
            ctx.fillPath()
            ctx.setStrokeColor(LumosTheme.Pigment.obsidianBase.cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: center)
            ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx.closePath()
            ctx.strokePath()

            let midAngle = startAngle + sweep / 2
            let labelR = radius * 0.65
            let lx = center.x + labelR * cos(midAngle)
            let ly = center.y + labelR * sin(midAngle)
            let text = "\(String(format: "%.0f", seg.rewardMultiplier))×"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: LumosTheme.Typeface.headline(11),
                .foregroundColor: UIColor.white
            ]
            let sz = (text as NSString).size(withAttributes: attrs)
            (text as NSString).draw(at: CGPoint(x: lx - sz.width/2, y: ly - sz.height/2), withAttributes: attrs)
            startAngle = endAngle
        }

        // Outer ring
        ctx.setStrokeColor(LumosTheme.Pigment.auroraCyan.cgColor)
        ctx.setLineWidth(3)
        ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Center
        ctx.setFillColor(LumosTheme.Pigment.obsidianBase.cgColor)
        ctx.addArc(center: center, radius: 16, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.fillPath()
        ctx.setStrokeColor(LumosTheme.Pigment.auroraAmber.cgColor)
        ctx.setLineWidth(2.5)
        ctx.addArc(center: center, radius: 16, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()
    }
}

// MARK: - Histogram Chart
final class NexusHistogramView: UIView {

    private let buckets: [HistoBucket]

    init(buckets: [HistoBucket]) {
        self.buckets = buckets
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard !buckets.isEmpty, let ctx = UIGraphicsGetCurrentContext() else { return }
        let maxProp = buckets.map { $0.proportion }.max() ?? 1
        let barW = (rect.width - CGFloat(buckets.count - 1) * 4) / CGFloat(buckets.count)
        let colors = LumosTheme.Gradient.wheelSeg

        for (i, bucket) in buckets.enumerated() {
            let barH = CGFloat(bucket.proportion / maxProp) * (rect.height - 24)
            let x = CGFloat(i) * (barW + 4)
            let y = rect.height - barH - 20

            let barRect = CGRect(x: x, y: y, width: barW, height: barH)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            ctx.setFillColor(colors[i % colors.count].withAlphaComponent(0.85).cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

            // Label
            let pct = String(format: "%.0f%%", bucket.proportion * 100)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: LumosTheme.Typeface.body(8),
                .foregroundColor: LumosTheme.Pigment.textMuted
            ]
            let sz = (pct as NSString).size(withAttributes: attrs)
            (pct as NSString).draw(at: CGPoint(x: x + barW/2 - sz.width/2, y: rect.height - 16), withAttributes: attrs)
        }
    }
}

// MARK: - Reel Animation View
final class ReelAnimationView: UIView {

    private let symbols = ["⭐", "💎", "🎰", "🔥", "⚡", "🎯", "💫", "🃏"]
    private var displayLabels: [UILabel] = []
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = LumosTheme.Pigment.cardSurface
        layer.cornerRadius = LumosTheme.Radius.md
        layer.borderWidth = 1
        layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
        setupReels()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupReels() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        for _ in 0..<5 {
            let lbl = UILabel()
            lbl.text = symbols.randomElement()
            lbl.font = UIFont.systemFont(ofSize: 32)
            lbl.textAlignment = .center
            stack.addArrangedSubview(lbl)
            displayLabels.append(lbl)
        }
    }

    func startSpinning() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            for lbl in self.displayLabels {
                lbl.text = self.symbols.randomElement()
            }
        }
    }

    func playAnimation() {
        for lbl in displayLabels {
            UIView.transition(with: lbl, duration: 0.15, options: .transitionFlipFromTop) {
                lbl.text = self.symbols.randomElement()
            }
        }
    }

    func stopSpinning(result: Double) {
        timer?.invalidate()
        timer = nil
        for lbl in displayLabels { lbl.text = result >= 5 ? "⭐" : "🎰" }
    }

    deinit { timer?.invalidate() }
}

// MARK: - Empty State
final class VaultEmptyStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let icon = UIImageView(image: UIImage(systemName: "tray"))
        icon.tintColor = LumosTheme.Pigment.textMuted
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let lbl = UILabel()
        lbl.text = "No saved blueprints yet.\nCreate one in the editor!"
        lbl.font = LumosTheme.Typeface.body(15)
        lbl.textColor = LumosTheme.Pigment.textMuted
        lbl.textAlignment = .center
        lbl.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, lbl])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// MARK: - Fun Score Gauge
final class FunScoreGaugeView: UIView {

    private let score: Double

    init(score: Double) {
        self.score = score
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        let trackPath = UIBezierPath()
        trackPath.move(to: CGPoint(x: 16, y: rect.midY))
        trackPath.addLine(to: CGPoint(x: rect.width - 100, y: rect.midY))
        LumosTheme.Pigment.borderGlow.setStroke()
        trackPath.lineWidth = 8
        trackPath.lineCapStyle = .round
        trackPath.stroke()

        let fillW = max(0, min(1, score / 100)) * (rect.width - 116)
        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: 16, y: rect.midY))
        fillPath.addLine(to: CGPoint(x: 16 + fillW, y: rect.midY))

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        let gradColors = [LumosTheme.Pigment.auroraMagenta.cgColor, LumosTheme.Pigment.auroraAmber.cgColor]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradColors as CFArray, locations: nil)!
        ctx?.addPath(fillPath.cgPath)
        ctx?.setLineWidth(8)
        ctx?.setLineCap(.round)
        ctx?.replacePathWithStrokedPath()
        ctx?.clip()
        ctx?.drawLinearGradient(grad, start: CGPoint(x: 16, y: rect.midY), end: CGPoint(x: 16 + fillW, y: rect.midY), options: [])
        ctx?.restoreGState()

        let scoreLbl = String(format: "%.1f", score)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: LumosTheme.Typeface.headline(22),
            .foregroundColor: LumosTheme.Pigment.auroraMagenta
        ]
        NSAttributedString(string: scoreLbl, attributes: attrs).draw(at: CGPoint(x: rect.width - 90, y: rect.midY - 14))

        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: LumosTheme.Typeface.body(11),
            .foregroundColor: LumosTheme.Pigment.textMuted
        ]
        NSAttributedString(string: "Fun Score", attributes: subAttrs).draw(at: CGPoint(x: rect.width - 90, y: rect.midY + 10))
    }
}
