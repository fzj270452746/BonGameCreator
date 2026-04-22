import UIKit

final class ExpandingWildsEditorPanel: UIView {

    private(set) var currentConfig = CrystalExpandingWildsConfig()

    private let reelRow         = CrystalStepperRow()
    private let wildChanceSlider    = CrystalSliderRow()
    private let expandChanceSlider  = CrystalSliderRow()
    private let baseRewardSlider    = CrystalSliderRow()
    private let wildMultiSlider     = CrystalSliderRow()

    override init(frame: CGRect) { super.init(frame: frame); setupOrbit() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupOrbit() }

    private func setupOrbit() {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = LumosTheme.Spacing.sm
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        outer.addArrangedSubview(LumosSectionHeader(title: "Expanding Wilds Config", accentColor: LumosTheme.Pigment.auroraAmber))

        reelRow.configure(title: "Reel Count", value: currentConfig.reelCount, min: 3, max: 7)
        reelRow.onValueChanged = { [weak self] v in self?.currentConfig.reelCount = v }
        outer.addArrangedSubview(reelRow)

        wildChanceSlider.configure(title: "Wild Appearance Chance", value: Float(currentConfig.wildChance * 100),
                                   min: 1, max: 40, format: "%.0f%%",
                                   accentColor: LumosTheme.Pigment.auroraAmber)
        wildChanceSlider.onValueChanged = { [weak self] v in self?.currentConfig.wildChance = Double(v) / 100.0 }
        outer.addArrangedSubview(wildChanceSlider)

        expandChanceSlider.configure(title: "Expand Chance", value: Float(currentConfig.expandChance * 100),
                                     min: 5, max: 80, format: "%.0f%%",
                                     accentColor: LumosTheme.Pigment.auroraMagenta)
        expandChanceSlider.onValueChanged = { [weak self] v in self?.currentConfig.expandChance = Double(v) / 100.0 }
        outer.addArrangedSubview(expandChanceSlider)

        baseRewardSlider.configure(title: "Base Spin Reward", value: Float(currentConfig.baseSpinReward),
                                   min: 0.5, max: 10, format: "%.1fx",
                                   accentColor: LumosTheme.Pigment.auroraGreen)
        baseRewardSlider.onValueChanged = { [weak self] v in self?.currentConfig.baseSpinReward = Double(v) }
        outer.addArrangedSubview(baseRewardSlider)

        wildMultiSlider.configure(title: "Wild Multiplier", value: Float(currentConfig.wildMultiplier),
                                  min: 1.5, max: 10, format: "%.1fx",
                                  accentColor: LumosTheme.Pigment.auroraCyan)
        wildMultiSlider.onValueChanged = { [weak self] v in self?.currentConfig.wildMultiplier = Double(v) }
        outer.addArrangedSubview(wildMultiSlider)
    }

    func applyConfig(_ cfg: CrystalExpandingWildsConfig) {
        currentConfig = cfg
        reelRow.configure(title: "Reel Count", value: cfg.reelCount, min: 3, max: 7)
        wildChanceSlider.configure(title: "Wild Appearance Chance", value: Float(cfg.wildChance * 100),
                                   min: 1, max: 40, format: "%.0f%%", accentColor: LumosTheme.Pigment.auroraAmber)
        expandChanceSlider.configure(title: "Expand Chance", value: Float(cfg.expandChance * 100),
                                     min: 5, max: 80, format: "%.0f%%", accentColor: LumosTheme.Pigment.auroraMagenta)
        baseRewardSlider.configure(title: "Base Spin Reward", value: Float(cfg.baseSpinReward),
                                   min: 0.5, max: 10, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraGreen)
        wildMultiSlider.configure(title: "Wild Multiplier", value: Float(cfg.wildMultiplier),
                                  min: 1.5, max: 10, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraCyan)
    }
}
