//
//  BreedDetailViewModel.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// ViewModel для отображения детальной информации о породе
final class BreedDetailViewModel: BreedDetailViewModelProtocol {
    typealias State = BreedDetailState
    
    /// Состояния экрана детальной информации
    enum BreedDetailState {
        case initial
        case loading
        case loaded
        case error(Error)
    }
    
    private(set) var state: State = .initial
    private let apiService: APIServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol
    private let cacheService: CacheServiceProtocol
    private var currentTask: Task<Void, Never>?

    private(set) var breed: Breed?
    private(set) var breedImage: UIImage?
    
    weak var delegate: BreedDetailViewModelDelegate?
    
    init(apiService: APIServiceProtocol = APIService(),
         imageLoader: ImageLoaderServiceProtocol = ImageLoaderService(),
         cacheService: CacheServiceProtocol = ImageCacheManager.shared) {
        self.apiService = apiService
        self.imageLoader = imageLoader
        self.cacheService = cacheService
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    /// Устанавливает породу для отображения и запускает загрузку изображения
    func setBreed(_ breed: Breed) {
        currentTask?.cancel()
        self.breed = breed
        self.breedImage = nil
        state = .loading
        
        Task { @MainActor in
            delegate?.didStartLoadingImage()
        }
        
        loadBreedImage(breed)
    }
    
    /// Загружает изображение для породы
    private func loadBreedImage(_ breed: Breed) {
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                if let imageId = breed.imageId {
                    let image: BreedImage = try await self.apiService.fetch(endpoint: .imageById(imageId))
                    if !Task.isCancelled {
                        try await self.loadAndCacheImage(from: image.url)
                    }
                } else {
                    let images: [BreedImage] = try await self.apiService.fetch(endpoint: .breedImages(breed.id))
                    if !Task.isCancelled, let firstImage = images.first {
                        try await self.loadAndCacheImage(from: firstImage.url)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.state = .error(error)
                        self.delegate?.didReceiveError(error)
                    }
                }
            }
        }
    }
    
    /// Загружает и кэширует изображение по URL
    private func loadAndCacheImage(from url: String) async throws {
        let image = try await imageLoader.loadImage(from: url)
        if !Task.isCancelled {
            await updateImage(image)
        }
    }
    
    /// Обновляет UI после загрузки изображения
    @MainActor
    private func updateImage(_ image: UIImage) {
        breedImage = image
        state = .loaded
        delegate?.didUpdateBreedImage()
    }
}

