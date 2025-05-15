//
//  Coordinator.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Координатор отвечает за навигацию и flow в приложении
protocol Coordinator: AnyObject {
    /// Дочерние координаторы
    var childCoordinators: [Coordinator] { get set }
    
    /// Запускает flow координатора
    func start()
}

