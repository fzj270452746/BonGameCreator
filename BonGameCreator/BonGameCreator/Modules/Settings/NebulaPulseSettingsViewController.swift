import UIKit

final class NebulaPulseSettingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    struct SettingsRow {
        let icon: String
        let iconColor: UIColor
        let title: String
        let action: SettingsAction
    }

    enum SettingsAction {
        case openURL(String)
        case sendFeedback
        case showAbout
        case resetOnboarding
    }

    private lazy var rows: [[SettingsRow]] = [
        [
            SettingsRow(icon: "envelope.fill", iconColor: LumosTheme.Pigment.auroraGreen,
                        title: "Send Feedback", action: .sendFeedback),
            SettingsRow(icon: "star.fill", iconColor: LumosTheme.Pigment.auroraAmber,
                        title: "Rate on App Store", action: .openURL("https://apps.apple.com"))
        ],
        [
            SettingsRow(icon: "info.circle.fill", iconColor: LumosTheme.Pigment.textSecondary,
                        title: "About BonusSlotsCreator", action: .showAbout)
//            SettingsRow(icon: "arrow.counterclockwise.circle.fill", iconColor: LumosTheme.Pigment.auroraMagenta,
//                        title: "Replay Intro", action: .resetOnboarding)
        ]
    ]

    private let sectionHeaders = ["Support", "About"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Settings"
        setupTable()
        setupHeader()
    }

    private func setupTable() {
        tableView.backgroundColor = LumosTheme.Pigment.obsidianBase
        tableView.register(SettingsGlyphCell.self, forCellReuseIdentifier: SettingsGlyphCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupHeader() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 130))

        let iconView = UIImageView(image: UIImage(systemName: "dice.fill"))
        iconView.tintColor = LumosTheme.Pigment.auroraCyan
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let nameLbl = UILabel()
        nameLbl.text = "BonusLab"
        nameLbl.font = LumosTheme.Typeface.headline(22)
        nameLbl.textColor = LumosTheme.Pigment.textPrimary
        nameLbl.textAlignment = .center

        let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildStr = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let versionLbl = UILabel()
        versionLbl.text = "Version \(versionStr) (\(buildStr))"
        versionLbl.font = LumosTheme.Typeface.body(12)
        versionLbl.textColor = LumosTheme.Pigment.textMuted
        versionLbl.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, nameLbl, versionLbl])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        tableView.tableHeaderView = container
    }
}

extension NebulaPulseSettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { rows.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows[section].count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sectionHeaders[section] }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 52 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsGlyphCell.reuseID, for: indexPath) as! SettingsGlyphCell
        cell.configure(with: rows[indexPath.section][indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.section][indexPath.row]
        switch row.action {
        case .openURL(let urlStr):
            guard let url = URL(string: urlStr) else { return }
            UIApplication.shared.open(url)
        case .sendFeedback:
            let emailURL = URL(string: "mailto:feedback@bonuslab.app?subject=BonusLab%20Feedback")!
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            } else {
                LumosToast.show(message: "Please email: feedback@bonuslab.app", in: view, duration: 3)
            }
        case .showAbout:
            let alert = UIAlertController(title: "BonusLab", message: "BonusSlotsCreator is a game mechanic designer and simulator for indie game developers, designers, and students.\n\nDesign bonus game configurations, run statistical simulations, and iterate on your ideas — all offline.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .resetOnboarding:
            UserDefaults.standard.set(false, forKey: "lumosOnboardingComplete")
            let onboarding = LumosOnboardingViewController()
            onboarding.modalPresentationStyle = .fullScreen
            present(onboarding, animated: true)
        }
    }
}

// MARK: - Settings Cell
final class SettingsGlyphCell: UITableViewCell {
    static let reuseID = "SettingsGlyphCell"

    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLbl = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = LumosTheme.Pigment.cardSurface

        iconContainer.layer.cornerRadius = 8
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        titleLbl.font = LumosTheme.Typeface.body(15)
        titleLbl.textColor = LumosTheme.Pigment.textPrimary

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = LumosTheme.Pigment.textMuted
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.widthAnchor.constraint(equalToConstant: 14).isActive = true

        let row = UIStackView(arrangedSubviews: [iconContainer, titleLbl, UIView(), arrow])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with row: NebulaPulseSettingsViewController.SettingsRow) {
        iconView.image = UIImage(systemName: row.icon)
        iconView.tintColor = .white
        iconContainer.backgroundColor = row.iconColor
        titleLbl.text = row.title
    }
}
