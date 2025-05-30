
import Foundation

// Protocol for the network service
protocol APIServiceProtocol {
    // Performs an API request and decodes the response
    func fetch<T: Decodable>(endpoint: APIEndpoint) async throws -> T
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data processing error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
}

//Service for interacting with the API
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

