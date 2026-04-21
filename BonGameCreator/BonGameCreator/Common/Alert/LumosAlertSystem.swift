import UIKit

// MARK: - Base Alert
class LumosBaseAlertView: UIView {

    let containerCard = UIView()
    let titleLbl      = UILabel()
    let messageLbl    = UILabel()
    let buttonStack   = UIStackView()
    private weak var hostVC: UIViewController?
    private let dimView = UIView()
    private var retainSelf: LumosBaseAlertView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOrbit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupOrbit() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        dimView.translatesAutoresizingMaskIntoConstraints = false

        containerCard.backgroundColor = LumosTheme.Pigment.cardSurface
        containerCard.layer.cornerRadius = LumosTheme.Radius.xl
        containerCard.layer.borderWidth = 1.5
        containerCard.layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
        containerCard.translatesAutoresizingMaskIntoConstraints = false

        // Gradient top strip
        let strip = UIView()
        strip.translatesAutoresizingMaskIntoConstraints = false
        strip.layer.cornerRadius = LumosTheme.Radius.xl
        strip.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        strip.clipsToBounds = true
        let grad = CAGradientLayer.lumosGradient(colors: LumosTheme.Gradient.heroTop,
                                                  startPoint: CGPoint(x: 0, y: 0.5),
                                                  endPoint: CGPoint(x: 1, y: 0.5))
        grad.frame = CGRect(x: 0, y: 0, width: 400, height: 4)
        strip.layer.addSublayer(grad)
        strip.heightAnchor.constraint(equalToConstant: 4).isActive = true

        titleLbl.font = LumosTheme.Typeface.headline(18)
        titleLbl.textColor = LumosTheme.Pigment.textPrimary
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0

        messageLbl.font = LumosTheme.Typeface.body(14)
        messageLbl.textColor = LumosTheme.Pigment.textSecondary
        messageLbl.textAlignment = .center
        messageLbl.numberOfLines = 0

        buttonStack.axis = .horizontal
        buttonStack.spacing = LumosTheme.Spacing.sm
        buttonStack.distribution = .fillEqually

        let innerStack = UIStackView(arrangedSubviews: [strip, titleLbl, messageLbl, buttonStack])
        innerStack.axis = .vertical
        innerStack.spacing = LumosTheme.Spacing.sm
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        containerCard.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: containerCard.topAnchor),
            innerStack.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: LumosTheme.Spacing.md),
            innerStack.trailingAnchor.constraint(equalTo: containerCard.trailingAnchor, constant: -LumosTheme.Spacing.md),
            innerStack.bottomAnchor.constraint(equalTo: containerCard.bottomAnchor, constant: -LumosTheme.Spacing.md)
        ])
    }

    func presentIn(_ vc: UIViewController) {
        retainSelf = self
        hostVC = vc
        guard let window = vc.view.window ?? vc.view else { return }

        dimView.frame = window.bounds
        window.addSubview(dimView)
        window.addSubview(containerCard)

        containerCard.translatesAutoresizingMaskIntoConstraints = true
        containerCard.frame = CGRect(x: 24, y: window.bounds.midY,
                                     width: window.bounds.width - 48, height: 0)

        containerCard.alpha = 0
        containerCard.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        dimView.alpha = 0

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 6) {
            self.dimView.alpha = 1
            self.containerCard.alpha = 1
            self.containerCard.transform = .identity
            self.containerCard.frame = CGRect(
                x: 24,
                y: window.bounds.midY - 100,
                width: window.bounds.width - 48,
                height: 200
            )
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        dimView.addGestureRecognizer(tap)
    }

    @objc func dismissAlert() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimView.alpha = 0
            self.containerCard.alpha = 0
            self.containerCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.dimView.removeFromSuperview()
            self.containerCard.removeFromSuperview()
            self.retainSelf = nil
        }
    }

    func makeButton(title: String, colors: [UIColor], action: @escaping () -> Void) -> UIButton {
        let btn = NebulaCTAButton()
        btn.setTitle(title, for: .normal)
        btn.configureGradient(colors: colors)
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addAction(UIAction { [weak self] _ in
            self?.dismissAlert()
            action()
        }, for: .touchUpInside)
        return btn
    }
}

// MARK: - Confirm Alert
final class LumosConfirmAlertView: LumosBaseAlertView {

    private let onConfirm: () -> Void

    init(title: String, message: String, confirmTitle: String, onConfirm: @escaping () -> Void) {
        self.onConfirm = onConfirm
        super.init(frame: .zero)
        titleLbl.text   = title
        messageLbl.text = message

        let cancelBtn = makeButton(title: "Cancel", colors: [LumosTheme.Pigment.elevatedCard, LumosTheme.Pigment.cardSurface]) {}
        let confirmBtn = makeButton(title: confirmTitle, colors: LumosTheme.Gradient.heroTop) { [weak self] in
            self?.onConfirm()
        }
        buttonStack.addArrangedSubview(cancelBtn)
        buttonStack.addArrangedSubview(confirmBtn)
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Input Alert
final class LumosInputAlertView: LumosBaseAlertView {

    private let textField   = PaddedTextField()
    private let onConfirm: (String?) -> Void

    init(title: String, message: String, placeholder: String, confirmTitle: String, onConfirm: @escaping (String?) -> Void) {
        self.onConfirm = onConfirm
        super.init(frame: .zero)
        titleLbl.text   = title
        messageLbl.text = message

        textField.placeholder = placeholder
        textField.font = LumosTheme.Typeface.body(15)
        textField.textColor = LumosTheme.Pigment.textPrimary
        textField.backgroundColor = LumosTheme.Pigment.elevatedCard
        textField.layer.cornerRadius = LumosTheme.Radius.sm
        textField.layer.borderWidth = 1
        textField.layer.borderColor = LumosTheme.Pigment.borderGlow.cgColor
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // Insert textField before buttons
        if let idx = containerCard.subviews.first?.subviews.firstIndex(of: buttonStack) {
            _ = idx
        }
        // Add to inner stack via buttonStack's superview
        let fieldWrapper = UIStackView(arrangedSubviews: [textField])
        fieldWrapper.axis = .vertical

        let cancelBtn  = makeButton(title: "Cancel", colors: [LumosTheme.Pigment.elevatedCard, LumosTheme.Pigment.cardSurface]) {}
        let confirmBtn = makeButton(title: confirmTitle, colors: LumosTheme.Gradient.heroTop) { [weak self] in
            self?.onConfirm(self?.textField.text)
        }
        buttonStack.addArrangedSubview(cancelBtn)
        buttonStack.addArrangedSubview(confirmBtn)

        // Manually insert textField row
        if let innerStack = containerCard.subviews.first as? UIStackView {
            let insertIdx = innerStack.arrangedSubviews.count - 1
            innerStack.insertArrangedSubview(textField, at: insertIdx)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
