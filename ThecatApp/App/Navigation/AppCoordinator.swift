//
//  AppCoordinator.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Корневой координатор приложения
final class AppCoordinator: Coordinator {
    /// Дочерние координаторы
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    /// Запускает приложение, создавая основной flow
    func start() {
        let mainCoordinator = MainCoordinator(window: window)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}

