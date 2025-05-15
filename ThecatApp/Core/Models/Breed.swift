//
//  Breed.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import Foundation

/// Модель породы кошки
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

