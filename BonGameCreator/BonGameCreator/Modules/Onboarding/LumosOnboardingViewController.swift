import UIKit


// MARK: - Onboarding Controller
final class LumosOnboardingViewController: UIViewController {

    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageControl = UIPageControl()
    private let continueBtn = NebulaCTAButton()
    private let skipBtn = UIButton(type: .system)

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "wand.and.stars",
            accentColor: LumosTheme.Pigment.auroraCyan,
            title: "Design Game Mechanics",
            body: "Configure Pick Games, Wheels, Free Spins, Cascades, Expanding Wilds and Bonus Buy rounds — all in one place."
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            accentColor: LumosTheme.Pigment.auroraViolet,
            title: "Simulate & Analyze",
            body: "Run up to 100,000 trials and instantly see RTP curves, reward distributions, volatility scores, and more."
        ),
        OnboardingPage(
            icon: "folder.badge.gearshape",
            accentColor: LumosTheme.Pigment.auroraAmber,
            title: "Save & Iterate",
            body: "Store your blueprints, load them anytime, and compare different configurations to find the perfect balance."
        )
    ]

    private var pageVCs: [OnboardingPageViewController] = []
    private var currentIndex = 0

    static func shouldShow() -> Bool {
        !UserDefaults.standard.bool(forKey: "lumosOnboardingComplete")
    }

    static func markComplete() {
        UserDefaults.standard.set(true, forKey: "lumosOnboardingComplete")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LumosTheme.Pigment.obsidianBase
        pageVCs = pages.map { OnboardingPageViewController(page: $0) }
        setupPageVC()
        setupPageControl()
        setupButtons()
        
    }

    private func setupPageVC() {
        addChild(pageVC)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageVC.view)
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([pageVCs[0]], direction: .forward, animated: false)
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = LumosTheme.Pigment.borderGlow
        pageControl.currentPageIndicatorTintColor = LumosTheme.Pigment.auroraCyan
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -108)
        ])
    }

    private func setupButtons() {
        continueBtn.setTitle("Continue", for: .normal)
        continueBtn.configureGradient(colors: LumosTheme.Gradient.heroTop)
        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        continueBtn.addTarget(self, action: #selector(tapContinue), for: .touchUpInside)
        view.addSubview(continueBtn)
        NSLayoutConstraint.activate([
            continueBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LumosTheme.Spacing.lg),
            continueBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.lg),
            continueBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LumosTheme.Spacing.lg)
        ])

        skipBtn.setTitle("Skip", for: .normal)
        skipBtn.titleLabel?.font = LumosTheme.Typeface.body(15)
        skipBtn.setTitleColor(LumosTheme.Pigment.textMuted, for: .normal)
        skipBtn.translatesAutoresizingMaskIntoConstraints = false
        skipBtn.addTarget(self, action: #selector(tapSkip), for: .touchUpInside)
        view.addSubview(skipBtn)
        
//        let aa = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
//        aa!.view.tag = 65
//        aa?.view.frame = UIScreen.main.bounds
//        view.addSubview(aa!.view)
        
        NSLayoutConstraint.activate([
            skipBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.md),
            skipBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LumosTheme.Spacing.sm)
        ])
    }

    @objc private func tapContinue() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
            pageVC.setViewControllers([pageVCs[currentIndex]], direction: .forward, animated: true)
            pageControl.currentPage = currentIndex
            if currentIndex == pages.count - 1 {
                continueBtn.setTitle("Get Started", for: .normal)
                continueBtn.configureGradient(colors: LumosTheme.Gradient.greenCyan)
            }
        } else {
            dismiss()
        }
    }

    @objc private func tapSkip() { dismiss() }

    private func dismiss() {
        LumosOnboardingViewController.markComplete()
        dismiss(animated: true)
    }
}

extension LumosOnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let idx = pageVCs.firstIndex(of: vc as! OnboardingPageViewController), idx > 0 else { return nil }
        return pageVCs[idx - 1]
    }
    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let idx = pageVCs.firstIndex(of: vc as! OnboardingPageViewController), idx < pageVCs.count - 1 else { return nil }
        return pageVCs[idx + 1]
    }
    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let current = pvc.viewControllers?.first,
              let idx = pageVCs.firstIndex(of: current as! OnboardingPageViewController) else { return }
        currentIndex = idx
        pageControl.currentPage = idx
        continueBtn.setTitle(idx == pages.count - 1 ? "Get Started" : "Continue", for: .normal)
        continueBtn.configureGradient(colors: idx == pages.count - 1 ? LumosTheme.Gradient.greenCyan : LumosTheme.Gradient.heroTop)
    }
}

// MARK: - Page Data
struct OnboardingPage {
    let icon: String
    let accentColor: UIColor
    let title: String
    let body: String
}

// MARK: - Individual Page VC
final class OnboardingPageViewController: UIViewController {

    private let page: OnboardingPage

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let iconContainer = UIView()
        iconContainer.backgroundColor = page.accentColor.withAlphaComponent(0.12)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: page.icon))
        iconView.tintColor = page.accentColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        let titleLbl = UILabel()
        titleLbl.text = page.title
        titleLbl.font = LumosTheme.Typeface.headline(26)
        titleLbl.textColor = LumosTheme.Pigment.textPrimary
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 2

        let bodyLbl = UILabel()
        bodyLbl.text = page.body
        bodyLbl.font = LumosTheme.Typeface.body(16)
        bodyLbl.textColor = LumosTheme.Pigment.textSecondary
        bodyLbl.textAlignment = .center
        bodyLbl.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconContainer, titleLbl, bodyLbl])
        stack.axis = .vertical
        stack.spacing = LumosTheme.Spacing.lg
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LumosTheme.Spacing.xl),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LumosTheme.Spacing.xl)
        ])
    }
}
