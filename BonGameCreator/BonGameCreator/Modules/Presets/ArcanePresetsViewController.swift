import UIKit

// MARK: - Presets Browser (read-only gallery, distinct from Create tab)
final class ArcanePresetsViewController: UIViewController {

    private var allPresets: [NexusBlueprint] = []
    private var filtered: [NexusBlueprint] = []
    private var selectedFilter: ZephyrBonusKind? = nil

    private let filterScrollView = UIScrollView()
    private let filterStack = UIStackView()
    private var filterPills: [PresetFilterPill] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Presets"
        allPresets = ArcaneVaultStore.shared.builtInPresets()
        filtered = allPresets
        setupFilterBar()
        setupCollectionView()
    }

    // MARK: - Filter Bar

    private func setupFilterBar() {
        filterScrollView.showsHorizontalScrollIndicator = false
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterScrollView)
        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 38)
        ])

        filterStack.axis = .horizontal
        filterStack.spacing = 8
        filterStack.alignment = .center
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterScrollView.addSubview(filterStack)
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: filterScrollView.topAnchor),
            filterStack.leadingAnchor.constraint(equalTo: filterScrollView.leadingAnchor, constant: 16),
            filterStack.trailingAnchor.constraint(equalTo: filterScrollView.trailingAnchor, constant: -16),
            filterStack.bottomAnchor.constraint(equalTo: filterScrollView.bottomAnchor),
            filterStack.heightAnchor.constraint(equalTo: filterScrollView.heightAnchor)
        ])

        // "All" pill
        let allPill = PresetFilterPill(title: "All", color: LumosTheme.Pigment.textSecondary)
        allPill.addTarget(self, action: #selector(tapFilter(_:)), for: .touchUpInside)
        allPill.tag = -1
        filterStack.addArrangedSubview(allPill)
        filterPills.append(allPill)
        allPill.setActive(true)

        for kind in ZephyrBonusKind.allCases {
            let pill = PresetFilterPill(title: kind.stellarTitle, color: accentColor(for: kind))
            pill.addTarget(self, action: #selector(tapFilter(_:)), for: .touchUpInside)
            pill.tag = kind.rawValue
            filterStack.addArrangedSubview(pill)
            filterPills.append(pill)
        }
    }

    // MARK: - Collection

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.register(PresetGalleryCell.self, forCellWithReuseIdentifier: PresetGalleryCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Filter Action

    @objc private func tapFilter(_ sender: PresetFilterPill) {
        filterPills.forEach { $0.setActive(false) }
        sender.setActive(true)

        if sender.tag == -1 {
            selectedFilter = nil
            filtered = allPresets
        } else if let kind = ZephyrBonusKind(rawValue: sender.tag) {
            selectedFilter = kind
            filtered = allPresets.filter { $0.bonusKind == kind }
        }
        collectionView.reloadData()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Helpers

    func accentColor(for kind: ZephyrBonusKind) -> UIColor {
        switch kind {
        case .pickGame:       return LumosTheme.Pigment.auroraCyan
        case .wheelGame:      return LumosTheme.Pigment.auroraViolet
        case .freeSpins:      return LumosTheme.Pigment.auroraGreen
        case .cascade:        return LumosTheme.Pigment.auroraCyan
        case .expandingWilds: return LumosTheme.Pigment.auroraAmber
        case .bonusBuy:       return LumosTheme.Pigment.auroraOrange
        }
    }
}

// MARK: - Collection DataSource / Delegate

extension ArcanePresetsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filtered.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetGalleryCell.reuseID, for: indexPath) as! PresetGalleryCell
        cell.configure(with: filtered[indexPath.item], accentColor: accentColor(for: filtered[indexPath.item].bonusKind))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 46) / 2
        return CGSize(width: width, height: 190)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bp = filtered[indexPath.item]
        let detail = PresetDetailViewController(blueprint: bp, accentColor: accentColor(for: bp.bonusKind))
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Filter Pill

final class PresetFilterPill: UIControl {

    private let label = UILabel()
    private let pillColor: UIColor

    init(title: String, color: UIColor) {
        self.pillColor = color
        super.init(frame: .zero)
        layer.cornerRadius = 12
        layer.borderWidth = 1.5

        label.text = title
        label.font = LumosTheme.Typeface.subhead(12)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        setActive(false)
    }
    required init?(coder: NSCoder) { fatalError() }

