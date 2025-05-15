//
//  APIService.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import Foundation

/// Протокол сетевого сервиса
protocol APIServiceProtocol {
    /// Выполняет запрос к API и декодирует ответ
    func fetch<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}

/// Ошибки API
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Ошибка обработки данных: \(error.localizedDescription)"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        }
    }
}

/// Сервис для работы с API
final class APIService: APIServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = session
    }
    
    func fetch<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(endpoint.apiKey, forHTTPHeaderField: "x-api-key")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw APIError.noInternetConnection
            }
            throw APIError.networkError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

