import Foundation

struct VortexSimOutcome {
    let trialCount: Int
    let meanYield: Double
    let peakYield: Double
    let nadirYield: Double
    let funScoreIndex: Double
    let bucketedHistogram: [HistoBucket]
    let topTenYields: [Double]
    let rawSamples: [Double]

    var volatilityIndex: Double {
        guard rawSamples.count > 1 else { return 0 }
        let mean = meanYield
        let variance = rawSamples.reduce(0.0) { $0 + pow($1 - mean, 2) } / Double(rawSamples.count)
        return sqrt(variance)
    }
}

struct HistoBucket: Identifiable {
    let id = UUID()
    let rangeLabel: String
    let frequency: Int
    let proportion: Double
}

// MARK: - Fun Score
extension VortexSimOutcome {
    static func computeFunScore(ev: Double, volatility: Double) -> Double {
        let raw = ev * (1 + volatility / 10.0)
        return min(max(raw, 0), 100)
    }
}
