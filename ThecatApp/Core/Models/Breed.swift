
import Foundation

struct Breed: Codable {
    let id: String
    let name: String
    let description: String
    let energyLevel: Int?
    let intelligence: Int?
    let wikipediaUrl: String?
    let referenceImageId: String?
    
    var imageId: String? {
        referenceImageId
    }
}

