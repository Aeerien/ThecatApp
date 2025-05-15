//
//  CacheServiceProtocol.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Протокол сервиса кэширования
protocol CacheServiceProtocol {
    func getImage(for key: String) -> UIImage?
    func saveImage(_ image: UIImage, for key: String)
    func removeImage(for key: String)
    func clearCache()
    func getCacheInfo() -> (memoryCount: Int, diskSize: String)
}

