
import UIKit

// Root coordinator of the application
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    // Launches the app by creating the main flow
    func start() {
        let mainCoordinator = MainCoordinator(window: window)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}

