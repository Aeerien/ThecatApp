//
//  BreedImage.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import Foundation

/// Модель изображения породы
struct BreedImage: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}

