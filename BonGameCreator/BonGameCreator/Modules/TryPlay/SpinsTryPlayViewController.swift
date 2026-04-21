import UIKit

final class SpinsTryPlayViewController: UIViewController {

    private let config: CrystalFreeSpinsConfig
    private var spinsRemaining: Int = 0
    private var totalWin: Double = 0
    private var isRunning = false

    private let spinsLbl    = UILabel()
    private let totalLbl    = UILabel()
    private let lastSpinLbl = UILabel()
    private let logStack    = UIStackView()
    private let logScroll   = UIScrollView()
    private let spinBtn     = NebulaCTAButton()
    private let autoBtn     = NebulaCTAButton()
    private let resetBtn    = UIButton(type: .system)
    private let reelView    = ReelAnimationView()

    init(config: CrystalFreeSpinsConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Try Play — Free Spins"
        setupLayout()
        resetGame()
    }

    private func setupLayout() {
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

        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = LumosTheme.Spacing.md
        outer.alignment = .center
        outer.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: scroll.topAnchor, constant: LumosTheme.Spacing.lg),
            outer.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: LumosTheme.Spacing.md),
            outer.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -LumosTheme.Spacing.md),
            outer.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -LumosTheme.Spacing.lg),
            outer.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -LumosTheme.Spacing.md * 2)
        ])

        // Reel animation
        reelView.translatesAutoresizingMaskIntoConstraints = false
        outer.addArrangedSubview(reelView)
        NSLayoutConstraint.activate([
            reelView.heightAnchor.constraint(equalToConstant: 100),
            reelView.widthAnchor.constraint(equalTo: outer.widthAnchor)
        ])

        // Stats
        spinsLbl.font = LumosTheme.Typeface.headline(32)
        spinsLbl.textColor = LumosTheme.Pigment.auroraCyan
        spinsLbl.textAlignment = .center
        outer.addArrangedSubview(spinsLbl)

        let spinsCaption = UILabel()
        spinsCaption.text = "Spins Remaining"
        spinsCaption.font = LumosTheme.Typeface.body(13)
        spinsCaption.textColor = LumosTheme.Pigment.textMuted
        spinsCaption.textAlignment = .center
        outer.addArrangedSubview(spinsCaption)

        lastSpinLbl.font = LumosTheme.Typeface.mono(18)
        lastSpinLbl.textColor = LumosTheme.Pigment.auroraAmber
        lastSpinLbl.textAlignment = .center
        outer.addArrangedSubview(lastSpinLbl)

        totalLbl.font = LumosTheme.Typeface.headline(22)
        totalLbl.textColor = LumosTheme.Pigment.auroraGreen
        totalLbl.textAlignment = .center
        outer.addArrangedSubview(totalLbl)

        // Buttons
        spinBtn.setTitle("▶  Spin Once", for: .normal)
        spinBtn.configureGradient(colors: LumosTheme.Gradient.heroTop)
        spinBtn.addTarget(self, action: #selector(tapSpinOnce), for: .touchUpInside)
        outer.addArrangedSubview(spinBtn)
        NSLayoutConstraint.activate([
            spinBtn.heightAnchor.constraint(equalToConstant: 52),
            spinBtn.widthAnchor.constraint(equalToConstant: 200)
        ])

        autoBtn.setTitle("⚡  Auto All", for: .normal)
        autoBtn.configureGradient(colors: LumosTheme.Gradient.amberOrange)
        autoBtn.addTarget(self, action: #selector(tapAutoAll), for: .touchUpInside)
        outer.addArrangedSubview(autoBtn)
        NSLayoutConstraint.activate([
            autoBtn.heightAnchor.constraint(equalToConstant: 48),
            autoBtn.widthAnchor.constraint(equalToConstant: 200)
        ])

        resetBtn.setTitle("Reset", for: .normal)
        resetBtn.setTitleColor(LumosTheme.Pigment.textSecondary, for: .normal)
        resetBtn.titleLabel?.font = LumosTheme.Typeface.body(14)
        resetBtn.addTarget(self, action: #selector(tapReset), for: .touchUpInside)
        outer.addArrangedSubview(resetBtn)

        // Log
        let logHeader = LumosSectionHeader(title: "Spin Log", accentColor: LumosTheme.Pigment.auroraViolet)
        logHeader.translatesAutoresizingMaskIntoConstraints = false
        outer.addArrangedSubview(logHeader)
        logHeader.widthAnchor.constraint(equalTo: outer.widthAnchor).isActive = true

        logScroll.translatesAutoresizingMaskIntoConstraints = false
        logScroll.backgroundColor = LumosTheme.Pigment.cardSurface
        logScroll.layer.cornerRadius = LumosTheme.Radius.sm
        outer.addArrangedSubview(logScroll)
        NSLayoutConstraint.activate([
            logScroll.heightAnchor.constraint(equalToConstant: 160),
            logScroll.widthAnchor.constraint(equalTo: outer.widthAnchor)
        ])

        logStack.axis = .vertical
        logStack.spacing = 4
        logStack.translatesAutoresizingMaskIntoConstraints = false
        logScroll.addSubview(logStack)
        NSLayoutConstraint.activate([
            logStack.topAnchor.constraint(equalTo: logScroll.topAnchor, constant: 8),
            logStack.leadingAnchor.constraint(equalTo: logScroll.leadingAnchor, constant: 10),
            logStack.trailingAnchor.constraint(equalTo: logScroll.trailingAnchor, constant: -10),
            logStack.bottomAnchor.constraint(equalTo: logScroll.bottomAnchor, constant: -8),
            logStack.widthAnchor.constraint(equalTo: logScroll.widthAnchor, constant: -20)
        ])
    }

    private func resetGame() {
        spinsRemaining = config.spinCount
        totalWin = 0
        logStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        updateUI()
        lastSpinLbl.text = "Ready to spin!"
    }

    private func updateUI() {
        spinsLbl.text = "\(spinsRemaining)"
        totalLbl.text = "Total Win: \(String(format: "%.2f", totalWin))×"
        spinBtn.isEnabled = spinsRemaining > 0
        autoBtn.isEnabled = spinsRemaining > 0
    }

    private func executeSingleSpin() -> Double {
        let reward = Double.random(in: config.minSpinReward...config.maxSpinReward) * config.baseMultiplier
        totalWin += reward
        spinsRemaining -= 1
        if Double.random(in: 0..<1) < config.retriggerChance {
            let bonus = Int.random(in: 3...8)
            spinsRemaining += bonus
            appendLog("Retrigger! +\(bonus) spins", color: LumosTheme.Pigment.auroraMagenta)
        }
        appendLog("Spin: +\(String(format: "%.2f", reward))×", color: LumosTheme.Pigment.auroraGreen)
        return reward
    }

    private func appendLog(_ text: String, color: UIColor) {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = LumosTheme.Typeface.mono(12)
        lbl.textColor = color
        logStack.addArrangedSubview(lbl)
        DispatchQueue.main.async {
            let bottom = self.logScroll.contentSize.height - self.logScroll.bounds.height
            if bottom > 0 { self.logScroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: true) }
        }
    }

    @objc private func tapSpinOnce() {
        guard spinsRemaining > 0 else { return }
        reelView.playAnimation()
        let reward = executeSingleSpin()
        lastSpinLbl.text = "Last: \(String(format: "%.2f", reward))×"
        updateUI()
        if spinsRemaining == 0 { showFinished() }
    }

    @objc private func tapAutoAll() {
        guard spinsRemaining > 0 else { return }
        isRunning = true
        spinBtn.isEnabled = false
        autoBtn.isEnabled = false
        runAutoSpin()
    }

    private func runAutoSpin() {
        guard spinsRemaining > 0 else {
            isRunning = false
            updateUI()
            showFinished()
            return
        }
        reelView.playAnimation()
        let reward = executeSingleSpin()
        lastSpinLbl.text = "Last: \(String(format: "%.2f", reward))×"
        spinsLbl.text = "\(spinsRemaining)"
        totalLbl.text = "Total Win: \(String(format: "%.2f", totalWin))×"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.runAutoSpin()
        }
    }

    private func showFinished() {
        let alert = LumosConfirmAlertView(
            title: "Round Complete!",
            message: "Total Win: \(String(format: "%.2f", totalWin))×\nPlay again?",
            confirmTitle: "Play Again"
        ) { [weak self] in self?.resetGame() }
        alert.presentIn(self)
    }

    @objc private func tapReset() { resetGame() }
}
