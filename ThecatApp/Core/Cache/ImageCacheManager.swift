
import UIKit

// Image caching manager (Singleton)
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var memoryCacheCount = 0
    private let configuration: CacheConfigurationProtocol
    private let ioQueue = DispatchQueue(label: "com.thecatapi.imagecache.io", qos: .utility)
    private let maxFileAge: TimeInterval = 7 * 24 * 60 * 60
    
    private init(configuration: CacheConfigurationProtocol = DefaultCacheConfiguration()) {
        self.configuration = configuration
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        cache.countLimit = configuration.maxMemoryCount
        cache.totalCostLimit = configuration.maxMemorySize
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        cleanOldFiles()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handler for memory warning
    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
        memoryCacheCount = 0
    }
    
    private func cleanOldFiles() {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            let now = Date()
            
            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.cacheDirectory,
                includingPropertiesForKeys: [.creationDateKey]
            ) else { return }
            
            for file in files {
                guard let attrs = try? self.fileManager.attributesOfItem(atPath: file.path),
                      let creationDate = attrs[.creationDate] as? Date else { continue }
                
                if now.timeIntervalSince(creationDate) > self.maxFileAge {
                    try? self.fileManager.removeItem(at: file)
                }
            }
        }
    }
}

// MARK: - CacheServiceProtocol
extension ImageCacheManager: CacheServiceProtocol {
    func getImage(for key: String) -> UIImage? {
        if let cached = cache.object(forKey: key as NSString) {
            return cached
        }
        
        let path = cacheDirectory.appendingPathComponent(key.hash.description)
        
        return ioQueue.sync {
            if let data = try? Data(contentsOf: path),
               let img = UIImage(data: data) {
                cache.setObject(img, forKey: key as NSString)
                memoryCacheCount += 1
                return img
            }
            return nil
        }
    }
    
    func saveImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
        memoryCacheCount += 1
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            let path = self.cacheDirectory.appendingPathComponent(key.hash.description)
            try? image.jpegData(compressionQuality: 0.8)?.write(to: path)
        }
    }
    
    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
        memoryCacheCount -= 1
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            let path = self.cacheDirectory.appendingPathComponent(key.hash.description)
            try? self.fileManager.removeItem(at: path)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        memoryCacheCount = 0
        
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory,
                                                  withIntermediateDirectories: true)
        }
    }
    
    func getCacheInfo() -> (memoryCount: Int, diskSize: String) {
        let diskBytes = (try? fileManager.contentsOfDirectory(at: cacheDirectory,
                                                              includingPropertiesForKeys: [.fileSizeKey]))
            .map { urls in
                urls.reduce(0) { sum, url in
                    (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map { sum + $0 } ?? sum
                }
            } ?? 0
        let fmt = ByteCountFormatter()
        fmt.allowedUnits = [.useMB, .useKB]
        fmt.countStyle = .file
        return (memoryCacheCount, fmt.string(fromByteCount: Int64(diskBytes)))
    }
}

extension ImageCacheManager {
    func printCacheStatus() {
        let info = getCacheInfo()
        print("Cache status — memory images: \(info.memoryCount), disk: \(info.diskSize)")
    }
}

