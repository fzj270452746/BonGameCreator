import UIKit

final class FreeSpinsEditorPanel: UIView {

    private(set) var currentConfig = CrystalFreeSpinsConfig()

    private let spinCountRow    = CrystalStepperRow()
    private let multiplierSlider = CrystalSliderRow()
    private let retriggerSlider  = CrystalSliderRow()
    private let minRewardSlider  = CrystalSliderRow()
    private let maxRewardSlider  = CrystalSliderRow()

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

        let header = LumosSectionHeader(title: "Free Spins Config", accentColor: LumosTheme.Pigment.auroraGreen)
        outerStack.addArrangedSubview(header)

        spinCountRow.configure(title: "Spin Count", value: currentConfig.spinCount, min: 3, max: 50)
        spinCountRow.onValueChanged = { [weak self] v in self?.currentConfig.spinCount = v }
        outerStack.addArrangedSubview(spinCountRow)

        multiplierSlider.configure(title: "Base Multiplier",
                                   value: Float(currentConfig.baseMultiplier),
                                   min: 1, max: 10, format: "%.1fx",
                                   accentColor: LumosTheme.Pigment.auroraAmber)
        multiplierSlider.onValueChanged = { [weak self] v in self?.currentConfig.baseMultiplier = Double(v) }
        outerStack.addArrangedSubview(multiplierSlider)

        retriggerSlider.configure(title: "Retrigger Chance",
                                  value: Float(currentConfig.retriggerChance * 100),
                                  min: 0, max: 30, format: "%.0f%%",
                                  accentColor: LumosTheme.Pigment.auroraMagenta)
        retriggerSlider.onValueChanged = { [weak self] v in self?.currentConfig.retriggerChance = Double(v) / 100.0 }
        outerStack.addArrangedSubview(retriggerSlider)

        minRewardSlider.configure(title: "Min Spin Reward",
                                  value: Float(currentConfig.minSpinReward),
                                  min: 0.1, max: 5, format: "%.1fx",
                                  accentColor: LumosTheme.Pigment.auroraGreen)
        minRewardSlider.onValueChanged = { [weak self] v in self?.currentConfig.minSpinReward = Double(v) }
        outerStack.addArrangedSubview(minRewardSlider)

        maxRewardSlider.configure(title: "Max Spin Reward",
                                  value: Float(currentConfig.maxSpinReward),
                                  min: 1, max: 50, format: "%.1fx",
                                  accentColor: LumosTheme.Pigment.auroraCyan)
        maxRewardSlider.onValueChanged = { [weak self] v in self?.currentConfig.maxSpinReward = Double(v) }
        outerStack.addArrangedSubview(maxRewardSlider)
    }

    func applyConfig(_ cfg: CrystalFreeSpinsConfig) {
        currentConfig = cfg
        spinCountRow.configure(title: "Spin Count", value: cfg.spinCount, min: 3, max: 50)
        multiplierSlider.configure(title: "Base Multiplier", value: Float(cfg.baseMultiplier), min: 1, max: 10, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraAmber)
        retriggerSlider.configure(title: "Retrigger Chance", value: Float(cfg.retriggerChance * 100), min: 0, max: 30, format: "%.0f%%", accentColor: LumosTheme.Pigment.auroraMagenta)
        minRewardSlider.configure(title: "Min Spin Reward", value: Float(cfg.minSpinReward), min: 0.1, max: 5, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraGreen)
        maxRewardSlider.configure(title: "Max Spin Reward", value: Float(cfg.maxSpinReward), min: 1, max: 50, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraCyan)
    }
}

// MARK: - Slider Row Widget
final class CrystalSliderRow: UIView {

    var onValueChanged: ((Float) -> Void)?

    private let titleLbl  = UILabel()
    private let valueLbl  = UILabel()
    private let slider    = UISlider()
    private var fmt: String = "%.1f"

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

        titleLbl.font = LumosTheme.Typeface.body(13)
        titleLbl.textColor = LumosTheme.Pigment.textSecondary

        valueLbl.font = LumosTheme.Typeface.mono(14)
        valueLbl.textColor = LumosTheme.Pigment.auroraCyan
        valueLbl.textAlignment = .right
        valueLbl.setContentHuggingPriority(.required, for: .horizontal)

        slider.minimumTrackTintColor = LumosTheme.Pigment.auroraCyan
        slider.maximumTrackTintColor = LumosTheme.Pigment.borderGlow
        slider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)

        let topRow = UIStackView(arrangedSubviews: [titleLbl, UIView(), valueLbl])
        topRow.axis = .horizontal
        topRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [topRow, slider])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    func configure(title: String, value: Float, min: Float, max: Float, format: String, accentColor: UIColor) {
        titleLbl.text = title
        fmt = format
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.minimumTrackTintColor = accentColor
        valueLbl.textColor = accentColor
        valueLbl.text = String(format: fmt, value)
    }

    @objc private func sliderMoved() {
        valueLbl.text = String(format: fmt, slider.value)
        onValueChanged?(slider.value)
    }
}
