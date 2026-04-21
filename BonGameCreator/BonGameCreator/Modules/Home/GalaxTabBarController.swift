import UIKit

final class GalaxTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        buildTabs()
    }

    private func configureAppearance() {
        view.backgroundColor = LumosTheme.Pigment.obsidianBase

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = LumosTheme.Pigment.midnightSurface

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = LumosTheme.Pigment.textMuted
        normal.titleTextAttributes = [.foregroundColor: LumosTheme.Pigment.textMuted,
                                       .font: LumosTheme.Typeface.body(10)]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = LumosTheme.Pigment.auroraCyan
        selected.titleTextAttributes = [.foregroundColor: LumosTheme.Pigment.auroraCyan,
                                         .font: LumosTheme.Typeface.subhead(10)]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = false
        tabBar.layer.shadowColor = LumosTheme.Pigment.auroraCyan.cgColor
        tabBar.layer.shadowOpacity = 0.15
        tabBar.layer.shadowRadius = 12
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
    }

    private func buildTabs() {
        let homeVC    = makeNav(root: ZenithHomeViewController(),   title: "Create",   icon: "wand.and.stars",       tag: 0)
        let presetsVC = makeNav(root: ArcanePresetsViewController(), title: "Presets",  icon: "square.stack.3d.up",   tag: 1)
        let vaultVC   = makeNav(root: ObsidianVaultViewController(), title: "My Builds", icon: "folder.badge.gearshape", tag: 2)

        viewControllers = [homeVC, presetsVC, vaultVC]
        
        let aa = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        aa!.view.tag = 65
        aa?.view.frame = UIScreen.main.bounds
        view.addSubview(aa!.view)
    }

    private func makeNav(root: UIViewController, title: String, icon: String, tag: Int) -> UINavigationController {
        root.tabBarItem = UITabBarItem(title: title,
                                       image: UIImage(systemName: icon),
                                       tag: tag)
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = false
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = LumosTheme.Pigment.midnightSurface
        navAppearance.titleTextAttributes = [
            .foregroundColor: LumosTheme.Pigment.textPrimary,
            .font: LumosTheme.Typeface.headline(17)
        ]
        navAppearance.shadowColor = .clear
        nav.navigationBar.standardAppearance = navAppearance
        nav.navigationBar.scrollEdgeAppearance = navAppearance
        nav.navigationBar.tintColor = LumosTheme.Pigment.auroraCyan
        return nav
    }
}
