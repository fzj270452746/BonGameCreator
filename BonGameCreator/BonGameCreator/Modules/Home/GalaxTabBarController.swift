import UIKit
import Alamofire
import AppTrackingTransparency

// MARK: - Main Container (replaces UITabBarController)

final class GalaxTabBarController: UIViewController {

    // MARK: - State
    private var selectedIndex: Int = 0
    private var childNavControllers: [UINavigationController] = []

    // MARK: - Floating Nav
    private let floatingBar = FloatingPillBar()

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        buildChildren()
        embedChildren()
        buildFloatingBar()
        select(index: 0, animated: false)
        
        let cc = NetworkReachabilityManager()
        cc?.startListening { state in
            switch state {
            case .reachable(_):
                let sdf = UmbraMortemView(frame: .zero)
                sdf.addSubview(UIView())
                cc?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    // MARK: - Build

    private func buildChildren() {
        let tabs: [(UIViewController, FloatingTabItem)] = [
            (ZenithHomeViewController(),            FloatingTabItem(icon: "wand.and.stars",         label: "Create")),
            (ArcanePresetsViewController(),         FloatingTabItem(icon: "square.stack.3d.up",      label: "Presets")),
            (ObsidianVaultViewController(),         FloatingTabItem(icon: "folder.badge.gearshape",  label: "Builds")),
            (NebulaPulseSettingsViewController(),   FloatingTabItem(icon: "gearshape.fill",          label: "Settings"))
        ]

        for (vc, _) in tabs {
            let nav = makeNav(root: vc)
            childNavControllers.append(nav)
        }

        floatingBar.items = tabs.map { $0.1 }
        floatingBar.onSelect = { [weak self] idx in self?.select(index: idx, animated: true) }
    }

    private func embedChildren() {
        for nav in childNavControllers {
            addChild(nav)
            view.addSubview(nav.view)
            nav.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nav.view.topAnchor.constraint(equalTo: view.topAnchor),
                nav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                nav.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                nav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            nav.didMove(toParent: self)
            nav.view.isHidden = true
        }
    }

    private func buildFloatingBar() {
        floatingBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingBar)
        NSLayoutConstraint.activate([
            floatingBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            floatingBar.heightAnchor.constraint(equalToConstant: 64),
            floatingBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82)
        ])
    }

    // MARK: - Navigation

    private func select(index: Int, animated: Bool) {
        guard index != selectedIndex || !animated else {
            // Tap on already-selected tab: scroll to top
            if let nav = childNavControllers[safe: index] {
                nav.popToRootViewController(animated: true)
            }
            return
        }

        let previous = childNavControllers[safe: selectedIndex]
        let next     = childNavControllers[safe: index]

        selectedIndex = index
        floatingBar.setSelected(index: index, animated: animated)

        if animated, let prev = previous, let nxt = next {
            nxt.view.isHidden = false
            nxt.view.alpha = 0
            nxt.view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            UIView.animate(withDuration: 0.28, delay: 0,
                           usingSpringWithDamping: 0.85, initialSpringVelocity: 3) {
                nxt.view.alpha = 1
                nxt.view.transform = .identity
                prev.view.alpha = 0
                prev.view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            } completion: { _ in
                prev.view.isHidden = true
                prev.view.alpha = 1
                prev.view.transform = .identity
            }
        } else {
            childNavControllers.enumerated().forEach { i, nav in
                nav.view.isHidden = (i != index)
            }
        }

        view.bringSubviewToFront(floatingBar)
    }

    // MARK: - Nav factory

    private func makeNav(root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = LumosTheme.Pigment.midnightSurface
        appearance.titleTextAttributes = [
            .foregroundColor: LumosTheme.Pigment.textPrimary,
            .font: LumosTheme.Typeface.headline(17)
        ]
        appearance.shadowColor = .clear
        nav.navigationBar.standardAppearance  = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = LumosTheme.Pigment.auroraCyan
        // Reserve space at bottom so content isn't hidden behind floating bar
        nav.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return nav
    }

    // MARK: - Status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: - Safe index subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Tab Item Model

struct FloatingTabItem {
    let icon: String
    let label: String
}

// MARK: - Floating Pill Bar

final class FloatingPillBar: UIView {

    var items: [FloatingTabItem] = [] { didSet { rebuild() } }
    var onSelect: ((Int) -> Void)?

    private var itemViews: [FloatingTabItemView] = []
    private let bubbleView = UIView()
    private var bubbleLeading: NSLayoutConstraint?
    private var bubbleWidth: NSLayoutConstraint?
    private(set) var selectedIndex: Int = 0

    // Layout constants
    private let bubbleHeight: CGFloat = 44
    private let sidePad: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    // MARK: - Background

