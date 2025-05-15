//
//  PhotoGalleryViewModel.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit
import Foundation

/// Делегат для обновления UI галереи фотографий
protocol PhotoGalleryViewModelDelegate: AnyObject {
    func didUpdatePhotos()
    func didReceiveError(_ error: Error)
}

/// ViewModel для управления галереей фотографий породы
final class PhotoGalleryViewModel {
    private let apiService: APIServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol & ImagePrefetchingProtocol
    private let breedId: String
    private var currentPage = 0
    private let perPage = 10
    private var currentTask: Task<Void, Never>?
    
    private(set) var photos: [BreedImage] = []
    weak var delegate: PhotoGalleryViewModelDelegate?
    
    init(breedId: String,
         apiService: APIServiceProtocol = APIService(),
         imageLoader: (ImageLoaderServiceProtocol & ImagePrefetchingProtocol) = ImageLoaderService()) {
        self.breedId = breedId
        self.apiService = apiService
        self.imageLoader = imageLoader
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    /// Загружает изображение по URL
    func loadImage(for url: String) async throws -> UIImage {
        return try await imageLoader.loadImage(from: url)
    }
    
    /// Запускает предварительную загрузку изображений
    func prefetchImages(urls: [String]) {
        imageLoader.prefetchImages(at: urls)
    }
    
    /// Отменяет предварительную загрузку изображений
    func cancelPrefetching(urls: [String]) {
        imageLoader.cancelPrefetching(at: urls)
    }
    
    /// Загружает следующую страницу фотографий
    func loadNextPage() {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let newPhotos: [BreedImage] = try await apiService.fetch(endpoint: .breedImages(breedId))
                if !Task.isCancelled {
                    await MainActor.run {
                        self.photos.append(contentsOf: newPhotos)
                        self.currentPage += 1
                        self.delegate?.didUpdatePhotos()
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.delegate?.didReceiveError(error)
                    }
                }
            }
        }
    }
}

