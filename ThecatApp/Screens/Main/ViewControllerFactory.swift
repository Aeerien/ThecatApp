//
//  ViewControllerFactory.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Протокол для создания view controllers
protocol ViewControllerFactoryProtocol {
    func makeMainViewController() -> MainViewController
    func makeBreedListViewController() -> BreedListViewController
    func makeBreedDetailViewController() -> BreedDetailViewController
    func makePhotoGalleryViewController(breedId: String, title: String) -> PhotoGalleryViewController
}

/// Класс для создания view controllers с правильной инъекцией зависимостей
final class ViewControllerFactory: ViewControllerFactoryProtocol {
    private let apiService: APIServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol & ImagePrefetchingProtocol
    private let cacheService: CacheServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService(),
         imageLoader: (ImageLoaderServiceProtocol & ImagePrefetchingProtocol) = ImageLoaderService(),
         cacheService: CacheServiceProtocol = ImageCacheManager.shared) {
        self.apiService = apiService
        self.imageLoader = imageLoader
        self.cacheService = cacheService
    }
    
    func makeMainViewController() -> MainViewController {
        let breedListVC = makeBreedListViewController()
        let breedDetailVC = makeBreedDetailViewController()
        return MainViewController(breedListViewController: breedListVC,
                                breedDetailViewController: breedDetailVC)
    }
    
    func makeBreedListViewController() -> BreedListViewController {
        let viewModel = BreedListViewModel(apiService: apiService)
        return BreedListViewController(viewModel: viewModel)
    }
    
    func makeBreedDetailViewController() -> BreedDetailViewController {
        let viewModel = BreedDetailViewModel(
            apiService: apiService,
            imageLoader: imageLoader,
            cacheService: cacheService
        )
        return BreedDetailViewController(viewModel: viewModel)
    }
    
    func makePhotoGalleryViewController(breedId: String, title: String) -> PhotoGalleryViewController {
        let viewModel = PhotoGalleryViewModel(
            breedId: breedId,
            apiService: apiService,
            imageLoader: imageLoader
        )
        let vc = PhotoGalleryViewController(viewModel: viewModel)
        vc.title = title
        return vc
    }
}

