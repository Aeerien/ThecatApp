
import Foundation

enum APIEndpoint {
    case breeds
    case imageById(String)
    case breedImages(String)
    
    var apiKey: String {
        "live_UPbDT8TFCb3EN8RZvMatE9bRiA4tpceOkw8wOQX0bKr3HTuWCWM20bIBPx41QPQa"
    }
    
    var baseURL: String {
        "https://api.thecatapi.com/v1"
    }
    
    var path: String {
        switch self {
        case .breeds:
            return "/breeds"
        case .imageById(let id):
            return "/images/\(id)"
        case .breedImages(let breedId):
            return "/images/search?breed_ids=\(breedId)&limit=10"
        }
    }
    
    var url: URL? {
        URL(string: baseURL + path)
    }
}
