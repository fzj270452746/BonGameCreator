import UIKit

// MARK: - Cascade Try Play
final class CascadeTryPlayViewController: UIViewController {

    private let config: CrystalCascadeConfig
    private let reelView = ReelAnimationView()
    private let cascadeInfoCard = LumosCardView()
    private let resultLbl = UILabel()
    private let cascadeLbl = UILabel()
    private let spinBtn = NebulaCTAButton()
    private var totalWin = 0.0
    private var cascadeCount = 0

    init(config: CrystalCascadeConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Cascade — Try Play"
        buildLayout()
    }

    private func buildLayout() {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LumosTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: LumosTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: LumosTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -LumosTheme.Spacing.md),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -LumosTheme.Spacing.lg),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -LumosTheme.Spacing.md * 2)
        ])

        let infoLbl = UILabel()
        infoLbl.text = "Grid: \(config.cols)×\(config.rows) | Symbols: \(config.symbolCount) | Min Match: \(config.minMatch) | Max Cascades: \(config.maxCascades)"
        infoLbl.font = LumosTheme.Typeface.body(12)
        infoLbl.textColor = LumosTheme.Pigment.textSecondary
        infoLbl.numberOfLines = 0
        stack.addArrangedSubview(infoLbl)

        reelView.translatesAutoresizingMaskIntoConstraints = false
        reelView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.addArrangedSubview(reelView)

        // Result card
        cascadeInfoCard.translatesAutoresizingMaskIntoConstraints = false
        cascadeInfoCard.heightAnchor.constraint(equalToConstant: 80).isActive = true
        let infoStack = UIStackView(arrangedSubviews: [resultLbl, cascadeLbl])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        cascadeInfoCard.addSubview(infoStack)
        NSLayoutConstraint.activate([
            infoStack.centerXAnchor.constraint(equalTo: cascadeInfoCard.centerXAnchor),
            infoStack.centerYAnchor.constraint(equalTo: cascadeInfoCard.centerYAnchor)
        ])

        resultLbl.text = "Tap Spin to play"
        resultLbl.font = LumosTheme.Typeface.headline(20)
        resultLbl.textColor = LumosTheme.Pigment.auroraCyan
        cascadeLbl.text = ""
        cascadeLbl.font = LumosTheme.Typeface.body(13)
        cascadeLbl.textColor = LumosTheme.Pigment.textMuted
        stack.addArrangedSubview(cascadeInfoCard)

        spinBtn.setTitle("▶  Spin", for: .normal)
        spinBtn.configureGradient(colors: LumosTheme.Gradient.heroTop)
        spinBtn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        spinBtn.addTarget(self, action: #selector(tapSpin), for: .touchUpInside)
        stack.addArrangedSubview(spinBtn)
    }

    @objc private func tapSpin() {
        reelView.startSpinning()
        spinBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let outcome = VortexSimEngine.shared.simulateCascade(cfg: self.config)
            self.reelView.stopSpinning(result: outcome)
            self.totalWin = outcome
            self.cascadeCount = Int.random(in: 1...self.config.maxCascades)
            self.resultLbl.text = String(format: "+%.2fx", outcome)
            self.cascadeLbl.text = "\(self.cascadeCount) cascade(s)"
            self.spinBtn.isEnabled = true
        }
    }
}

// MARK: - Expanding Wilds Try Play
final class ExpandingWildsTryPlayViewController: UIViewController {

    private let config: CrystalExpandingWildsConfig
    private let reelView = ReelAnimationView()
    private let resultLbl = UILabel()
    private let wildInfoLbl = UILabel()
    private let spinBtn = NebulaCTAButton()

    init(config: CrystalExpandingWildsConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Expanding Wilds — Try Play"
        buildLayout()
    }

    private func buildLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LumosTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LumosTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LumosTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.md)
        ])

        let infoLbl = UILabel()
        infoLbl.text = "Reels: \(config.reelCount) | Wild: \(Int(config.wildChance*100))% | Expand: \(Int(config.expandChance*100))% | Wild Mult: \(String(format: "%.1f", config.wildMultiplier))×"
        infoLbl.font = LumosTheme.Typeface.body(12)
        infoLbl.textColor = LumosTheme.Pigment.textSecondary
        infoLbl.numberOfLines = 0
        stack.addArrangedSubview(infoLbl)

        reelView.translatesAutoresizingMaskIntoConstraints = false
        reelView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.addArrangedSubview(reelView)

        let resultCard = LumosCardView()
        resultCard.heightAnchor.constraint(equalToConstant: 90).isActive = true
        let cardStack = UIStackView(arrangedSubviews: [resultLbl, wildInfoLbl])
        cardStack.axis = .vertical
        cardStack.spacing = 4
        cardStack.alignment = .center
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        resultCard.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.centerXAnchor.constraint(equalTo: resultCard.centerXAnchor),
            cardStack.centerYAnchor.constraint(equalTo: resultCard.centerYAnchor)
        ])
        resultLbl.text = "Tap Spin"
        resultLbl.font = LumosTheme.Typeface.headline(22)
        resultLbl.textColor = LumosTheme.Pigment.auroraAmber
        wildInfoLbl.text = ""
        wildInfoLbl.font = LumosTheme.Typeface.body(12)
        wildInfoLbl.textColor = LumosTheme.Pigment.textMuted
        stack.addArrangedSubview(resultCard)

        spinBtn.setTitle("▶  Spin", for: .normal)
        spinBtn.configureGradient(colors: LumosTheme.Gradient.amberOrange)
        spinBtn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        spinBtn.addTarget(self, action: #selector(tapSpin), for: .touchUpInside)
        stack.addArrangedSubview(spinBtn)
    }

    @objc private func tapSpin() {
        reelView.startSpinning()
        spinBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let outcome = VortexSimEngine.shared.simulateExpandingWilds(cfg: self.config)
            self.reelView.stopSpinning(result: outcome)
            self.resultLbl.text = String(format: "+%.2fx", outcome)
            let wildCount = (0..<self.config.reelCount).filter { _ in Double.random(in: 0..<1) < self.config.wildChance }.count
            self.wildInfoLbl.text = "\(wildCount) wild(s) appeared"
            self.spinBtn.isEnabled = true
        }
    }
}

