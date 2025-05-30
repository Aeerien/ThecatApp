
import UIKit

// Delegate for navigation from the breed detail screen
protocol BreedDetailNavigationDelegate: AnyObject {
    // Displays a photo gallery for the selected breed
    func showGallery(for breedId: String, title: String)
}

// Coordinator of the main application flow
final class MainCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    private weak var window: UIWindow?
    private let factory: ViewControllerFactoryProtocol
    private weak var navigationController: UINavigationController?
    private weak var mainViewController: MainViewController?
    
    init(window: UIWindow, factory: ViewControllerFactoryProtocol = ViewControllerFactory()) {
        self.window = window
        self.factory = factory
        super.init()
    }
    
    // Starts the main application flow
    func start() {
        let mainVC = factory.makeMainViewController()
        mainVC.breedDetailViewController.navigationDelegate = self
        
        let nav = UINavigationController(rootViewController: mainVC)
        navigationController = nav
        mainViewController = mainVC
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

// MARK: - MainCoordinatorProtocol
extension MainCoordinator: BreedDetailNavigationDelegate {
    func showGallery(for breedId: String, title: String) {
        let galleryVC = factory.makePhotoGalleryViewController(breedId: breedId, title: title)
        let nav = UINavigationController(rootViewController: galleryVC)
        mainViewController?.present(nav, animated: true)
    }
}

