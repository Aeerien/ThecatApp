
import UIKit
import Foundation

// Delegate for updating the photo gallery UI
protocol PhotoGalleryViewModelDelegate: AnyObject {
    func didUpdatePhotos()
    func didReceiveError(_ error: Error)
}

// ViewModel for managing the breed photo gallery
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
    
    func loadImage(for url: String) async throws -> UIImage {
        return try await imageLoader.loadImage(from: url)
    }
    
    func prefetchImages(urls: [String]) {
        imageLoader.prefetchImages(at: urls)
    }
    
    func cancelPrefetching(urls: [String]) {
        imageLoader.cancelPrefetching(at: urls)
    }
    
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
