//
//  MainCoordinator.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Делегат для навигации из экрана деталей породы
protocol BreedDetailNavigationDelegate: AnyObject {
    /// Показывает галерею фотографий для породы
    func showGallery(for breedId: String, title: String)
}

/// Координатор основного flow приложения
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
    
    /// Запускает основной flow приложения
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

