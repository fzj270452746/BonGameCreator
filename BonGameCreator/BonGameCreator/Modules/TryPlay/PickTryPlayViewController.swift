import UIKit

// MARK: - Pick Try Play
final class PickTryPlayViewController: UIViewController {

    private let config: CrystalPickConfig
    private var cardPool: [Double] = []
    private var flippedIndices: Set<Int> = []
    private var totalWin: Double = 0
    private var picksLeft: Int = 0

    private let scrollView    = UIScrollView()
    private let contentStack  = UIStackView()
    private let winLabel      = UILabel()
    private let picksLeftLbl  = UILabel()
    private var cardButtons:  [UIButton] = []
    private let resetBtn      = NebulaCTAButton()

    init(config: CrystalPickConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Try Play — Pick Game"
        setupLayout()
        startNewRound()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = LumosTheme.Spacing.md
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: LumosTheme.Spacing.lg),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: LumosTheme.Spacing.md),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -LumosTheme.Spacing.md),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -LumosTheme.Spacing.lg),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -LumosTheme.Spacing.md * 2)
        ])

        winLabel.font = LumosTheme.Typeface.headline(36)
        winLabel.textColor = LumosTheme.Pigment.auroraAmber
        winLabel.textAlignment = .center
        contentStack.addArrangedSubview(winLabel)

        picksLeftLbl.font = LumosTheme.Typeface.subhead(16)
        picksLeftLbl.textColor = LumosTheme.Pigment.textSecondary
        picksLeftLbl.textAlignment = .center
        contentStack.addArrangedSubview(picksLeftLbl)

        resetBtn.setTitle("↺  New Round", for: .normal)
        resetBtn.configureGradient(colors: LumosTheme.Gradient.cyanPurple)
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        resetBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        resetBtn.addTarget(self, action: #selector(tapReset), for: .touchUpInside)
    }

    private func startNewRound() {
        cardPool = VortexSimEngine.shared.singlePickPlay(cfg: config)
        flippedIndices = []
        totalWin = 0
        picksLeft = config.pickCount
        winLabel.text = "Win: 0.00×"
        picksLeftLbl.text = "Picks left: \(picksLeft)"

        contentStack.arrangedSubviews
            .filter { $0 is UICollectionView || $0 is UIView && $0 != winLabel && $0 != picksLeftLbl && $0 != resetBtn }
            .forEach { $0.removeFromSuperview() }

        let grid = buildCardGrid()
        contentStack.addArrangedSubview(grid)
        contentStack.addArrangedSubview(resetBtn)
    }

    private func buildCardGrid() -> UIView {
        let cols = 3
        let spacing: CGFloat = 10
        let cardSize: CGFloat = (UIScreen.main.bounds.width - LumosTheme.Spacing.md * 2 - spacing * CGFloat(cols - 1)) / CGFloat(cols)

        let wrapper = UIView()
        cardButtons = []

        let rows = Int(ceil(Double(cardPool.count) / Double(cols)))
        for row in 0..<rows {
            for col in 0..<cols {
                let idx = row * cols + col
                guard idx < cardPool.count else { continue }
                let btn = buildCardButton(index: idx, size: cardSize)
                btn.frame = CGRect(x: CGFloat(col) * (cardSize + spacing),
                                   y: CGFloat(row) * (cardSize + spacing),
                                   width: cardSize, height: cardSize)
                wrapper.addSubview(btn)
                cardButtons.append(btn)
            }
        }
        let totalH = CGFloat(rows) * cardSize + CGFloat(rows - 1) * spacing
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.heightAnchor.constraint(equalToConstant: totalH).isActive = true
        wrapper.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - LumosTheme.Spacing.md * 2).isActive = true
        return wrapper
    }

    private func buildCardButton(index: Int, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = index
        btn.backgroundColor = LumosTheme.Pigment.cardSurface
        btn.layer.cornerRadius = LumosTheme.Radius.md
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
        btn.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        btn.tintColor = LumosTheme.Pigment.auroraViolet
        btn.imageView?.contentMode = .scaleAspectFit
        btn.applyLumosGlow(color: LumosTheme.Pigment.auroraViolet, radius: 4, opacity: 0.3)
        btn.addTarget(self, action: #selector(tapCard(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func tapCard(_ sender: UIButton) {
        let idx = sender.tag
        guard !flippedIndices.contains(idx), picksLeft > 0 else { return }
        flippedIndices.insert(idx)
        picksLeft -= 1
        let reward = cardPool[idx]
        totalWin += reward

        UIView.transition(with: sender, duration: 0.4, options: .transitionFlipFromLeft) {
            sender.backgroundColor = LumosTheme.Pigment.elevatedCard
            sender.setImage(nil, for: .normal)
            sender.setTitle(String(format: "%.1f×", reward), for: .normal)
            sender.titleLabel?.font = LumosTheme.Typeface.headline(16)
            sender.setTitleColor(LumosTheme.Pigment.auroraAmber, for: .normal)
            sender.layer.borderColor = LumosTheme.Pigment.auroraAmber.cgColor
        }

        winLabel.text = String(format: "Win: %.2f×", totalWin)
        picksLeftLbl.text = picksLeft > 0 ? "Picks left: \(picksLeft)" : "Round Complete!"

        UIView.animate(withDuration: 0.15, animations: { self.winLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) }) { _ in
            UIView.animate(withDuration: 0.2) { self.winLabel.transform = .identity }
        }

        if picksLeft == 0 {
            revealAllCards()
        }
    }

    private func revealAllCards() {
        for (i, btn) in cardButtons.enumerated() {
            guard !flippedIndices.contains(i) else { continue }
            UIView.transition(with: btn, duration: 0.3, options: .transitionFlipFromLeft) {
                btn.backgroundColor = LumosTheme.Pigment.midnightSurface
                btn.setImage(nil, for: .normal)
                btn.setTitle(String(format: "%.1f×", self.cardPool[i]), for: .normal)
                btn.titleLabel?.font = LumosTheme.Typeface.body(13)
                btn.setTitleColor(LumosTheme.Pigment.textMuted, for: .normal)
                btn.layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
            }
        }
    }

    @objc private func tapReset() { startNewRound() }
}
