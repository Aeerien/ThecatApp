//
//  AlertPresenter.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Утилита для показа алертов
enum AlertPresenter {
    static func showError(_ error: Error, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