    func setActive(_ active: Bool) {
        backgroundColor = active ? pillColor.withAlphaComponent(0.15) : LumosTheme.Pigment.cardSurface
        layer.borderColor = active ? pillColor.cgColor : LumosTheme.Pigment.borderGlow.cgColor
        label.textColor = active ? pillColor : LumosTheme.Pigment.textMuted
    }
}

// MARK: - Gallery Card Cell

final class PresetGalleryCell: UICollectionViewCell {
    static let reuseID = "PresetGalleryCell"

    private let cardView = LumosCardView()
    private let kindBadge = UILabel()
    private let iconView = UIImageView()
    private let nameLbl = UILabel()
    private let statsStack = UIStackView()
    private let useBtn = UIButton(type: .system)
    private var blueprint: NexusBlueprint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Badge top-right
        kindBadge.font = LumosTheme.Typeface.body(9)
        kindBadge.textColor = .white
        kindBadge.layer.cornerRadius = 6
        kindBadge.clipsToBounds = true
        kindBadge.textAlignment = .center
        kindBadge.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(kindBadge)

        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // Name
        nameLbl.font = LumosTheme.Typeface.subhead(14)
        nameLbl.textColor = LumosTheme.Pigment.textPrimary
        nameLbl.numberOfLines = 2

        // Stats stack (2 mini rows)
        statsStack.axis = .vertical
        statsStack.spacing = 4

        // Use button
        useBtn.titleLabel?.font = LumosTheme.Typeface.subhead(12)
        useBtn.layer.cornerRadius = LumosTheme.Radius.sm
        useBtn.setTitle("Use in Editor", for: .normal)
        useBtn.addTarget(self, action: #selector(tapUse), for: .touchUpInside)

        let topRow = UIStackView(arrangedSubviews: [iconView, UIView(), kindBadge])
        topRow.axis = .horizontal
        topRow.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [topRow, nameLbl, statsStack, UIView(), useBtn])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            kindBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            kindBadge.heightAnchor.constraint(equalToConstant: 18),
            useBtn.heightAnchor.constraint(equalToConstant: 30),
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with bp: NexusBlueprint, accentColor: UIColor) {
        self.blueprint = bp
        iconView.image = UIImage(systemName: bp.bonusKind.stellarIcon)
        iconView.tintColor = accentColor
        nameLbl.text = bp.stellarName
        kindBadge.text = "  \(bp.bonusKind.stellarTitle)  "
        kindBadge.backgroundColor = accentColor

        useBtn.setTitleColor(accentColor, for: .normal)
        useBtn.backgroundColor = accentColor.withAlphaComponent(0.10)
        useBtn.layer.borderColor = accentColor.withAlphaComponent(0.3).cgColor
        useBtn.layer.borderWidth = 1

        // Build stat rows from config
        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (label, value) in statRows(for: bp) {
            let row = buildStatRow(label: label, value: value, color: accentColor)
            statsStack.addArrangedSubview(row)
        }
    }

    private func statRows(for bp: NexusBlueprint) -> [(String, String)] {
        switch bp.bonusKind {
        case .pickGame:
            return [("Cards", "\(bp.pickConfig.cardCount)"), ("Picks", "\(bp.pickConfig.pickCount)")]
        case .wheelGame:
            return [("Segments", "\(bp.wheelConfig.segments.count)"),
                    ("Max Win", "\(String(format: "%.0f", bp.wheelConfig.segments.map(\.rewardMultiplier).max() ?? 0))×")]
        case .freeSpins:
            return [("Spins", "\(bp.spinsConfig.spinCount)"),
                    ("Mult", "\(String(format: "%.1f", bp.spinsConfig.baseMultiplier))×")]
        case .cascade:
            return [("Grid", "\(bp.cascadeConfig.cols)×\(bp.cascadeConfig.rows)"),
                    ("Max Cas.", "\(bp.cascadeConfig.maxCascades)")]
        case .expandingWilds:
            return [("Reels", "\(bp.expandingWildsConfig.reelCount)"),
                    ("Wild", "\(Int(bp.expandingWildsConfig.wildChance * 100))%")]
        case .bonusBuy:
            return [("Cost", "\(String(format: "%.0f", bp.bonusBuyConfig.buyCostMultiplier))×"),
                    ("RTP", "\(String(format: "%.0f", bp.bonusBuyConfig.bonusTriggerRTP))%")]
        }
    }

    private func buildStatRow(label: String, value: String, color: UIColor) -> UIView {
        let lbl = UILabel()
        lbl.text = label
        lbl.font = LumosTheme.Typeface.body(11)
        lbl.textColor = LumosTheme.Pigment.textMuted

        let val = UILabel()
        val.text = value
        val.font = LumosTheme.Typeface.mono(11)
        val.textColor = color
        val.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [lbl, UIView(), val])
        row.axis = .horizontal
        return row
    }

    @objc private func tapUse() {
        guard let bp = blueprint else { return }
        // Walk up responder chain to find nav controller
        var responder: UIResponder? = self
        while let r = responder {
            if let nav = r as? UINavigationController {
                let homeVC = ZenithHomeViewController()
                homeVC.loadBlueprint(bp)
                nav.pushViewController(homeVC, animated: true)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                return
            }
            responder = r.next
        }
    }
}

