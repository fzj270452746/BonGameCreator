import Foundation

final class VortexSimEngine {

    static let shared = VortexSimEngine()
    private init() {}

    // MARK: - Public Entry
    func runSimulation(blueprint: NexusBlueprint, volume: VortexSimVolume) -> VortexSimOutcome {
        var samples: [Double] = []
        samples.reserveCapacity(volume.rawValue)

        for _ in 0..<volume.rawValue {
            switch blueprint.bonusKind {
            case .pickGame:  samples.append(simulateCrystalPick(cfg: blueprint.pickConfig))
            case .wheelGame: samples.append(simulatePrismWheel(cfg: blueprint.wheelConfig))
            case .freeSpins: samples.append(simulateFreeSpinRun(cfg: blueprint.spinsConfig))
            }
        }

        return buildOutcome(samples: samples, count: volume.rawValue)
    }

    // MARK: - Pick Game
    func simulateCrystalPick(cfg: CrystalPickConfig) -> Double {
        var pool = cfg.allRewards
        pool.shuffle()
        let picks = min(cfg.pickCount, pool.count)
        return pool.prefix(picks).reduce(0, +)
    }

    // MARK: - Wheel Game
    func simulatePrismWheel(cfg: CrystalWheelConfig) -> Double {
        let total = cfg.totalWeight
        guard total > 0 else { return 0 }
        let roll = Double.random(in: 0..<total)
        var cumulative = 0.0
        for seg in cfg.segments {
            cumulative += seg.weightFraction
            if roll < cumulative { return seg.rewardMultiplier }
        }
        return cfg.segments.last?.rewardMultiplier ?? 0
    }

    // MARK: - Free Spins
    func simulateFreeSpinRun(cfg: CrystalFreeSpinsConfig) -> Double {
        var remaining = cfg.spinCount
        var total = 0.0
        var guard_ = 0
        while remaining > 0 && guard_ < 10000 {
            guard_ += 1
            remaining -= 1
            let spinVal = Double.random(in: cfg.minSpinReward...cfg.maxSpinReward) * cfg.baseMultiplier
            total += spinVal
            if Double.random(in: 0..<1) < cfg.retriggerChance {
                remaining += Int.random(in: 3...8)
            }
        }
        return total
    }

    // MARK: - Single Play (for try-play mode)
    func singlePickPlay(cfg: CrystalPickConfig) -> [Double] {
        var pool = cfg.allRewards
        pool.shuffle()
        return pool
    }

    func singleWheelSpin(cfg: CrystalWheelConfig) -> (index: Int, reward: Double) {
        let total = cfg.totalWeight
        guard total > 0 else { return (0, 0) }
        let roll = Double.random(in: 0..<total)
        var cumulative = 0.0
        for (i, seg) in cfg.segments.enumerated() {
            cumulative += seg.weightFraction
            if roll < cumulative { return (i, seg.rewardMultiplier) }
        }
        let last = cfg.segments.count - 1
        return (last, cfg.segments[last].rewardMultiplier)
    }

    // MARK: - Outcome Builder
    private func buildOutcome(samples: [Double], count: Int) -> VortexSimOutcome {
        guard !samples.isEmpty else {
            return VortexSimOutcome(trialCount: 0, meanYield: 0, peakYield: 0, nadirYield: 0,
                                   funScoreIndex: 0, bucketedHistogram: [], topTenYields: [], rawSamples: [])
        }
        let sorted = samples.sorted()
        let mean = samples.reduce(0, +) / Double(samples.count)
        let peak = sorted.last ?? 0
        let nadir = sorted.first ?? 0

        let variance = samples.reduce(0.0) { $0 + pow($1 - mean, 2) } / Double(samples.count)
        let volatility = sqrt(variance)
        let funScore = VortexSimOutcome.computeFunScore(ev: mean, volatility: volatility)

        let histogram = buildHistogram(sorted: sorted, mean: mean, peak: peak)
        let topTen = Array(sorted.suffix(10).reversed())

        return VortexSimOutcome(trialCount: count, meanYield: mean, peakYield: peak,
                                nadirYield: nadir, funScoreIndex: funScore,
                                bucketedHistogram: histogram, topTenYields: topTen,
                                rawSamples: Array(samples.prefix(1000)))
    }

    private func buildHistogram(sorted: [Double], mean: Double, peak: Double) -> [HistoBucket] {
        let bucketCount = 8
        guard peak > 0 else { return [] }
        let step = peak / Double(bucketCount)
        var buckets = Array(repeating: 0, count: bucketCount)
        for v in sorted {
            let idx = min(Int(v / step), bucketCount - 1)
            buckets[idx] += 1
        }
        let total = Double(sorted.count)
        return buckets.enumerated().map { i, freq in
            let lo = String(format: "%.1f", Double(i) * step)
            let hi = String(format: "%.1f", Double(i + 1) * step)
            return HistoBucket(rangeLabel: "\(lo)-\(hi)", frequency: freq, proportion: Double(freq) / total)
        }
    }
}
