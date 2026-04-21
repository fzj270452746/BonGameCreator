import Foundation

// MARK: - Bonus Type
enum ZephyrBonusKind: Int, CaseIterable, Codable {
    case pickGame = 0
    case wheelGame = 1
    case freeSpins = 2

    var stellarTitle: String {
        switch self {
        case .pickGame:   return "Pick Game"
        case .wheelGame:  return "Wheel"
        case .freeSpins:  return "Free Spins"
        }
    }

    var stellarIcon: String {
        switch self {
        case .pickGame:   return "rectangle.grid.3x2.fill"
        case .wheelGame:  return "circle.grid.cross.fill"
        case .freeSpins:  return "sparkles"
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
    var createdAt: Date = Date()
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
