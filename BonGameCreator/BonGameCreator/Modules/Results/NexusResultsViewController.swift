import UIKit

final class NexusResultsViewController: UIViewController {

    private let outcome: VortexSimOutcome
    private let blueprint: NexusBlueprint

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    init(outcome: VortexSimOutcome, blueprint: NexusBlueprint) {
        self.outcome   = outcome
        self.blueprint = blueprint
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        title = "Simulation Results"
        setupLayout()
        populateStats()
        buildHistogramChart()
        buildTopRewards()
        buildFunScore()
        buildRTPCurve()
        buildOutcomeDistPie()
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

    private func populateStats() {
        let header = LumosSectionHeader(title: "Key Metrics — \(blueprint.bonusKind.stellarTitle)", accentColor: LumosTheme.Pigment.auroraCyan)
        contentStack.addArrangedSubview(header)

        let grid = UIStackView()
        grid.axis = .horizontal
        grid.spacing = LumosTheme.Spacing.sm
        grid.distribution = .fillEqually
        grid.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let evBadge  = OrbitStatBadge()
        let maxBadge = OrbitStatBadge()
        let minBadge = OrbitStatBadge()
        let volBadge = OrbitStatBadge()

        evBadge.configure(title: "Avg EV", value: String(format: "%.2fx", outcome.meanYield), accentColor: LumosTheme.Pigment.auroraCyan)
        maxBadge.configure(title: "Max Win", value: String(format: "%.1fx", outcome.peakYield), accentColor: LumosTheme.Pigment.auroraAmber)
        minBadge.configure(title: "Min Win", value: String(format: "%.1fx", outcome.nadirYield), accentColor: LumosTheme.Pigment.auroraGreen)
        volBadge.configure(title: "Volatility", value: String(format: "%.2f", outcome.volatilityIndex), accentColor: LumosTheme.Pigment.auroraMagenta)

        [evBadge, maxBadge, minBadge, volBadge].forEach { grid.addArrangedSubview($0) }
        contentStack.addArrangedSubview(grid)

        let trialLbl = UILabel()
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        let countStr = fmt.string(from: NSNumber(value: outcome.trialCount)) ?? "\(outcome.trialCount)"
        trialLbl.text = "Trials: \(countStr)"
        trialLbl.font = LumosTheme.Typeface.body(12)
        trialLbl.textColor = LumosTheme.Pigment.textMuted
        trialLbl.textAlignment = .right
        contentStack.addArrangedSubview(trialLbl)
    }

    private func buildHistogramChart() {
        let header = LumosSectionHeader(title: "Reward Distribution", accentColor: LumosTheme.Pigment.auroraViolet)
        contentStack.addArrangedSubview(header)

        let chartCard = LumosCardView()
        chartCard.translatesAutoresizingMaskIntoConstraints = false
        chartCard.heightAnchor.constraint(equalToConstant: 180).isActive = true
        contentStack.addArrangedSubview(chartCard)

        let chart = NexusHistogramView(buckets: outcome.bucketedHistogram)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chartCard.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 12),
            chart.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 12),
            chart.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -12),
            chart.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -12)
        ])
    }

    private func buildTopRewards() {
        guard !outcome.topTenYields.isEmpty else { return }
        let header = LumosSectionHeader(title: "Top 10 Wins", accentColor: LumosTheme.Pigment.auroraAmber)
        contentStack.addArrangedSubview(header)

        let card = LumosCardView()
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 6
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            innerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            innerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            innerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        let maxVal = outcome.topTenYields.first ?? 1
        for (i, val) in outcome.topTenYields.enumerated() {
            let row = buildTopRewardRow(rank: i + 1, value: val, maxValue: maxVal)
            innerStack.addArrangedSubview(row)
        }
        contentStack.addArrangedSubview(card)
    }

    private func buildTopRewardRow(rank: Int, value: Double, maxValue: Double) -> UIView {
        let container = UIView()
        let rankLbl = UILabel()
        rankLbl.text = "#\(rank)"
        rankLbl.font = LumosTheme.Typeface.mono(12)
        rankLbl.textColor = LumosTheme.Pigment.textMuted
        rankLbl.setContentHuggingPriority(.required, for: .horizontal)

        let bar = UIView()
        bar.backgroundColor = LumosTheme.Gradient.wheelSeg[rank % LumosTheme.Gradient.wheelSeg.count].withAlphaComponent(0.7)
        bar.layer.cornerRadius = 3

        let valLbl = UILabel()
        valLbl.text = String(format: "%.2fx", value)
        valLbl.font = LumosTheme.Typeface.mono(13)
        valLbl.textColor = LumosTheme.Pigment.auroraAmber
        valLbl.setContentHuggingPriority(.required, for: .horizontal)

        rankLbl.translatesAutoresizingMaskIntoConstraints = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        valLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(rankLbl)
        container.addSubview(bar)
        container.addSubview(valLbl)

        let proportion = maxValue > 0 ? CGFloat(value / maxValue) : 0
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 22),
            rankLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rankLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rankLbl.widthAnchor.constraint(equalToConstant: 28),
            bar.leadingAnchor.constraint(equalTo: rankLbl.trailingAnchor, constant: 6),
            bar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            bar.heightAnchor.constraint(equalToConstant: 10),
            bar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: proportion * 0.6),
            valLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func buildFunScore() {
        let header = LumosSectionHeader(title: "Fun Score", accentColor: LumosTheme.Pigment.auroraMagenta)
        contentStack.addArrangedSubview(header)

        let card = LumosCardView()
        card.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let scoreView = FunScoreGaugeView(score: outcome.funScoreIndex)
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(scoreView)
        NSLayoutConstraint.activate([
            scoreView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            scoreView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            scoreView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            scoreView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        contentStack.addArrangedSubview(card)
    }

    private func buildRTPCurve() {
        guard outcome.rawSamples.count > 1 else { return }
        let header = LumosSectionHeader(title: "RTP Convergence Curve", accentColor: LumosTheme.Pigment.auroraGreen)
        contentStack.addArrangedSubview(header)

        let card = LumosCardView()
        card.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let chart = NexusLineChartView(samples: outcome.rawSamples, accentColor: LumosTheme.Pigment.auroraGreen)
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            chart.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        contentStack.addArrangedSubview(card)

        let noteLbl = UILabel()
        noteLbl.text = "Running average of \(outcome.rawSamples.count) sampled rounds"
        noteLbl.font = LumosTheme.Typeface.body(11)
        noteLbl.textColor = LumosTheme.Pigment.textMuted
        noteLbl.textAlignment = .right
        contentStack.addArrangedSubview(noteLbl)
    }

    private func buildOutcomeDistPie() {
        guard !outcome.bucketedHistogram.isEmpty else { return }
        let header = LumosSectionHeader(title: "Outcome Distribution", accentColor: LumosTheme.Pigment.auroraOrange)
        contentStack.addArrangedSubview(header)

        let card = LumosCardView()
        card.heightAnchor.constraint(equalToConstant: 160).isActive = true

        let colors = LumosTheme.Gradient.wheelSeg
        let slices = outcome.bucketedHistogram.enumerated().map { i, b in
            NexusPieChartView.Slice(label: b.rangeLabel, value: b.proportion, color: colors[i % colors.count])
        }
        let pie = NexusPieChartView(slices: slices)
        pie.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pie)
        NSLayoutConstraint.activate([
            pie.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            pie.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            pie.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            pie.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        contentStack.addArrangedSubview(card)
    }
}
