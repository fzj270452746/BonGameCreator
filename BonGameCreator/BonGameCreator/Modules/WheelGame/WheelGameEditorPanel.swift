import UIKit

final class WheelGameEditorPanel: UIView {

    private(set) var currentConfig = CrystalWheelConfig()

    private let previewCanvas  = WheelPreviewCanvas()
    private let segmentsStack  = UIStackView()
    private let scrollView     = UIScrollView()
    private let addSegBtn      = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrbit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupOrbit() }

    private func setupOrbit() {
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = LumosTheme.Spacing.sm
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let header = LumosSectionHeader(title: "Wheel Config", accentColor: LumosTheme.Pigment.auroraViolet)
        outerStack.addArrangedSubview(header)

        previewCanvas.translatesAutoresizingMaskIntoConstraints = false
        previewCanvas.heightAnchor.constraint(equalToConstant: 200).isActive = true
        outerStack.addArrangedSubview(previewCanvas)

        let segHeader = LumosSectionHeader(title: "Segments", accentColor: LumosTheme.Pigment.auroraAmber)
        outerStack.addArrangedSubview(segHeader)

        segmentsStack.axis = .vertical
        segmentsStack.spacing = LumosTheme.Spacing.xs
        outerStack.addArrangedSubview(segmentsStack)

        addSegBtn.setTitle("+ Add Segment", for: .normal)
        addSegBtn.titleLabel?.font = LumosTheme.Typeface.subhead(13)
        addSegBtn.setTitleColor(LumosTheme.Pigment.auroraGreen, for: .normal)
        addSegBtn.addTarget(self, action: #selector(tapAddSegment), for: .touchUpInside)
        outerStack.addArrangedSubview(addSegBtn)

        rebuildSegmentRows()
        refreshPreview()
    }

    private func rebuildSegmentRows() {
        segmentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, seg) in currentConfig.segments.enumerated() {
            segmentsStack.addArrangedSubview(buildSegRow(index: i, seg: seg))
        }
    }

    private func buildSegRow(index: Int, seg: PrismWheelSegment) -> UIView {
        let container = UIView()
        container.backgroundColor = LumosTheme.Pigment.elevatedCard
        container.layer.cornerRadius = LumosTheme.Radius.sm

        let colorDot = UIView()
        colorDot.backgroundColor = UIColor(hex: seg.hexColor)
        colorDot.layer.cornerRadius = 8
        colorDot.translatesAutoresizingMaskIntoConstraints = false
        colorDot.widthAnchor.constraint(equalToConstant: 16).isActive = true
        colorDot.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let rewardField = PaddedTextField()
        rewardField.placeholder = "Reward"
        rewardField.text = String(format: "%.1f", seg.rewardMultiplier)
        rewardField.font = LumosTheme.Typeface.mono(14)
        rewardField.textColor = LumosTheme.Pigment.auroraAmber
        rewardField.backgroundColor = LumosTheme.Pigment.cardSurface
        rewardField.layer.cornerRadius = 6
        rewardField.keyboardType = .decimalPad
        rewardField.tag = index * 100

        let weightField = PaddedTextField()
        weightField.placeholder = "Weight"
        weightField.text = String(format: "%.0f", seg.weightFraction)
        weightField.font = LumosTheme.Typeface.mono(14)
        weightField.textColor = LumosTheme.Pigment.auroraCyan
        weightField.backgroundColor = LumosTheme.Pigment.cardSurface
        weightField.layer.cornerRadius = 6
        weightField.keyboardType = .decimalPad
        weightField.tag = index * 100 + 1

        for f in [rewardField, weightField] {
            f.addTarget(self, action: #selector(segFieldChanged(_:)), for: .editingChanged)
        }

        let xBtn = UIButton(type: .system)
        xBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        xBtn.tintColor = LumosTheme.Pigment.auroraMagenta
        xBtn.tag = index
        xBtn.addTarget(self, action: #selector(tapRemoveSeg(_:)), for: .touchUpInside)

        let rewardLbl = UILabel()
        rewardLbl.text = "×"
        rewardLbl.font = LumosTheme.Typeface.body(12)
        rewardLbl.textColor = LumosTheme.Pigment.textMuted

        let weightLbl = UILabel()
        weightLbl.text = "wt"
        weightLbl.font = LumosTheme.Typeface.body(12)
        weightLbl.textColor = LumosTheme.Pigment.textMuted

        let stack = UIStackView(arrangedSubviews: [colorDot, rewardField, rewardLbl, weightField, weightLbl, UIView(), xBtn])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            rewardField.widthAnchor.constraint(equalToConstant: 60),
            rewardField.heightAnchor.constraint(equalToConstant: 30),
            weightField.widthAnchor.constraint(equalToConstant: 55),
            weightField.heightAnchor.constraint(equalToConstant: 30),
            xBtn.widthAnchor.constraint(equalToConstant: 26),
            xBtn.heightAnchor.constraint(equalToConstant: 26)
        ])
        return container
    }

    @objc private func segFieldChanged(_ field: UITextField) {
        let idx = field.tag / 100
        let isWeight = (field.tag % 100) == 1
        guard idx < currentConfig.segments.count,
              let text = field.text, let val = Double(text) else { return }
        var seg = currentConfig.segments[idx]
        if isWeight { seg.weightFraction = val } else { seg.rewardMultiplier = val }
        currentConfig.segments[idx] = seg
        refreshPreview()
    }

    @objc private func tapAddSegment() {
        let colors = LumosTheme.Gradient.wheelSeg
        let newSeg = PrismWheelSegment(
            rewardMultiplier: 5,
            weightFraction: 10,
            hexColor: colors[currentConfig.segments.count % colors.count].hexString
        )
        currentConfig.segments.append(newSeg)
        rebuildSegmentRows()
        refreshPreview()
    }

    @objc private func tapRemoveSeg(_ sender: UIButton) {
        guard currentConfig.segments.count > 2 else { return }
        currentConfig.segments.remove(at: sender.tag)
        rebuildSegmentRows()
        refreshPreview()
    }

    private func refreshPreview() {
        previewCanvas.configure(segments: currentConfig.segments)
    }

    func applyConfig(_ cfg: CrystalWheelConfig) {
        currentConfig = cfg
        rebuildSegmentRows()
        refreshPreview()
    }
}

