//
//  CacheConfigurationProtocol.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import Foundation

/// Протокол конфигурации кэша
protocol CacheConfigurationProtocol {
    var maxMemoryCount: Int { get }
    var maxMemorySize: Int { get }
}

/// Стандартная конфигурация кэша
struct DefaultCacheConfiguration: CacheConfigurationProtocol {
    let maxMemoryCount = 100
    let maxMemorySize = 50 * 1024 * 1024
}