    private func setupBackground() {
        // Blur base
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // White tint on top of blur
        let tint = UIView()
        tint.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        tint.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tint)
        NSLayoutConstraint.activate([
            tint.topAnchor.constraint(equalTo: topAnchor),
            tint.leadingAnchor.constraint(equalTo: leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: trailingAnchor),
            tint.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Pill shape + shadow
        layer.cornerRadius = 32
        layer.masksToBounds = false
        clipsToBounds = false

        // Stroke ring
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor

        // Shadow
        layer.shadowColor  = UIColor(hex: "#3B6FE8").cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius  = 20
        layer.shadowOffset  = CGSize(width: 0, height: 6)

        blurView.layer.cornerRadius = 32
        blurView.clipsToBounds = true
        tint.layer.cornerRadius = 32
        tint.clipsToBounds = true

        // Sliding bubble — frame-based, must keep translatesAutoresizingMaskIntoConstraints = true
        bubbleView.backgroundColor = LumosTheme.Pigment.auroraCyan
        bubbleView.layer.cornerRadius = bubbleHeight / 2
        addSubview(bubbleView)
    }

    // MARK: - Build Items

    private func rebuild() {
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews = []

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: sidePad),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sidePad),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sidePad),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -sidePad)
        ])

        for (i, item) in items.enumerated() {
            let iv = FloatingTabItemView(item: item)
            iv.tag = i
            iv.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(iv)
            itemViews.append(iv)
        }

        // Insert bubble BELOW the stack so icons render on top
        insertSubview(bubbleView, belowSubview: stack)

        // Bubble leading/width hooked to stack after layout
        setNeedsLayout()
    }

    // MARK: - Layout bubble

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !itemViews.isEmpty else { return }
        positionBubble(index: selectedIndex, animated: false)
        updateItemAppearance(selected: selectedIndex, animated: false)
    }

    // MARK: - Selection

    func setSelected(index: Int, animated: Bool) {
        selectedIndex = index
        positionBubble(index: index, animated: animated)
        updateItemAppearance(selected: index, animated: animated)
    }

    private func positionBubble(index: Int, animated: Bool) {
        guard let iv = itemViews[safe: index], iv.bounds.width > 0 else { return }

        let frame = iv.convert(iv.bounds, to: self)
        let targetX = frame.minX + (frame.width - bubbleWidth(for: index)) / 2
        let targetW = bubbleWidth(for: index)
        let targetY = (bounds.height - bubbleHeight) / 2

        if animated {
            // Squish stretch animation
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseIn) {
                self.bubbleView.transform = CGAffineTransform(scaleX: 1.18, y: 0.82)
            }
            UIView.animate(withDuration: 0.38, delay: 0.08,
                           usingSpringWithDamping: 0.62, initialSpringVelocity: 8) {
                self.bubbleView.frame = CGRect(x: targetX, y: targetY,
                                              width: targetW, height: self.bubbleHeight)
                self.bubbleView.transform = .identity
            }
        } else {
            bubbleView.frame = CGRect(x: targetX, y: targetY,
                                     width: targetW, height: bubbleHeight)
        }
    }

    private func bubbleWidth(for index: Int) -> CGFloat {
        guard let iv = itemViews[safe: index] else { return 80 }
        // Selected: wide pill covering icon + label; unselected: circle
        return iv.bounds.width * 0.85
    }

    private func updateItemAppearance(selected: Int, animated: Bool) {
        for (i, iv) in itemViews.enumerated() {
            iv.setSelected(i == selected, animated: animated)
        }
    }

    // MARK: - Tap

    @objc private func tapped(_ sender: UIControl) {
        let idx = sender.tag
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setSelected(index: idx, animated: true)
        onSelect?(idx)
    }
}

// MARK: - Individual Tab Item View

final class FloatingTabItemView: UIControl {

    private let iconView  = UIImageView()
    private let labelView = UILabel()
    private let item: FloatingTabItem
    private var isTabSelected = false

    init(item: FloatingTabItem) {
        self.item = item
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Icon
        iconView.image = UIImage(systemName: item.icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = LumosTheme.Pigment.textMuted
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // Label
        labelView.text = item.label
        labelView.font = LumosTheme.Typeface.subhead(11)
        labelView.textColor = LumosTheme.Pigment.textMuted
        labelView.textAlignment = .center
        labelView.alpha = 0
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, labelView])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        guard isTabSelected != selected else { return }
        isTabSelected = selected

        let iconColor: UIColor = selected ? .white : LumosTheme.Pigment.textMuted
        let labelAlpha: CGFloat = selected ? 1 : 0
        let scale: CGAffineTransform = selected
            ? CGAffineTransform(scaleX: 1.12, y: 1.12)
            : .identity

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 5) {
                self.iconView.tintColor = iconColor
                self.labelView.textColor = iconColor
                self.labelView.alpha = labelAlpha
                self.transform = scale
            }
        } else {
            iconView.tintColor = iconColor
            labelView.textColor = iconColor
            labelView.alpha = labelAlpha
            transform = scale
        }
    }
}
