import UIKit

final class WheelTryPlayViewController: UIViewController {

    private let config: CrystalWheelConfig
    private var totalWin: Double = 0
    private var spinCount: Int = 0
    private var isSpinning = false

    private let wheelCanvas   = SpinWheelCanvas()
    private let winLabel      = UILabel()
    private let totalLabel    = UILabel()
    private let spinBtn       = NebulaCTAButton()
    private let resetBtn      = UIButton(type: .system)
    private let resultBanner  = UILabel()

    init(config: CrystalWheelConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Try Play — Wheel"
        setupLayout()
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LumosTheme.Spacing.md
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: LumosTheme.Spacing.lg),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: LumosTheme.Spacing.md),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -LumosTheme.Spacing.md),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -LumosTheme.Spacing.lg),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -LumosTheme.Spacing.md * 2)
        ])

        // Wheel
        let wheelSize = min(UIScreen.main.bounds.width - 60, 300.0)
        wheelCanvas.translatesAutoresizingMaskIntoConstraints = false
        wheelCanvas.widthAnchor.constraint(equalToConstant: wheelSize).isActive = true
        wheelCanvas.heightAnchor.constraint(equalToConstant: wheelSize).isActive = true
        wheelCanvas.configure(config: config)
        stack.addArrangedSubview(wheelCanvas)

        // Pointer
        let pointerLbl = UILabel()
        pointerLbl.text = "▼"
        pointerLbl.font = LumosTheme.Typeface.headline(28)
        pointerLbl.textColor = LumosTheme.Pigment.auroraAmber
        pointerLbl.textAlignment = .center
        stack.addArrangedSubview(pointerLbl)

        // Result banner
        resultBanner.text = "Spin to win!"
        resultBanner.font = LumosTheme.Typeface.headline(22)
        resultBanner.textColor = LumosTheme.Pigment.auroraCyan
        resultBanner.textAlignment = .center
        stack.addArrangedSubview(resultBanner)

        // Stats row
        winLabel.font = LumosTheme.Typeface.mono(16)
        winLabel.textColor = LumosTheme.Pigment.auroraAmber
        winLabel.textAlignment = .center
        winLabel.text = "Last: —"

        totalLabel.font = LumosTheme.Typeface.mono(16)
        totalLabel.textColor = LumosTheme.Pigment.auroraGreen
        totalLabel.textAlignment = .center
        totalLabel.text = "Total: 0.00×"

        let statsRow = UIStackView(arrangedSubviews: [winLabel, totalLabel])
        statsRow.axis = .horizontal
        statsRow.spacing = LumosTheme.Spacing.lg
        statsRow.distribution = .fillEqually
        stack.addArrangedSubview(statsRow)

        // Spin button
        spinBtn.setTitle("🎡  SPIN", for: .normal)
        spinBtn.configureGradient(colors: LumosTheme.Gradient.heroTop)
        spinBtn.translatesAutoresizingMaskIntoConstraints = false
        spinBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        spinBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        spinBtn.addTarget(self, action: #selector(tapSpin), for: .touchUpInside)
        stack.addArrangedSubview(spinBtn)

        // Reset
        resetBtn.setTitle("Reset", for: .normal)
        resetBtn.titleLabel?.font = LumosTheme.Typeface.body(14)
        resetBtn.setTitleColor(LumosTheme.Pigment.textSecondary, for: .normal)
        resetBtn.addTarget(self, action: #selector(tapReset), for: .touchUpInside)
        stack.addArrangedSubview(resetBtn)
    }

    @objc private func tapSpin() {
        guard !isSpinning else { return }
        isSpinning = true
        spinBtn.isEnabled = false

        let result = VortexSimEngine.shared.singleWheelSpin(cfg: config)
        let segCount = config.segments.count
        let segAngle = (2.0 * Double.pi) / Double(segCount)
        let targetAngle = segAngle * Double(result.index) + segAngle / 2.0
        let extraSpins = Double.random(in: 4...7) * 2.0 * Double.pi
        let finalAngle = extraSpins + (2.0 * Double.pi - targetAngle)

        UIView.animate(withDuration: 3.5, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            self.wheelCanvas.transform = CGAffineTransform(rotationAngle: CGFloat(finalAngle))
        } completion: { _ in
            self.isSpinning = false
            self.spinBtn.isEnabled = true
            self.spinCount += 1
            self.totalWin += result.reward
            self.winLabel.text = "Last: \(String(format: "%.2f", result.reward))×"
            self.totalLabel.text = "Total: \(String(format: "%.2f", self.totalWin))×"
            self.resultBanner.text = "🎉 \(String(format: "%.2f", result.reward))× !"
            UIView.animate(withDuration: 0.3) {
                self.resultBanner.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) { self.resultBanner.transform = .identity }
            }
        }
    }

    @objc private func tapReset() {
        totalWin = 0
        spinCount = 0
        winLabel.text = "Last: —"
        totalLabel.text = "Total: 0.00×"
        resultBanner.text = "Spin to win!"
        wheelCanvas.transform = .identity
    }
}
