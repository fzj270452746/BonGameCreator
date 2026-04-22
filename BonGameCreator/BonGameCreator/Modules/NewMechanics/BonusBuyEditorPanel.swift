import UIKit

final class BonusBuyEditorPanel: UIView {

    private(set) var currentConfig = CrystalBonusBuyConfig()

    private let costSlider      = CrystalSliderRow()
    private let bonusRTPSlider  = CrystalSliderRow()
    private let baseRTPSlider   = CrystalSliderRow()
    private let varianceSlider  = CrystalSliderRow()

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

        outer.addArrangedSubview(LumosSectionHeader(title: "Bonus Buy Config", accentColor: LumosTheme.Pigment.auroraOrange))

        costSlider.configure(title: "Buy Cost (×bet)", value: Float(currentConfig.buyCostMultiplier),
                             min: 20, max: 200, format: "%.0fx",
                             accentColor: LumosTheme.Pigment.auroraOrange)
        costSlider.onValueChanged = { [weak self] v in self?.currentConfig.buyCostMultiplier = Double(v) }
        outer.addArrangedSubview(costSlider)

        bonusRTPSlider.configure(title: "Bonus RTP (%)", value: Float(currentConfig.bonusTriggerRTP),
                                 min: 80, max: 200, format: "%.0f%%",
                                 accentColor: LumosTheme.Pigment.auroraAmber)
        bonusRTPSlider.onValueChanged = { [weak self] v in self?.currentConfig.bonusTriggerRTP = Double(v) }
        outer.addArrangedSubview(bonusRTPSlider)

        baseRTPSlider.configure(title: "Base Game RTP (%)", value: Float(currentConfig.baseGameRTP),
                                min: 85, max: 99, format: "%.1f%%",
                                accentColor: LumosTheme.Pigment.auroraCyan)
        baseRTPSlider.onValueChanged = { [weak self] v in self?.currentConfig.baseGameRTP = Double(v) }
        outer.addArrangedSubview(baseRTPSlider)

        varianceSlider.configure(title: "Variance", value: Float(currentConfig.variance),
                                 min: 0.05, max: 0.8, format: "%.2f",
                                 accentColor: LumosTheme.Pigment.auroraMagenta)
        varianceSlider.onValueChanged = { [weak self] v in self?.currentConfig.variance = Double(v) }
        outer.addArrangedSubview(varianceSlider)

        // Info card
        let infoCard = LumosCardView()
        let infoLbl = UILabel()
        infoLbl.text = "Bonus Buy simulates the expected return of directly purchasing a bonus round. Expected payout = Bonus RTP ÷ 100 × Buy Cost."
        infoLbl.font = LumosTheme.Typeface.body(11)
        infoLbl.textColor = LumosTheme.Pigment.textSecondary
        infoLbl.numberOfLines = 0
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        infoCard.addSubview(infoLbl)
        NSLayoutConstraint.activate([
            infoLbl.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 10),
            infoLbl.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 12),
            infoLbl.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -12),
            infoLbl.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -10)
        ])
        outer.addArrangedSubview(infoCard)
    }

    func applyConfig(_ cfg: CrystalBonusBuyConfig) {
        currentConfig = cfg
        costSlider.configure(title: "Buy Cost (×bet)", value: Float(cfg.buyCostMultiplier),
                             min: 20, max: 200, format: "%.0fx", accentColor: LumosTheme.Pigment.auroraOrange)
        bonusRTPSlider.configure(title: "Bonus RTP (%)", value: Float(cfg.bonusTriggerRTP),
                                 min: 80, max: 200, format: "%.0f%%", accentColor: LumosTheme.Pigment.auroraAmber)
        baseRTPSlider.configure(title: "Base Game RTP (%)", value: Float(cfg.baseGameRTP),
                                min: 85, max: 99, format: "%.1f%%", accentColor: LumosTheme.Pigment.auroraCyan)
        varianceSlider.configure(title: "Variance", value: Float(cfg.variance),
                                 min: 0.05, max: 0.8, format: "%.2f", accentColor: LumosTheme.Pigment.auroraMagenta)
    }
}
