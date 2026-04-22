import Foundation

// MARK: - Bonus Type
enum ZephyrBonusKind: Int, CaseIterable, Codable {
    case pickGame       = 0
    case wheelGame      = 1
    case freeSpins      = 2
    case cascade        = 3
    case expandingWilds = 4
    case bonusBuy       = 5

    var stellarTitle: String {
        switch self {
        case .pickGame:       return "Pick Game"
        case .wheelGame:      return "Wheel"
        case .freeSpins:      return "Free Spins"
        case .cascade:        return "Cascade"
        case .expandingWilds: return "Expanding Wilds"
        case .bonusBuy:       return "Bonus Buy"
        }
    }

    var stellarIcon: String {
        switch self {
        case .pickGame:       return "rectangle.grid.3x2.fill"
        case .wheelGame:      return "circle.grid.cross.fill"
        case .freeSpins:      return "sparkles"
        case .cascade:        return "arrow.down.to.line.alt"
        case .expandingWilds: return "square.stack.fill"
        case .bonusBuy:       return "cart.fill"
        }
    }
}

// MARK: - Pick Game
struct CrystalPickConfig: Codable {
    var cardCount: Int = 9
    var pickCount: Int = 3
    var rewardTiers: [Double] = [1, 2, 5, 10, 20, 50]

    var allRewards: [Double] {
        var pool: [Double] = []
        for i in 0..<cardCount {
            pool.append(rewardTiers[i % rewardTiers.count])
        }
        return pool.shuffled()
    }
}

// MARK: - Wheel Game
struct PrismWheelSegment: Codable, Identifiable {
    var id: UUID = UUID()
    var rewardMultiplier: Double
    var weightFraction: Double
    var hexColor: String

    static func defaultSegments() -> [PrismWheelSegment] {
        let palette = ["#FF6B35","#F7C59F","#EFEFD0","#004E89","#1A936F","#C6E0B4","#E84855","#9B5DE5"]
        let data: [(Double, Double)] = [(1,20),(2,20),(5,15),(10,10),(20,5),(50,3),(100,2),(0.5,25)]
        return data.enumerated().map { idx, pair in
            PrismWheelSegment(rewardMultiplier: pair.0, weightFraction: pair.1, hexColor: palette[idx % palette.count])
        }
    }
}

struct CrystalWheelConfig: Codable {
    var segments: [PrismWheelSegment] = PrismWheelSegment.defaultSegments()

    var totalWeight: Double { segments.reduce(0) { $0 + $1.weightFraction } }
}

// MARK: - Free Spins
struct CrystalFreeSpinsConfig: Codable {
    var spinCount: Int = 10
    var baseMultiplier: Double = 2.0
    var retriggerChance: Double = 0.05
    var minSpinReward: Double = 0.5
    var maxSpinReward: Double = 10.0
}

// MARK: - Unified Blueprint
struct NexusBlueprint: Codable, Identifiable {
    var id: UUID = UUID()
    var stellarName: String = "Untitled Blueprint"
    var bonusKind: ZephyrBonusKind = .pickGame
    var pickConfig: CrystalPickConfig = CrystalPickConfig()
    var wheelConfig: CrystalWheelConfig = CrystalWheelConfig()
    var spinsConfig: CrystalFreeSpinsConfig = CrystalFreeSpinsConfig()
    var cascadeConfig: CrystalCascadeConfig = CrystalCascadeConfig()
    var expandingWildsConfig: CrystalExpandingWildsConfig = CrystalExpandingWildsConfig()
    var bonusBuyConfig: CrystalBonusBuyConfig = CrystalBonusBuyConfig()
    var createdAt: Date = Date()
}

// MARK: - Cascade
struct CrystalCascadeConfig: Codable {
    var rows: Int = 5
    var cols: Int = 5
    var symbolCount: Int = 8
    var minMatch: Int = 3
    var baseMultiplier: Double = 1.0
    var cascadeMultiplierStep: Double = 0.5
    var maxCascades: Int = 10
}

// MARK: - Expanding Wilds
struct CrystalExpandingWildsConfig: Codable {
    var wildChance: Double = 0.10
    var expandChance: Double = 0.40
    var reelCount: Int = 5
    var baseSpinReward: Double = 2.0
    var wildMultiplier: Double = 3.0
}

// MARK: - Bonus Buy
struct CrystalBonusBuyConfig: Codable {
    var buyCostMultiplier: Double = 80.0
    var bonusTriggerRTP: Double = 120.0
    var baseGameRTP: Double = 96.0
    var variance: Double = 0.3
}

// MARK: - Simulation Count
enum VortexSimVolume: Int, CaseIterable {
    case micro  = 1000
    case medium = 10000
    case macro  = 100000

    var displayLabel: String {
        switch self {
        case .micro:  return "1K"
        case .medium: return "10K"
        case .macro:  return "100K"
        }
    }
}
