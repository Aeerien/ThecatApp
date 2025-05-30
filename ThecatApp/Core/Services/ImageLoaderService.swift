
import UIKit

// Protocol for loading images
protocol ImageLoaderServiceProtocol {
    func loadImage(from url: String) async throws -> UIImage
}

// Protocol for preloading images
protocol ImagePrefetchingProtocol: AnyObject {
    func prefetchImages(at urls: [String])
    func cancelPrefetching(at urls: [String])
}

// Service for loading and caching images
final class ImageLoaderService: ImageLoaderServiceProtocol, ImagePrefetchingProtocol {
    private let cache: CacheServiceProtocol
    private var prefetchTasks: [String: Task<Void, Never>] = [:]
    private let queue = DispatchQueue(label: "com.thecatapi.imageloader", qos: .utility)
    
    init(cache: CacheServiceProtocol = ImageCacheManager.shared) {
        self.cache = cache
    }
    
    func loadImage(from url: String) async throws -> UIImage {
        if let cachedImage = cache.getImage(for: url) {
            return cachedImage
        }
        
        guard let imageUrl = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: imageUrl)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw APIError.decodingError(NSError(domain: "ImageLoading",
                                                 code: -1,
                                                 userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
        }
        
        cache.saveImage(image, for: url)
        
        return image
    }
    
    func prefetchImages(at urls: [String]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            for url in urls {
                if self.prefetchTasks[url] == nil {
                    let task = Task {
                        _ = try? await self.loadImage(from: url)
                    }
                    self.prefetchTasks[url] = task
                }
            }
        }
    }
    
    func cancelPrefetching(at urls: [String]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            for url in urls {
                self.prefetchTasks[url]?.cancel()
                self.prefetchTasks.removeValue(forKey: url)
            }
        }
    }
}
