import UIKit

final class ObsidianVaultViewController: UIViewController {

    private var blueprints: [NexusBlueprint] = []
    private let tableView  = UITableView(frame: .zero, style: .plain)
    private let emptyView  = VaultEmptyStateView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "My Builds"
        setupTable()
        setupEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func reloadData() {
        blueprints = ArcaneVaultStore.shared.fetchAllBlueprints()
        tableView.reloadData()
        emptyView.isHidden = !blueprints.isEmpty
        tableView.isHidden = blueprints.isEmpty
    }

    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle  = .none
        tableView.register(VaultBlueprintCell.self, forCellReuseIdentifier: VaultBlueprintCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LumosTheme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LumosTheme.Spacing.md),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.md),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupEmptyView() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

extension ObsidianVaultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { blueprints.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VaultBlueprintCell.reuseID, for: indexPath) as! VaultBlueprintCell
        cell.configure(with: blueprints[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 96 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bp = blueprints[indexPath.row]
        let alert = LumosConfirmAlertView(
            title: "Load Blueprint",
            message: "Open \"\(bp.stellarName)\" in the editor?",
            confirmTitle: "Open"
        ) { [weak self] in
            guard let self else { return }
            let homeVC = ZenithHomeViewController()
            homeVC.loadBlueprint(bp)
            if let tabBar = self.tabBarController {
                tabBar.selectedIndex = 0
                if let nav = tabBar.viewControllers?[0] as? UINavigationController {
                    nav.setViewControllers([homeVC], animated: false)
                }
            }
        }
        alert.presentIn(self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            let bp = self.blueprints[indexPath.row]
            let confirm = LumosConfirmAlertView(
                title: "Delete Blueprint",
                message: "Delete \"\(bp.stellarName)\"? This cannot be undone.",
                confirmTitle: "Delete"
            ) {
                ArcaneVaultStore.shared.obliterateBlueprint(id: bp.id)
                self.reloadData()
                completion(true)
            }
            confirm.presentIn(self)
        }
        deleteAction.backgroundColor = LumosTheme.Pigment.auroraMagenta
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Vault Cell
final class VaultBlueprintCell: UITableViewCell {
    static let reuseID = "VaultBlueprintCell"

    private let card     = LumosCardView()
    private let iconView = UIImageView()
    private let nameLbl  = UILabel()
    private let dateLbl  = UILabel()
    private let kindBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupOrbit()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupOrbit() {
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 38).isActive = true

        nameLbl.font = LumosTheme.Typeface.subhead(15)
        nameLbl.textColor = LumosTheme.Pigment.textPrimary

        dateLbl.font = LumosTheme.Typeface.body(11)
        dateLbl.textColor = LumosTheme.Pigment.textMuted

        kindBadge.font = LumosTheme.Typeface.body(11)
        kindBadge.textColor = LumosTheme.Pigment.obsidianBase
        kindBadge.layer.cornerRadius = 8
        kindBadge.clipsToBounds = true
        kindBadge.textAlignment = .center

        let textStack = UIStackView(arrangedSubviews: [nameLbl, dateLbl])
        textStack.axis = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [iconView, textStack, UIView(), kindBadge])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            kindBadge.widthAnchor.constraint(equalToConstant: 72),
            kindBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    func configure(with bp: NexusBlueprint) {
        nameLbl.text = bp.stellarName
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        dateLbl.text = fmt.string(from: bp.createdAt)
        iconView.image = UIImage(systemName: bp.bonusKind.stellarIcon)

        let (color, title): (UIColor, String)
        switch bp.bonusKind {
        case .pickGame:  (color, title) = (LumosTheme.Pigment.auroraCyan, "Pick")
        case .wheelGame: (color, title) = (LumosTheme.Pigment.auroraViolet, "Wheel")
        case .freeSpins: (color, title) = (LumosTheme.Pigment.auroraGreen, "Spins")
        }
        iconView.tintColor = color
        kindBadge.backgroundColor = color
        kindBadge.text = title
    }
}