// MARK: - Bonus Buy Try Play
final class BonusBuyTryPlayViewController: UIViewController {

    private let config: CrystalBonusBuyConfig
    private let resultLbl = UILabel()
    private let subtitleLbl = UILabel()
    private let buyBtn = NebulaCTAButton()
    private let costLbl = UILabel()

    init(config: CrystalBonusBuyConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Bonus Buy — Try Play"
        buildLayout()
    }

    private func buildLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LumosTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LumosTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LumosTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.md)
        ])

        let paramCard = LumosCardView()
        let paramStack = UIStackView()
        paramStack.axis = .vertical
        paramStack.spacing = 6
        paramStack.translatesAutoresizingMaskIntoConstraints = false
        paramCard.addSubview(paramStack)
        NSLayoutConstraint.activate([
            paramStack.topAnchor.constraint(equalTo: paramCard.topAnchor, constant: 12),
            paramStack.leadingAnchor.constraint(equalTo: paramCard.leadingAnchor, constant: 14),
            paramStack.trailingAnchor.constraint(equalTo: paramCard.trailingAnchor, constant: -14),
            paramStack.bottomAnchor.constraint(equalTo: paramCard.bottomAnchor, constant: -12)
        ])
        for (label, value) in [("Buy Cost", "\(String(format: "%.0f", config.buyCostMultiplier))× bet"),
                                ("Bonus RTP", "\(String(format: "%.0f", config.bonusTriggerRTP))%"),
                                ("Base RTP", "\(String(format: "%.1f", config.baseGameRTP))%")] {
            let row = UIStackView()
            row.axis = .horizontal
            let l = UILabel(); l.text = label; l.font = LumosTheme.Typeface.body(13); l.textColor = LumosTheme.Pigment.textSecondary
            let v = UILabel(); v.text = value; v.font = LumosTheme.Typeface.mono(13); v.textColor = LumosTheme.Pigment.auroraOrange; v.textAlignment = .right
            row.addArrangedSubview(l); row.addArrangedSubview(UIView()); row.addArrangedSubview(v)
            paramStack.addArrangedSubview(row)
        }
        stack.addArrangedSubview(paramCard)

        let resultCard = LumosCardView()
        resultCard.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let rStack = UIStackView(arrangedSubviews: [resultLbl, subtitleLbl, costLbl])
        rStack.axis = .vertical; rStack.spacing = 4; rStack.alignment = .center
        rStack.translatesAutoresizingMaskIntoConstraints = false
        resultCard.addSubview(rStack)
        NSLayoutConstraint.activate([rStack.centerXAnchor.constraint(equalTo: resultCard.centerXAnchor), rStack.centerYAnchor.constraint(equalTo: resultCard.centerYAnchor)])
        resultLbl.text = "Ready to buy bonus"
        resultLbl.font = LumosTheme.Typeface.headline(18)
        resultLbl.textColor = LumosTheme.Pigment.auroraOrange
        subtitleLbl.text = ""
        subtitleLbl.font = LumosTheme.Typeface.body(12)
        subtitleLbl.textColor = LumosTheme.Pigment.textMuted
        costLbl.text = ""
        costLbl.font = LumosTheme.Typeface.mono(12)
        costLbl.textColor = LumosTheme.Pigment.auroraMagenta
        stack.addArrangedSubview(resultCard)

        buyBtn.setTitle("🎰  Buy Bonus", for: .normal)
        buyBtn.configureGradient(colors: [LumosTheme.Pigment.auroraOrange, LumosTheme.Pigment.auroraAmber])
        buyBtn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        buyBtn.addTarget(self, action: #selector(tapBuy), for: .touchUpInside)
        stack.addArrangedSubview(buyBtn)
    }

    @objc private func tapBuy() {
        buyBtn.isEnabled = false
        let outcome = VortexSimEngine.shared.simulateBonusBuy(cfg: config)
        let cost = config.buyCostMultiplier
        let profit = outcome - cost
        resultLbl.text = String(format: "Payout: %.2fx", outcome)
        subtitleLbl.text = profit >= 0 ? String(format: "Net: +%.2fx ✓", profit) : String(format: "Net: %.2fx ✗", profit)
        subtitleLbl.textColor = profit >= 0 ? LumosTheme.Pigment.auroraGreen : LumosTheme.Pigment.auroraMagenta
        costLbl.text = String(format: "Cost was: %.0fx", cost)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.buyBtn.isEnabled = true
        }
    }
}
