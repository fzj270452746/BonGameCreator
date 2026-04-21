import UIKit

final class PickGameEditorPanel: UIView {

    private(set) var currentConfig = CrystalPickConfig()

    private let cardCountRow  = CrystalStepperRow()
    private let pickCountRow  = CrystalStepperRow()
    private let rewardsCard   = LumosCardView()
    private let rewardsStack  = UIStackView()
    private let addRewardBtn  = UIButton(type: .system)

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

        let header = LumosSectionHeader(title: "Pick Game Config", accentColor: LumosTheme.Pigment.auroraCyan)
        outerStack.addArrangedSubview(header)

        cardCountRow.configure(title: "Card Count", value: currentConfig.cardCount, min: 3, max: 24)
        cardCountRow.onValueChanged = { [weak self] v in self?.currentConfig.cardCount = v }
        outerStack.addArrangedSubview(cardCountRow)

        pickCountRow.configure(title: "Pick Count", value: currentConfig.pickCount, min: 1, max: 12)
        pickCountRow.onValueChanged = { [weak self] v in self?.currentConfig.pickCount = v }
        outerStack.addArrangedSubview(pickCountRow)

        let rewardHeader = LumosSectionHeader(title: "Reward Tiers", accentColor: LumosTheme.Pigment.auroraAmber)
        outerStack.addArrangedSubview(rewardHeader)

        rewardsCard.translatesAutoresizingMaskIntoConstraints = false
        outerStack.addArrangedSubview(rewardsCard)

        rewardsStack.axis = .vertical
        rewardsStack.spacing = LumosTheme.Spacing.xs
        rewardsStack.translatesAutoresizingMaskIntoConstraints = false
        rewardsCard.addSubview(rewardsStack)
        NSLayoutConstraint.activate([
            rewardsStack.topAnchor.constraint(equalTo: rewardsCard.topAnchor, constant: LumosTheme.Spacing.sm),
            rewardsStack.leadingAnchor.constraint(equalTo: rewardsCard.leadingAnchor, constant: LumosTheme.Spacing.sm),
            rewardsStack.trailingAnchor.constraint(equalTo: rewardsCard.trailingAnchor, constant: -LumosTheme.Spacing.sm),
            rewardsStack.bottomAnchor.constraint(equalTo: rewardsCard.bottomAnchor, constant: -LumosTheme.Spacing.sm)
        ])

        rebuildRewardRows()

        addRewardBtn.setTitle("+ Add Reward Tier", for: .normal)
        addRewardBtn.titleLabel?.font = LumosTheme.Typeface.subhead(13)
        addRewardBtn.setTitleColor(LumosTheme.Pigment.auroraGreen, for: .normal)
        addRewardBtn.addTarget(self, action: #selector(tapAddReward), for: .touchUpInside)
        outerStack.addArrangedSubview(addRewardBtn)
    }

    private func rebuildRewardRows() {
        rewardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, reward) in currentConfig.rewardTiers.enumerated() {
            let row = buildRewardRow(index: i, value: reward)
            rewardsStack.addArrangedSubview(row)
        }
    }

    private func buildRewardRow(index: Int, value: Double) -> UIView {
        let container = UIView()
        container.backgroundColor = LumosTheme.Pigment.elevatedCard
        container.layer.cornerRadius = LumosTheme.Radius.sm

        let label = UILabel()
        label.text = "Tier \(index + 1)"
        label.font = LumosTheme.Typeface.body(13)
        label.textColor = LumosTheme.Pigment.textSecondary

        let field = PaddedTextField()
        field.text = String(format: "%.1f", value)
        field.font = LumosTheme.Typeface.mono(15)
        field.textColor = LumosTheme.Pigment.auroraAmber
        field.keyboardType = .decimalPad
        field.backgroundColor = LumosTheme.Pigment.cardSurface
        field.layer.cornerRadius = 6
        field.tag = index
        field.addTarget(self, action: #selector(rewardFieldChanged(_:)), for: .editingChanged)

        let xBtn = UIButton(type: .system)
        xBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        xBtn.tintColor = LumosTheme.Pigment.auroraMagenta
        xBtn.tag = index
        xBtn.addTarget(self, action: #selector(tapRemoveReward(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, UIView(), field, xBtn])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            field.widthAnchor.constraint(equalToConstant: 70),
            field.heightAnchor.constraint(equalToConstant: 32),
            xBtn.widthAnchor.constraint(equalToConstant: 28),
            xBtn.heightAnchor.constraint(equalToConstant: 28)
        ])
        return container
    }

    @objc private func rewardFieldChanged(_ field: UITextField) {
        let idx = field.tag
        guard idx < currentConfig.rewardTiers.count,
              let text = field.text, let val = Double(text) else { return }
        currentConfig.rewardTiers[idx] = val
    }

    @objc private func tapAddReward() {
        currentConfig.rewardTiers.append(1.0)
        rebuildRewardRows()
    }

    @objc private func tapRemoveReward(_ sender: UIButton) {
        let idx = sender.tag
        guard currentConfig.rewardTiers.count > 1 else { return }
        currentConfig.rewardTiers.remove(at: idx)
        rebuildRewardRows()
    }

    func applyConfig(_ config: CrystalPickConfig) {
        currentConfig = config
        cardCountRow.configure(title: "Card Count", value: config.cardCount, min: 3, max: 24)
        pickCountRow.configure(title: "Pick Count", value: config.pickCount, min: 1, max: 12)
        rebuildRewardRows()
    }
}
