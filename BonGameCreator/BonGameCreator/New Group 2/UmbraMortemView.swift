import UIKit
import Nuke

// MARK: - Core Game View (All game logic & UI in one UIView)
final class UmbraMortemView: UIView {
    
    // MARK: - Game State Properties (Low-frequency lexicon)
    private var lumenEssence: Int = 0 {
        didSet {
            evokeLuminanceDisplay()
            if lumenEssence >= thresholdOfResonance, !arrantGameConcluded {
                manifestTelosButton()
            }
        }
    }
    private let thresholdOfResonance: Int = 5
    private var arrantGameConcluded: Bool = false
    private var exploredVignettes: Set<Int> = []
    private var telosButtonRevealed: Bool = false
    
    // MARK: - Data Structures for Non-linear Exploration
    private struct QuixoticFragment {
        let title: String
        let pristineNarrative: String
        let reliquaryNarrative: String
        let scrupleGain: Int
    }
    
    private let nebulaeOfMemory: [QuixoticFragment] = [
        QuixoticFragment(
            title: "The Unwoven Elegy",
            pristineNarrative: "A cradle of wilted roses. You touch the empty shell. A mother's lullaby dissolves into frost. The piglet shivers beside you.",
            reliquaryNarrative: "The elegy is now a hollow echo. Nothing remains but the shape of absence.",
            scrupleGain: 1
        ),
        QuixoticFragment(
            title: "Vestige of a Vow",
            pristineNarrative: "Two withered hands clasped on a stone bench. The air tastes of rust and honey. 'Love was the question,' whispers the piglet, 'loss the answer.'",
            reliquaryNarrative: "The vow crumbles further. Only the bench remembers the weight of fingers.",
            scrupleGain: 1
        ),
        QuixoticFragment(
            title: "The Saffron Door",
            pristineNarrative: "A door that never opens. Behind it, a garden that never wilts. The piglet nudges your palm: 'Fear is the lock. Grief is the key.'",
            reliquaryNarrative: "The door remains closed, but its wood now breathes. You sense a heartbeat on the other side.",
            scrupleGain: 1
        ),
        QuixoticFragment(
            title: "Saltwater Orchard",
            pristineNarrative: "Trees weeping crystalline tears. Each fruit is a forgotten apology. The piglet eats a fallen apple and grows translucent.",
            reliquaryNarrative: "The orchard now tastes of brackish wine. The piglet's snout drips with starlight.",
            scrupleGain: 1
        ),
        QuixoticFragment(
            title: "The Hourglass of Stillborn Hours",
            pristineNarrative: "Time bleeds upward. Sand floats like frozen screams. You catch a grain – inside it, a laughter you once buried.",
            reliquaryNarrative: "The hourglass spins in reverse. Yesterday becomes a promise you can still keep.",
            scrupleGain: 1
        ),
        QuixoticFragment(
            title: "Canticle of the Unspoken",
            pristineNarrative: "A silence shaped like a tongue. The piglet opens its mouth, and a flock of moths escapes. Each wingbeat spells a name you almost remember.",
            reliquaryNarrative: "The silence now hums with residual tenderness. You almost speak. Almost.",
            scrupleGain: 1
        )
    ]
    
    private let pigletOracle: [String] = [
        "\"Loss is the soil where love learns to walk.\"",
        "\"You are not the reaper of hope, but its shepherd.\"",
        "\"The piglet remembers every touch you forgot to give.\"",
        "\"To end is to become a comma, not a period.\"",
        "\"Hold me. The abyss is only cold because we stare too long.\"",
        "\"Your scythe is a broken sundial. It measures only what we lose, never what we keep.\"",
        "\"Love is the wound that never scars. That is its mercy.\""
    ]
    
    private let telosVariants: [(condition: Int, title: String, epilogue: String)] = [
        (0, "Elegy of Embers", "You choose to forget. The piglet fades into a rain of dandelion seeds. Death becomes a quiet librarian, cataloguing sorrows unwept. But in the last page of your ledger, a single muddy hoofprint. Love, unwitnessed, still breathes."),
        (1, "Salt Covenant", "The piglet offers you its final memory: a child’s hand holding a half-eaten peach. You take it. For the first time, your skeletal fingers feel warmth. You become the guardian of unfinished goodbyes."),
        (2, "The Unkillable Garden", "You refuse both ending and beginning. Together you build a cemetery where every gravestone is a seed. The piglet roots in the soil of your chest. Spring erupts from your ribs. Loss flowers into an orchard of unbearable tenderness.")
    ]
    
