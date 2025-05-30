
import Foundation

protocol CacheConfigurationProtocol {
    var maxMemoryCount: Int { get }
    var maxMemorySize: Int { get }
}

struct DefaultCacheConfiguration: CacheConfigurationProtocol {
    let maxMemoryCount = 100
    let maxMemorySize = 50 * 1024 * 1024
}