// MARK: - Wheel Preview Canvas
final class WheelPreviewCanvas: UIView {

    private var segments: [PrismWheelSegment] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(segments: [PrismWheelSegment]) {
        self.segments = segments
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 8
        let total = segments.reduce(0.0) { $0 + $1.weightFraction }
        guard total > 0 else { return }

        var startAngle: CGFloat = -.pi / 2
        for seg in segments {
            let sweep = CGFloat(seg.weightFraction / total) * .pi * 2
            let endAngle = startAngle + sweep

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            UIColor(hex: seg.hexColor).withAlphaComponent(0.85).setFill()
            path.fill()

            // Border
            UIColor(hex: "#0D0D1A").setStroke()
            path.lineWidth = 1.5
            path.stroke()

            // Label
            let midAngle = startAngle + sweep / 2
            let labelR = radius * 0.65
            let lx = center.x + labelR * cos(midAngle)
            let ly = center.y + labelR * sin(midAngle)
            let label = String(format: "%.0fx", seg.rewardMultiplier)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: LumosTheme.Typeface.headline(10),
                .foregroundColor: UIColor.white
            ]
            let size = label.size(withAttributes: attrs)
            label.draw(at: CGPoint(x: lx - size.width/2, y: ly - size.height/2), withAttributes: attrs)

            startAngle = endAngle
        }

        // Center circle
        let centerPath = UIBezierPath(arcCenter: center, radius: 18, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        LumosTheme.Pigment.obsidianBase.setFill()
        centerPath.fill()
        LumosTheme.Pigment.borderGlow.setStroke()
        centerPath.lineWidth = 2
        centerPath.stroke()
    }
}

// MARK: - UIColor hex string
extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}
