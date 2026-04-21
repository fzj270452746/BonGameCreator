import Foundation

final class ArcaneVaultStore {

    static let shared = ArcaneVaultStore()
    private init() {}

    private let blueprintKey = "arcane_blueprints_v1"

    func fetchAllBlueprints() -> [NexusBlueprint] {
        guard let data = UserDefaults.standard.data(forKey: blueprintKey),
              let decoded = try? JSONDecoder().decode([NexusBlueprint].self, from: data) else {
            return []
        }
        return decoded
    }

    func persistBlueprint(_ blueprint: NexusBlueprint) {
        var all = fetchAllBlueprints()
        if let idx = all.firstIndex(where: { $0.id == blueprint.id }) {
            all[idx] = blueprint
        } else {
            all.append(blueprint)
        }
        saveAll(all)
    }

    func obliterateBlueprint(id: UUID) {
        var all = fetchAllBlueprints()
        all.removeAll { $0.id == id }
        saveAll(all)
    }

    private func saveAll(_ blueprints: [NexusBlueprint]) {
        if let data = try? JSONEncoder().encode(blueprints) {
            UserDefaults.standard.set(data, forKey: blueprintKey)
        }
    }

    // MARK: - Presets
    func builtInPresets() -> [NexusBlueprint] {
        var presets: [NexusBlueprint] = []

        // Pick - High Risk
        var p1 = NexusBlueprint()
        p1.stellarName = "Pick: High Risk"
        p1.bonusKind = .pickGame
        p1.pickConfig = CrystalPickConfig(cardCount: 9, pickCount: 2, rewardTiers: [0.5, 1, 1, 2, 50, 100])
        presets.append(p1)

        // Pick - Balanced
        var p2 = NexusBlueprint()
        p2.stellarName = "Pick: Balanced"
        p2.bonusKind = .pickGame
        p2.pickConfig = CrystalPickConfig(cardCount: 9, pickCount: 3, rewardTiers: [1, 2, 5, 10, 20, 50])
        presets.append(p2)

        // Wheel - Even
        var w1 = NexusBlueprint()
        w1.stellarName = "Wheel: Even Distribution"
        w1.bonusKind = .wheelGame
        var evenSegs = PrismWheelSegment.defaultSegments()
        evenSegs = evenSegs.map { PrismWheelSegment(id: $0.id, rewardMultiplier: $0.rewardMultiplier, weightFraction: 12.5, hexColor: $0.hexColor) }
        w1.wheelConfig = CrystalWheelConfig(segments: evenSegs)
        presets.append(w1)

        // Wheel - Jackpot
        var w2 = NexusBlueprint()
        w2.stellarName = "Wheel: Jackpot Style"
        w2.bonusKind = .wheelGame
        let jackpotSegs = [
            PrismWheelSegment(rewardMultiplier: 1, weightFraction: 40, hexColor: "#FF6B35"),
            PrismWheelSegment(rewardMultiplier: 2, weightFraction: 30, hexColor: "#F7C59F"),
            PrismWheelSegment(rewardMultiplier: 5, weightFraction: 15, hexColor: "#1A936F"),
            PrismWheelSegment(rewardMultiplier: 10, weightFraction: 8, hexColor: "#004E89"),
            PrismWheelSegment(rewardMultiplier: 50, weightFraction: 4, hexColor: "#9B5DE5"),
            PrismWheelSegment(rewardMultiplier: 500, weightFraction: 1, hexColor: "#E84855"),
            PrismWheelSegment(rewardMultiplier: 0.5, weightFraction: 2, hexColor: "#C6E0B4")
        ]
        w2.wheelConfig = CrystalWheelConfig(segments: jackpotSegs)
        presets.append(w2)

        // Free Spins - Low
        var f1 = NexusBlueprint()
        f1.stellarName = "Spins: Low Multiplier"
        f1.bonusKind = .freeSpins
        f1.spinsConfig = CrystalFreeSpinsConfig(spinCount: 10, baseMultiplier: 1.5, retriggerChance: 0.03, minSpinReward: 0.5, maxSpinReward: 5)
        presets.append(f1)

        // Free Spins - High
        var f2 = NexusBlueprint()
        f2.stellarName = "Spins: High Multiplier"
        f2.bonusKind = .freeSpins
        f2.spinsConfig = CrystalFreeSpinsConfig(spinCount: 8, baseMultiplier: 5.0, retriggerChance: 0.08, minSpinReward: 1, maxSpinReward: 20)
        presets.append(f2)

        return presets
    }
}
