
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Check if the device supports scenes
        if #available(iOS 13.0, *) {
            // Используем SceneDelegate для настройки окна
        } else {
            // For devices running iOS versions earlier than 13, configure the window here
            window = UIWindow(frame: UIScreen.main.bounds)
            appCoordinator = AppCoordinator(window: window!)
            appCoordinator?.start()
        }
        setupAppearance()
        
        return true
    }
    
    private func setupAppearance() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Clear cache when entering background to free up memory
        ImageCacheManager.shared.clearCache()
    }
}
