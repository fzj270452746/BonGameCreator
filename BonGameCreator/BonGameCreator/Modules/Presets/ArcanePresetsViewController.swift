import UIKit

final class ArcanePresetsViewController: UIViewController {

    private var presets: [NexusBlueprint] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Presets"
        presets = ArcaneVaultStore.shared.builtInPresets()
        setupTable()
    }

    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(PresetGlyphCell.self, forCellReuseIdentifier: PresetGlyphCell.reuseID)
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
}

extension ArcanePresetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { presets.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PresetGlyphCell.reuseID, for: indexPath) as! PresetGlyphCell
        cell.configure(with: presets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 88 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bp = presets[indexPath.row]
        let alert = LumosConfirmAlertView(
            title: "Load Preset",
            message: "Open \"\(bp.stellarName)\" in the editor?",
            confirmTitle: "Open"
        ) { [weak self] in
            guard let self else { return }
            let homeVC = ZenithHomeViewController()
            homeVC.loadBlueprint(bp)
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        alert.presentIn(self)
    }
}

// MARK: - Preset Cell
final class PresetGlyphCell: UITableViewCell {
    static let reuseID = "PresetGlyphCell"

    private let card       = LumosCardView()
    private let iconView   = UIImageView()
    private let nameLbl    = UILabel()
    private let kindLbl    = UILabel()
    private let arrowImg   = UIImageView()

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
        iconView.tintColor = LumosTheme.Pigment.auroraViolet
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        nameLbl.font = LumosTheme.Typeface.subhead(15)
        nameLbl.textColor = LumosTheme.Pigment.textPrimary

        kindLbl.font = LumosTheme.Typeface.body(12)
        kindLbl.textColor = LumosTheme.Pigment.textSecondary

        arrowImg.image = UIImage(systemName: "chevron.right")
        arrowImg.tintColor = LumosTheme.Pigment.textMuted
        arrowImg.contentMode = .scaleAspectFit
        arrowImg.translatesAutoresizingMaskIntoConstraints = false
        arrowImg.widthAnchor.constraint(equalToConstant: 16).isActive = true

        let textStack = UIStackView(arrangedSubviews: [nameLbl, kindLbl])
        textStack.axis = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [iconView, textStack, UIView(), arrowImg])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
    }

    func configure(with bp: NexusBlueprint) {
        nameLbl.text = bp.stellarName
        kindLbl.text = bp.bonusKind.stellarTitle
        iconView.image = UIImage(systemName: bp.bonusKind.stellarIcon)
        let colors: [ZephyrBonusKind: UIColor] = [
            .pickGame: LumosTheme.Pigment.auroraCyan,
            .wheelGame: LumosTheme.Pigment.auroraViolet,
            .freeSpins: LumosTheme.Pigment.auroraGreen
        ]
        iconView.tintColor = colors[bp.bonusKind] ?? LumosTheme.Pigment.auroraCyan
    }
}
