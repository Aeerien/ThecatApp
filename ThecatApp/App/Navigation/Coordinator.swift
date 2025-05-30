
import UIKit

// Coordinator is responsible for navigation and flow within the application
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    
    // Starts the coordinator's flow
    func start()
}

