
import UIKit

// Utility for displaying alerts
enum AlertPresenter {
    static func showError(_ error: Error, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