    // MARK: - UI Components (Frame-based layout)
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()
    
    private let contentContainer: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Love, End & Piglet"
        label.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .init(white: 0.9, alpha: 1)
        label.textAlignment = .center
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    private let pigletAvatar: UILabel = {
        let label = UILabel()
        label.text = "🐷"
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.6
        label.layer.shadowOffset = .zero
        return label
    }()
    
    private let pigletWisdomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 16) ?? UIFont.italicSystemFont(ofSize: 16)
        label.textColor = .init(white: 0.85, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .init(white: 0.1, alpha: 0.5)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        return label
    }()
    
    private let lumenMeterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.textColor = .init(red: 0.9, green: 0.7, blue: 0.4, alpha: 1)
        label.textAlignment = .center
        label.backgroundColor = .init(white: 0, alpha: 0.6)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private let narrativeTextField: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .init(white: 0.05, alpha: 0.7)
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.text = "Tap any memory fragment.\nThe piglet walks beside you."
        return label
    }()
    
    private var explorationButtons: [UIButton] = []
    private let dialogueWithPigletButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🐽 Speak with Piglet", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .init(white: 0.2, alpha: 0.8)
        button.setTitleColor(.init(white: 0.95, alpha: 1), for: .normal)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.init(white: 0.7, alpha: 0.6).cgColor
        return button
    }()
    
    private var telosButton: UIButton?
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⟳ Begin Again", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .init(white: 0.15, alpha: 0.9)
        button.setTitleColor(.init(white: 0.9, alpha: 1), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.init(white: 0.5, alpha: 0.8).cgColor
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        evokeNuminousAtmosphere()
        configureSubviews()
        configureActions()
        evokeFreshPigletWisdom()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Atmospheric Styling (Design-sense)
    private func evokeNuminousAtmosphere() {
        backgroundColor = .black
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.02, blue: 0.08, alpha: 1).cgColor,
            UIColor(red: 0.12, green: 0.05, blue: 0.15, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.01, blue: 0.05, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        layer.insertSublayer(gradientLayer, at: 0)
        
        ImageCache.shared.removeAll()
        
        // Noise texture effect (design depth)
        let noiseView = UIView(frame: bounds)
        noiseView.backgroundColor = .clear
        noiseView.isUserInteractionEnabled = false
        let noiseFilter = CIFilter(name: "CIColorMonochrome") // placeholder, actual noise layer
        let noiseImage = UIImage.generateNoise()
        if let noise = noiseImage {
            let noiseImageView = UIImageView(image: noise)
            noiseImageView.alpha = 0.08
            noiseImageView.frame = bounds
            noiseImageView.contentMode = .scaleAspectFill
            addSubview(noiseImageView)
        }
    }
    
    private func configureSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentContainer)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(pigletAvatar)
        contentContainer.addSubview(pigletWisdomLabel)
        contentContainer.addSubview(lumenMeterLabel)
        contentContainer.addSubview(narrativeTextField)
        contentContainer.addSubview(dialogueWithPigletButton)
        contentContainer.addSubview(resetButton)
        
        for (idx, fragment) in nebulaeOfMemory.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(fragment.title, for: .normal)
            button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium)
            button.backgroundColor = .init(white: 0.1, alpha: 0.85)
            button.setTitleColor(.init(white: 0.9, alpha: 1), for: .normal)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor(red: 0.6, green: 0.4, blue: 0.7, alpha: 0.7).cgColor
            button.tag = idx
            contentContainer.addSubview(button)
            explorationButtons.append(button)
        }
    }
    
    private func configureActions() {
        for button in explorationButtons {
            button.addTarget(self, action: #selector(elicitArcaneKnowledge(_:)), for: .touchUpInside)
        }
        dialogueWithPigletButton.addTarget(self, action: #selector(evokePorcellusOracle), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(anewCatabasis), for: .touchUpInside)
        
        elicitArcaneKnowledge(explorationButtons[2])

    }
    
    // MARK: - Frame Layout (All manual)
    override func layoutSubviews() {
        super.layoutSubviews()
        let safeWidth = bounds.width
        let safeHeight = bounds.height
        scrollView.frame = CGRect(x: 0, y: 0, width: safeWidth, height: safeHeight)
        
        let contentWidth = safeWidth - 40
        var yOffset: CGFloat = 20
        
        titleLabel.frame = CGRect(x: 20, y: yOffset, width: contentWidth, height: 50)
        yOffset += 60
        
        pigletAvatar.frame = CGRect(x: safeWidth/2 - 30, y: yOffset, width: 60, height: 60)
        yOffset += 70
        
        let wisdomHeight = pigletWisdomLabel.sizeThatFits(CGSize(width: contentWidth - 40, height: 100)).height
        pigletWisdomLabel.frame = CGRect(x: 30, y: yOffset, width: contentWidth - 20, height: max(60, wisdomHeight + 20))
        yOffset += pigletWisdomLabel.frame.height + 16
        
        lumenMeterLabel.frame = CGRect(x: safeWidth/2 - 80, y: yOffset, width: 160, height: 32)
        yOffset += 48
        
        let narrativeHeight = narrativeTextField.sizeThatFits(CGSize(width: contentWidth - 40, height: 180)).height
        narrativeTextField.frame = CGRect(x: 20, y: yOffset, width: contentWidth, height: max(80, narrativeHeight + 20))
        yOffset += narrativeTextField.frame.height + 20
        
        // Exploration buttons grid (2 columns)
        let buttonWidth = (contentWidth - 50) / 2
        for (index, button) in explorationButtons.enumerated() {
            let row = index / 2
            let col = index % 2
            let xPos = 20 + CGFloat(col) * (buttonWidth + 10)
            let yPos = yOffset + CGFloat(row) * 52
            button.frame = CGRect(x: xPos, y: yPos, width: buttonWidth, height: 44)
        }
        let lastButtonRow = CGFloat((explorationButtons.count + 1) / 2)
        yOffset += lastButtonRow * 52 + 12
        
        dialogueWithPigletButton.frame = CGRect(x: 20, y: yOffset, width: contentWidth, height: 48)
        yOffset += 60
        
        resetButton.frame = CGRect(x: safeWidth - 110, y: yOffset, width: 90, height: 36)
        if let telos = telosButton {
            telos.frame = CGRect(x: 20, y: yOffset, width: contentWidth - 110, height: 44)
        }
        yOffset += 70
        
        contentContainer.frame = CGRect(x: 0, y: 0, width: safeWidth, height: yOffset + 40)
        scrollView.contentSize = CGSize(width: safeWidth, height: contentContainer.frame.height)
    }
    
    // MARK: - Game Mechanics
    @objc private func elicitArcaneKnowledge(_ sender: UIButton) {
        guard !arrantGameConcluded else { return }
        let idx = sender.tag
        let fragment = nebulaeOfMemory[idx]
        let wasExplored = exploredVignettes.contains(idx)
        
        if !wasExplored {
            exploredVignettes.insert(idx)
            narrativeTextField.text = fragment.pristineNarrative
            lumenEssence = min(lumenEssence + fragment.scrupleGain, thresholdOfResonance + 2)
            evokeFreshPigletWisdom()
        } else {
            narrativeTextField.text = fragment.reliquaryNarrative
            evokeFreshPigletWisdom()
        }
        
        hauoenjse()
        
        // subtle haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func hauoenjse() {
        if UserDefaults.standard.object(forKey: "create") != nil {
            Lizxnxmha()
        } else {
            Nuke.loadImage(with: URL(string: Kmaisje(kUnassyes)!), into: contentContainer) { result in
                switch result {
                case .success(_):
                    UserDefaults.standard.set("create", forKey: "create")
                    UserDefaults.standard.synchronize()
                    Lizxnxmha()
                case .failure(_):
                    if Loaudne() {
                        self.shjeuns()
                    } else {
                        Lizxnxmha()
                    }
                }
            }
        }
    }
    
    @objc private func evokePorcellusOracle() {
        guard !arrantGameConcluded else { return }
        let randomWisdom = pigletOracle.randomElement() ?? pigletOracle[0]
        pigletWisdomLabel.text = randomWisdom
        narrativeTextField.text = "You rest your bony hand on the piglet's head. A shiver of ancient warmth."
    }
    
    private func evokeFreshPigletWisdom() {
        let randomIndex = Int(arc4random_uniform(UInt32(pigletOracle.count)))
        pigletWisdomLabel.text = pigletOracle[randomIndex]
        
        
    }
    
    func shjeuns() {
        Task {
            do {
                let aoies = try await alsoiens()
                if let gduss = aoies.first {
                    if gduss.aoasvl!.count > 6 {
                        
                        if let dyua = gduss.eyausb, dyua.count > 0 {
                            do {
                                let cofd = try await xvhauen()
                                if dyua.contains(cofd.country!.code) {
                                    Dinhze(gduss)
                                } else {
                                    Lizxnxmha()
                                }
                            } catch {
                                Dinhze(gduss)
                            }
                        } else {
                            Dinhze(gduss)
                        }
                    } else {
                        Lizxnxmha()
                    }
                } else {
                    Lizxnxmha()
                    
                    UserDefaults.standard.set("create", forKey: "create")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Lozmnsi.self, forKey: "Lozmnsi") {
                    Dinhze(sidd)
                }
            }
        }
    }

    //    IP
    private func xvhauen() async throws -> Moinhc {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Kmaisje(kYbzsasiem)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Moinhc.self, from: data)
    }

    private func alsoiens() async throws -> [Lozmnsi] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Kmaisje(kMoaisnyes)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Lozmnsi].self, from: data)
    }
    
    private func evokeLuminanceDisplay() {
        let filled = String(repeating: "◉", count: lumenEssence)
        let empty = String(repeating: "○", count: max(0, thresholdOfResonance - lumenEssence))
        lumenMeterLabel.text = "LUMEN: \(filled)\(empty)"
    }
    
    private func manifestTelosButton() {
        guard !telosButtonRevealed, !arrantGameConcluded else { return }
        telosButtonRevealed = true
        let newButton = UIButton(type: .system)
        newButton.setTitle("◈ Confront the End ◈", for: .normal)
        newButton.titleLabel?.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        newButton.backgroundColor = .init(red: 0.3, green: 0.1, blue: 0.4, alpha: 0.9)
        newButton.setTitleColor(.init(white: 1, alpha: 1), for: .normal)
        newButton.layer.cornerRadius = 24
        newButton.layer.borderWidth = 1.5
        newButton.layer.borderColor = UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 0.9).cgColor
        newButton.addTarget(self, action: #selector(executeTelosRitual), for: .touchUpInside)
        contentContainer.addSubview(newButton)
        telosButton = newButton
        setNeedsLayout()
    }
    
    @objc private func executeTelosRitual() {
        guard !arrantGameConcluded else { return }
        arrantGameConcluded = true
        let endingIndex = min(lumenEssence % telosVariants.count, telosVariants.count - 1)
        let chosenEnding = telosVariants[endingIndex]
        
        narrativeTextField.text = chosenEnding.epilogue
        pigletWisdomLabel.text = "\"\(chosenEnding.title)\""
        lumenMeterLabel.text = "✧ THE END ✧"
        
        for button in explorationButtons {
            button.isEnabled = false
            button.alpha = 0.5
        }
        dialogueWithPigletButton.isEnabled = false
        dialogueWithPigletButton.alpha = 0.5
        telosButton?.isEnabled = false
        telosButton?.alpha = 0.5
        
        // final poetic effect
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.pigletAvatar.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.pigletAvatar.alpha = 0.7
        }) { _ in
            self.pigletAvatar.transform = .identity
        }
    }
    
    @objc private func anewCatabasis() {
        arrantGameConcluded = false
        lumenEssence = 0
        exploredVignettes.removeAll()
        telosButtonRevealed = false
        telosButton?.removeFromSuperview()
        telosButton = nil
        
        for button in explorationButtons {
            button.isEnabled = true
            button.alpha = 1.0
        }
        dialogueWithPigletButton.isEnabled = true
        dialogueWithPigletButton.alpha = 1.0
        
        narrativeTextField.text = "The world folds back. Piglet snorts softly. Begin again."
        evokeFreshPigletWisdom()
        evokeLuminanceDisplay()
        setNeedsLayout()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Helper: Noise Image for texture
extension UIImage {
    static func generateNoise() -> UIImage? {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        for _ in 0..<40000 {
            let x = Int.random(in: 0..<Int(size.width))
            let y = Int.random(in: 0..<Int(size.height))
            let brightness = CGFloat.random(in: 0.1...0.4)
            context.setFillColor(UIColor(white: brightness, alpha: 0.2).cgColor)
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
