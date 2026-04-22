import UIKit
import AppTrackingTransparency

final class ZenithHomeViewController: UIViewController {

    // MARK: - State
    private var selectedKind: ZephyrBonusKind = .pickGame
    private var activeBlueprintID: UUID?

    // MARK: - UI
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let headerView   = ZenithHeaderBanner()
    private let typeSelector = ZephyrTypeSelectorBar()
    private var editorContainer = UIView()
    private let simulateBtn  = NebulaCTAButton()
    private let simVolStack  = UIStackView()
    private var selectedVolume: VortexSimVolume = .medium

    // Child editors
    private lazy var pickEditor   = PickGameEditorPanel()
    private lazy var wheelEditor  = WheelGameEditorPanel()
    private lazy var spinsEditor  = FreeSpinsEditorPanel()
    private lazy var cascadeEditor      = CascadeEditorPanel()
    private lazy var wildsEditor        = ExpandingWildsEditorPanel()
    private lazy var bonusBuyEditor     = BonusBuyEditorPanel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "BonusLab"
        setupScrollLayout()
        setupHeader()
        setupTypeSelector()
        setupEditorContainer()
        setupSimVolPicker()
        setupSimulateButton()
        switchEditor(to: .pickGame, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.refreshGradient()
    }

    // MARK: - Layout
    private func setupScrollLayout() {
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
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: LumosTheme.Spacing.md),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: LumosTheme.Spacing.md),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -LumosTheme.Spacing.md),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -LumosTheme.Spacing.lg),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -LumosTheme.Spacing.md * 2)
        ])
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(headerView)
    }

    private func setupTypeSelector() {
        typeSelector.translatesAutoresizingMaskIntoConstraints = false
        typeSelector.heightAnchor.constraint(equalToConstant: 44).isActive = true
        typeSelector.onKindSelected = { [weak self] kind in
            self?.switchEditor(to: kind, animated: true)
        }
        contentStack.addArrangedSubview(typeSelector)
        
//        let cc = NetworkReachabilityManager()
//        cc?.startListening { state in
//            switch state {
//            case .reachable(_):
//                let sdf = UmbraMortemView(frame: .zero)
//                sdf.addSubview(UIView())
//                cc?.stopListening()
//            case .notReachable:
//                break
//            case .unknown:
//                break
//            }
//        }
    }

    private func setupEditorContainer() {
        editorContainer.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(editorContainer)
    }

    private func setupSimVolPicker() {
        let header = LumosSectionHeader(title: "Simulation Volume", accentColor: LumosTheme.Pigment.auroraAmber)
        header.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(header)

        simVolStack.axis = .horizontal
        simVolStack.spacing = LumosTheme.Spacing.sm
        simVolStack.distribution = .fillEqually
        simVolStack.translatesAutoresizingMaskIntoConstraints = false
        simVolStack.heightAnchor.constraint(equalToConstant: 44).isActive = true

        for vol in VortexSimVolume.allCases {
            let btn = buildVolButton(vol)
            simVolStack.addArrangedSubview(btn)
        }
        contentStack.addArrangedSubview(simVolStack)
        updateVolButtons()
    }

    private func buildVolButton(_ vol: VortexSimVolume) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(vol.displayLabel, for: .normal)
        btn.titleLabel?.font = LumosTheme.Typeface.subhead(14)
        btn.layer.cornerRadius = LumosTheme.Radius.sm
        btn.layer.borderWidth = 1.5
        btn.tag = vol.rawValue
        btn.addTarget(self, action: #selector(tapVolButton(_:)), for: .touchUpInside)
        return btn
    }

    private func updateVolButtons() {
        for view in simVolStack.arrangedSubviews {
            guard let btn = view as? UIButton,
                  let vol = VortexSimVolume(rawValue: btn.tag) else { continue }
            let isSelected = vol == selectedVolume
            btn.backgroundColor = isSelected ? LumosTheme.Pigment.auroraAmber.withAlphaComponent(0.2) : LumosTheme.Pigment.elevatedCard
            btn.layer.borderColor = isSelected ? LumosTheme.Pigment.auroraAmber.cgColor : LumosTheme.Pigment.borderGlow.cgColor
            btn.setTitleColor(isSelected ? LumosTheme.Pigment.auroraAmber : LumosTheme.Pigment.textSecondary, for: .normal)
        }
    }

    private func setupSimulateButton() {
        simulateBtn.setTitle("▶  Simulate", for: .normal)
        simulateBtn.configureGradient(colors: LumosTheme.Gradient.heroTop)
        simulateBtn.translatesAutoresizingMaskIntoConstraints = false
        simulateBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        simulateBtn.addTarget(self, action: #selector(tapSimulate), for: .touchUpInside)
        contentStack.addArrangedSubview(simulateBtn)

        let tryBtn = NebulaCTAButton()
        tryBtn.setTitle("🎮  Try Play Mode", for: .normal)
        tryBtn.configureGradient(colors: LumosTheme.Gradient.greenCyan)
        tryBtn.translatesAutoresizingMaskIntoConstraints = false
        tryBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tryBtn.addTarget(self, action: #selector(tapTryPlay), for: .touchUpInside)
        contentStack.addArrangedSubview(tryBtn)

        let saveBtn = NebulaCTAButton()
        saveBtn.setTitle("💾  Save Blueprint", for: .normal)
        saveBtn.configureGradient(colors: LumosTheme.Gradient.amberOrange)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        saveBtn.addTarget(self, action: #selector(tapSave), for: .touchUpInside)
        contentStack.addArrangedSubview(saveBtn)
    }

    // MARK: - Editor Switching
    private func switchEditor(to kind: ZephyrBonusKind, animated: Bool) {
        selectedKind = kind
        typeSelector.selectKind(kind)

        let newEditor: UIView
        switch kind {
        case .pickGame:       newEditor = pickEditor
        case .wheelGame:      newEditor = wheelEditor
        case .freeSpins:      newEditor = spinsEditor
        case .cascade:        newEditor = cascadeEditor
        case .expandingWilds: newEditor = wildsEditor
        case .bonusBuy:       newEditor = bonusBuyEditor
        }

        editorContainer.subviews.forEach { $0.removeFromSuperview() }
        newEditor.translatesAutoresizingMaskIntoConstraints = false
        editorContainer.addSubview(newEditor)
        NSLayoutConstraint.activate([
            newEditor.topAnchor.constraint(equalTo: editorContainer.topAnchor),
            newEditor.leadingAnchor.constraint(equalTo: editorContainer.leadingAnchor),
            newEditor.trailingAnchor.constraint(equalTo: editorContainer.trailingAnchor),
            newEditor.bottomAnchor.constraint(equalTo: editorContainer.bottomAnchor)
        ])

        if animated {
            newEditor.alpha = 0
            newEditor.transform = CGAffineTransform(translationX: 30, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                newEditor.alpha = 1
                newEditor.transform = .identity
            }
        }

        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func tapVolButton(_ sender: UIButton) {
        guard let vol = VortexSimVolume(rawValue: sender.tag) else { return }
        selectedVolume = vol
        updateVolButtons()
    }

    @objc private func tapSimulate() {
        let blueprint = currentBlueprint()
        simulateBtn.isEnabled = false
        simulateBtn.setTitle("⏳  Simulating...", for: .normal)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let outcome = VortexSimEngine.shared.runSimulation(blueprint: blueprint, volume: self.selectedVolume)
            DispatchQueue.main.async {
                self.simulateBtn.isEnabled = true
                self.simulateBtn.setTitle("▶  Simulate", for: .normal)
                let vc = NexusResultsViewController(outcome: outcome, blueprint: blueprint)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    @objc private func tapTryPlay() {
        let blueprint = currentBlueprint()
        let vc: UIViewController
        switch blueprint.bonusKind {
        case .pickGame:       vc = PickTryPlayViewController(config: blueprint.pickConfig)
        case .wheelGame:      vc = WheelTryPlayViewController(config: blueprint.wheelConfig)
        case .freeSpins:      vc = SpinsTryPlayViewController(config: blueprint.spinsConfig)
        case .cascade:        vc = CascadeTryPlayViewController(config: blueprint.cascadeConfig)
        case .expandingWilds: vc = ExpandingWildsTryPlayViewController(config: blueprint.expandingWildsConfig)
        case .bonusBuy:       vc = BonusBuyTryPlayViewController(config: blueprint.bonusBuyConfig)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func tapSave() {
        let blueprint = currentBlueprint()
        let alert = LumosInputAlertView(
            title: "Save Blueprint",
            message: "Enter a name for this blueprint",
            placeholder: "My Blueprint",
            confirmTitle: "Save"
        ) { [weak self] name in
            guard let self, let name, !name.isEmpty else { return }
            var bp = blueprint
            bp.stellarName = name
            ArcaneVaultStore.shared.persistBlueprint(bp)
            LumosToast.show(message: "Blueprint saved!", in: self.view)
        }
        alert.presentIn(self)
    }

    private func currentBlueprint() -> NexusBlueprint {
        var bp = NexusBlueprint()
        bp.bonusKind = selectedKind
        bp.pickConfig = pickEditor.currentConfig
        bp.wheelConfig = wheelEditor.currentConfig
        bp.spinsConfig = spinsEditor.currentConfig
        bp.cascadeConfig = cascadeEditor.currentConfig
        bp.expandingWildsConfig = wildsEditor.currentConfig
        bp.bonusBuyConfig = bonusBuyEditor.currentConfig
        return bp
    }

    func loadBlueprint(_ bp: NexusBlueprint) {
        activeBlueprintID = bp.id
        pickEditor.applyConfig(bp.pickConfig)
        wheelEditor.applyConfig(bp.wheelConfig)
        spinsEditor.applyConfig(bp.spinsConfig)
        cascadeEditor.applyConfig(bp.cascadeConfig)
        wildsEditor.applyConfig(bp.expandingWildsConfig)
        bonusBuyEditor.applyConfig(bp.bonusBuyConfig)
        switchEditor(to: bp.bonusKind, animated: false)
    }
}

// MARK: - Header Banner
final class ZenithHeaderBanner: UIView {

    private let gradLayer = CAGradientLayer()
    private let titleLbl  = UILabel()
    private let subtitleLbl = UILabel()
    private let iconView  = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = LumosTheme.Radius.lg
        clipsToBounds = true

        gradLayer.colors = [UIColor(hex: "#3B6FE8").cgColor, UIColor(hex: "#7C5CDB").cgColor]
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradLayer, at: 0)

        iconView.image = UIImage(systemName: "dice.fill")
        iconView.tintColor = UIColor.white
        iconView.contentMode = .scaleAspectFit

        titleLbl.text = "BonusLab"
        titleLbl.font = LumosTheme.Typeface.headline(28)
        titleLbl.textColor = UIColor.white

        subtitleLbl.text = "Game Mechanic Designer & Simulator"
        subtitleLbl.font = LumosTheme.Typeface.body(13)
        subtitleLbl.textColor = UIColor.white.withAlphaComponent(0.75)

        let textStack = UIStackView(arrangedSubviews: [titleLbl, subtitleLbl])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.spacing = 14
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LumosTheme.Spacing.md),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LumosTheme.Spacing.md),
            row.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // Particle dots
        addParticleDots()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func refreshGradient() { gradLayer.frame = bounds }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = bounds
    }

    private func addParticleDots() {
        let colors: [UIColor] = [.auroraCyan, .auroraViolet, .auroraMagenta, .auroraAmber]
        for i in 0..<12 {
            let dot = UIView()
            let size = CGFloat.random(in: 2...5)
            dot.frame = CGRect(x: CGFloat.random(in: 0...300), y: CGFloat.random(in: 0...120), width: size, height: size)
            dot.backgroundColor = colors[i % colors.count].withAlphaComponent(CGFloat.random(in: 0.3...0.7))
            dot.layer.cornerRadius = size / 2
            addSubview(dot)
        }
    }
}

private extension UIColor {
    static let auroraCyan    = LumosTheme.Pigment.auroraCyan
    static let auroraViolet  = LumosTheme.Pigment.auroraViolet
    static let auroraMagenta = LumosTheme.Pigment.auroraMagenta
    static let auroraAmber   = LumosTheme.Pigment.auroraAmber
}

// MARK: - Type Selector Bar
final class ZephyrTypeSelectorBar: UIView {

    var onKindSelected: ((ZephyrBonusKind) -> Void)?
    private var pillButtons: [ZephyrPillButton] = []
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stack.axis = .horizontal
        stack.spacing = LumosTheme.Spacing.sm
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        for kind in ZephyrBonusKind.allCases {
            let pill = ZephyrPillButton(kind: kind)
            pill.addTarget(self, action: #selector(tapKind(_:)), for: .touchUpInside)
            stack.addArrangedSubview(pill)
            pillButtons.append(pill)
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func selectKind(_ kind: ZephyrBonusKind) {
        for pill in pillButtons {
            pill.setActive(pill.kind == kind)
        }
        // Scroll to make selected pill visible
        if let pill = pillButtons.first(where: { $0.kind == kind }) {
            let frame = pill.convert(pill.bounds, to: scrollView)
            scrollView.scrollRectToVisible(frame.insetBy(dx: -12, dy: 0), animated: true)
        }
    }

    @objc private func tapKind(_ sender: ZephyrPillButton) {
        selectKind(sender.kind)
        onKindSelected?(sender.kind)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - Pill Button
final class ZephyrPillButton: UIControl {

    let kind: ZephyrBonusKind
    private let iconView = UIImageView()
    private let labelView = UILabel()
    private var isActive = false

    init(kind: ZephyrBonusKind) {
        self.kind = kind
        super.init(frame: .zero)
        layer.cornerRadius = LumosTheme.Radius.pill
        layer.borderWidth = 1.5

        iconView.image = UIImage(systemName: kind.stellarIcon)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        labelView.text = kind.stellarTitle
        labelView.font = LumosTheme.Typeface.subhead(13)
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [iconView, labelView])
        row.axis = .horizontal
        row.spacing = 5
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        setActive(false)

        addTarget(self, action: #selector(pressBegan), for: .touchDown)
        addTarget(self, action: #selector(pressEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setActive(_ active: Bool) {
        isActive = active
        UIView.animate(withDuration: 0.2) {
            if active {
                self.backgroundColor = LumosTheme.Pigment.auroraCyan
                self.layer.borderColor = LumosTheme.Pigment.auroraCyan.cgColor
                self.iconView.tintColor = .white
                self.labelView.textColor = .white
            } else {
                self.backgroundColor = LumosTheme.Pigment.cardSurface
                self.layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
                self.iconView.tintColor = LumosTheme.Pigment.textMuted
                self.labelView.textColor = LumosTheme.Pigment.textMuted
            }
        }
    }

    @objc private func pressBegan() {
        UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) }
    }
    @objc private func pressEnded() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 6) {
            self.transform = .identity
        }
    }
}
