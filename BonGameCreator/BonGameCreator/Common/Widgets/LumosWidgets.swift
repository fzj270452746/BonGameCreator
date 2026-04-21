import UIKit

// MARK: - Gradient Button
final class NebulaCTAButton: UIButton {

    private let gradLayer = CAGradientLayer()
    private var gradColors: [UIColor] = LumosTheme.Gradient.heroTop

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrbit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupOrbit() }

    private func setupOrbit() {
        gradLayer.colors = gradColors.map { $0.cgColor }
        gradLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradLayer, at: 0)
        clipsToBounds = false
        titleLabel?.font = LumosTheme.Typeface.headline(16)
        setTitleColor(LumosTheme.Pigment.textPrimary, for: .normal)
        applyLumosGlow(color: gradColors.first ?? .purple, radius: 6, opacity: 0.28)
        addTarget(self, action: #selector(pressBegan), for: .touchDown)
        addTarget(self, action: #selector(pressEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    func configureGradient(colors: [UIColor]) {
        gradColors = colors
        gradLayer.colors = colors.map { $0.cgColor }
        applyLumosGlow(color: colors.first ?? .purple, radius: 6, opacity: 0.28)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = bounds
        let orbitRadius = min(bounds.height * 0.22, 12)
        gradLayer.cornerRadius = orbitRadius
        layer.cornerRadius = orbitRadius
    }

    @objc private func pressBegan() {
        UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }
    @objc private func pressEnded() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6) {
            self.transform = .identity
        }
    }
}

// MARK: - Card Container
final class LumosCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = LumosTheme.Pigment.cardSurface
        layer.cornerRadius = LumosTheme.Radius.md
        layer.borderWidth = 1
        layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// MARK: - Stat Badge
final class OrbitStatBadge: UIView {

    private let titleLbl = UILabel()
    private let valueLbl = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = LumosTheme.Pigment.elevatedCard
        layer.cornerRadius = LumosTheme.Radius.sm
        layer.borderWidth = 1
        layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor

        titleLbl.font = LumosTheme.Typeface.body(11)
        titleLbl.textColor = LumosTheme.Pigment.textSecondary
        titleLbl.textAlignment = .center

        valueLbl.font = LumosTheme.Typeface.mono(18)
        valueLbl.textColor = LumosTheme.Pigment.auroraCyan
        valueLbl.textAlignment = .center
        valueLbl.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [valueLbl, titleLbl])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(title: String, value: String, accentColor: UIColor = LumosTheme.Pigment.auroraCyan) {
        titleLbl.text = title
        valueLbl.text = value
        valueLbl.textColor = accentColor
    }
}

// MARK: - Section Header
final class LumosSectionHeader: UIView {

    private let lineLead = UIView()
    private let label    = UILabel()

    init(title: String, accentColor: UIColor = LumosTheme.Pigment.auroraCyan) {
        super.init(frame: .zero)
        lineLead.backgroundColor = accentColor
        lineLead.layer.cornerRadius = 2
        label.text = title
        label.font = LumosTheme.Typeface.subhead(14)
        label.textColor = LumosTheme.Pigment.textPrimary

        let stack = UIStackView(arrangedSubviews: [lineLead, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            lineLead.widthAnchor.constraint(equalToConstant: 4),
            lineLead.heightAnchor.constraint(equalToConstant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// MARK: - Stepper Row
final class CrystalStepperRow: UIView {

    var onValueChanged: ((Int) -> Void)?
    private(set) var currentValue: Int = 1

    private let titleLbl  = UILabel()
    private let valueLbl  = UILabel()
    private let minusBtn  = UIButton(type: .system)
    private let plusBtn   = UIButton(type: .system)

    private var minVal: Int = 1
    private var maxVal: Int = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrbit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupOrbit() }

    private func setupOrbit() {
        backgroundColor = LumosTheme.Pigment.elevatedCard
        layer.cornerRadius = LumosTheme.Radius.sm
        layer.borderWidth = 1
        layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor

        titleLbl.font = LumosTheme.Typeface.body(14)
        titleLbl.textColor = LumosTheme.Pigment.textSecondary

        valueLbl.font = LumosTheme.Typeface.mono(18)
        valueLbl.textColor = LumosTheme.Pigment.auroraCyan
        valueLbl.textAlignment = .center
        valueLbl.setContentHuggingPriority(.required, for: .horizontal)

        for btn in [minusBtn, plusBtn] {
            btn.tintColor = LumosTheme.Pigment.auroraViolet
            btn.titleLabel?.font = LumosTheme.Typeface.headline(20)
            btn.backgroundColor = LumosTheme.Pigment.cardSurface
            btn.layer.cornerRadius = 8
        }
        minusBtn.setTitle("−", for: .normal)
        plusBtn.setTitle("+", for: .normal)
        minusBtn.addTarget(self, action: #selector(tapMinus), for: .touchUpInside)
        plusBtn.addTarget(self, action: #selector(tapPlus), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLbl, UIView(), valueLbl, minusBtn, plusBtn])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            minusBtn.widthAnchor.constraint(equalToConstant: 32),
            minusBtn.heightAnchor.constraint(equalToConstant: 32),
            plusBtn.widthAnchor.constraint(equalToConstant: 32),
            plusBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(title: String, value: Int, min: Int, max: Int) {
        titleLbl.text = title
        currentValue = value
        minVal = min
        maxVal = max
        valueLbl.text = "\(value)"
    }

    @objc private func tapMinus() {
        guard currentValue > minVal else { return }
        currentValue -= 1
        valueLbl.text = "\(currentValue)"
        onValueChanged?(currentValue)
        bounceValue()
    }
    @objc private func tapPlus() {
        guard currentValue < maxVal else { return }
        currentValue += 1
        valueLbl.text = "\(currentValue)"
        onValueChanged?(currentValue)
        bounceValue()
    }
    private func bounceValue() {
        UIView.animate(withDuration: 0.1, animations: { self.valueLbl.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }) { _ in
            UIView.animate(withDuration: 0.15) { self.valueLbl.transform = .identity }
        }
    }
}