// MARK: - Preset Detail

final class PresetDetailViewController: UIViewController {

    private let blueprint: NexusBlueprint
    private let accent: UIColor

    init(blueprint: NexusBlueprint, accentColor: UIColor) {
        self.blueprint = blueprint
        self.accent = accentColor
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = blueprint.stellarName
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

        // Hero card
        let heroCard = buildHeroCard()
        stack.addArrangedSubview(heroCard)

        // Params section
        stack.addArrangedSubview(LumosSectionHeader(title: "Parameters", accentColor: accent))
        let paramsCard = buildParamsCard()
        stack.addArrangedSubview(paramsCard)

        // Description
        stack.addArrangedSubview(LumosSectionHeader(title: "About this Preset", accentColor: LumosTheme.Pigment.textSecondary))
        let descCard = buildDescCard()
        stack.addArrangedSubview(descCard)

        // CTA
        let useBtn = NebulaCTAButton()
        useBtn.setTitle("Open in Editor", for: .normal)
        useBtn.configureGradient(colors: [accent, accent.withAlphaComponent(0.7)])
        useBtn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        useBtn.addTarget(self, action: #selector(tapOpen), for: .touchUpInside)
        stack.addArrangedSubview(useBtn)
    }

    private func buildHeroCard() -> UIView {
        let card = LumosCardView()

        let gradLayer = CAGradientLayer()
        gradLayer.colors = [accent.withAlphaComponent(0.18).cgColor, UIColor.clear.cgColor]
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint = CGPoint(x: 1, y: 1)
        card.layer.insertSublayer(gradLayer, at: 0)
        DispatchQueue.main.async { gradLayer.frame = card.bounds }

        let iconView = UIImageView(image: UIImage(systemName: blueprint.bonusKind.stellarIcon))
        iconView.tintColor = accent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let nameLbl = UILabel()
        nameLbl.text = blueprint.stellarName
        nameLbl.font = LumosTheme.Typeface.headline(22)
        nameLbl.textColor = LumosTheme.Pigment.textPrimary
        nameLbl.numberOfLines = 2

        let kindLbl = UILabel()
        kindLbl.text = blueprint.bonusKind.stellarTitle
        kindLbl.font = LumosTheme.Typeface.body(14)
        kindLbl.textColor = accent

        let textStack = UIStackView(arrangedSubviews: [nameLbl, kindLbl])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func buildParamsCard() -> UIView {
        let card = LumosCardView()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        for (label, value) in detailedParams() {
            let sep = UIView()
            sep.backgroundColor = LumosTheme.Pigment.borderGlow
            sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
            if !inner.arrangedSubviews.isEmpty { inner.addArrangedSubview(sep) }

            let lbl = UILabel(); lbl.text = label; lbl.font = LumosTheme.Typeface.body(14); lbl.textColor = LumosTheme.Pigment.textSecondary
            let val = UILabel(); val.text = value; val.font = LumosTheme.Typeface.mono(14); val.textColor = accent; val.textAlignment = .right
            let row = UIStackView(arrangedSubviews: [lbl, UIView(), val])
            row.axis = .horizontal
            inner.addArrangedSubview(row)
        }
        return card
    }

    private func buildDescCard() -> UIView {
        let card = LumosCardView()
        let lbl = UILabel()
        lbl.text = description(for: blueprint)
        lbl.font = LumosTheme.Typeface.body(14)
        lbl.textColor = LumosTheme.Pigment.textSecondary
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func detailedParams() -> [(String, String)] {
        switch blueprint.bonusKind {
        case .pickGame:
            let c = blueprint.pickConfig
            return [("Card Count", "\(c.cardCount)"), ("Pick Count", "\(c.pickCount)"),
                    ("Reward Tiers", c.rewardTiers.map { String(format: "%.0f×", $0) }.joined(separator: "  "))]
        case .wheelGame:
            let c = blueprint.wheelConfig
            let maxWin = c.segments.map(\.rewardMultiplier).max() ?? 0
            return [("Segments", "\(c.segments.count)"), ("Max Win", String(format: "%.0f×", maxWin)),
                    ("Total Weight", String(format: "%.0f", c.totalWeight))]
        case .freeSpins:
            let c = blueprint.spinsConfig
            return [("Spin Count", "\(c.spinCount)"), ("Base Multiplier", String(format: "%.1f×", c.baseMultiplier)),
                    ("Retrigger Chance", String(format: "%.0f%%", c.retriggerChance * 100)),
                    ("Reward Range", String(format: "%.1f – %.1f×", c.minSpinReward, c.maxSpinReward))]
        case .cascade:
            let c = blueprint.cascadeConfig
            return [("Grid", "\(c.cols)×\(c.rows)"), ("Symbol Types", "\(c.symbolCount)"),
                    ("Min Match", "\(c.minMatch)"), ("Base Multiplier", String(format: "%.1f×", c.baseMultiplier)),
                    ("Cascade Step", String(format: "+%.1f×", c.cascadeMultiplierStep)),
                    ("Max Cascades", "\(c.maxCascades)")]
        case .expandingWilds:
            let c = blueprint.expandingWildsConfig
            return [("Reels", "\(c.reelCount)"), ("Wild Chance", String(format: "%.0f%%", c.wildChance * 100)),
                    ("Expand Chance", String(format: "%.0f%%", c.expandChance * 100)),
                    ("Wild Multiplier", String(format: "%.1f×", c.wildMultiplier)),
                    ("Base Reward", String(format: "%.1f×", c.baseSpinReward))]
        case .bonusBuy:
            let c = blueprint.bonusBuyConfig
            return [("Buy Cost", String(format: "%.0f× bet", c.buyCostMultiplier)),
                    ("Bonus RTP", String(format: "%.0f%%", c.bonusTriggerRTP)),
                    ("Base Game RTP", String(format: "%.1f%%", c.baseGameRTP)),
                    ("Variance", String(format: "%.2f", c.variance))]
        }
    }

    private func description(for bp: NexusBlueprint) -> String {
        switch bp.bonusKind {
        case .pickGame:       return "A classic pick-and-reveal bonus where players choose cards from a grid. Higher card counts with fewer picks increase volatility. Good starting point for casual bonus designs."
        case .wheelGame:      return "A spinning wheel bonus with configurable segments and weights. Jackpot-style configs concentrate weight on low rewards with rare huge wins. Even distribution suits low-variance designs."
        case .freeSpins:      return "A free spins round with a base multiplier applied to every spin reward. Retrigger chance can dramatically increase expected value and session length."
        case .cascade:        return "A cascade (avalanche) mechanic where winning symbols are removed and new ones fall in. Each cascade wave increases the multiplier, rewarding chain reactions."
        case .expandingWilds: return "Wild symbols can appear on any reel and potentially expand to cover the entire reel, multiplying the payout for that spin significantly."
        case .bonusBuy:       return "Simulate a direct bonus-buy feature. Players pay a fixed multiple of their bet to immediately trigger the bonus round, bypassing base-game variance."
        }
    }

    @objc private func tapOpen() {
        let homeVC = ZenithHomeViewController()
        homeVC.loadBlueprint(blueprint)
        navigationController?.pushViewController(homeVC, animated: true)
    }
}
