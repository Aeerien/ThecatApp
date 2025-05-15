//
//  BreedListViewModel.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import Foundation

/// Делегат для обновления UI при изменениях в списке пород
protocol BreedListViewModelDelegate: AnyObject {
    func didUpdateBreeds()
    func didReceiveError(_ error: Error)
}

/// ViewModel для управления списком пород кошек
final class BreedListViewModel: BreedListViewModelProtocol {
    typealias State = BreedListState
    
    enum BreedListState {
        case initial
        case loading
        case loaded
        case error(Error)
    }
    
    private(set) var state: State = .initial
    private let apiService: APIServiceProtocol
    private(set) var breeds: [Breed] = []
    weak var delegate: BreedListViewModelDelegate?
    
    var breedsCount: Int {
        breeds.count
    }
    
    var hasBreeds: Bool {
        !breeds.isEmpty
    }

    private var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    /// Создает ViewModel с указанным API сервисом
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    /// Загружает список пород
    func fetchBreeds() {
        guard !isLoading else { return }
        
        state = .loading
        Task {
            do {
                let breeds: [Breed] = try await apiService.fetch(endpoint: .breeds)
                if !Task.isCancelled {
                    await MainActor.run {
                        self.breeds = breeds
                        self.state = .loaded
                        self.delegate?.didUpdateBreeds()
                    }
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.state = .error(error)
                        self.delegate?.didReceiveError(error)
                    }
                }
            }
        }
    }
    
    /// Возвращает породу по индексу из массива breeds
    func breed(at index: Int) -> Breed {
        return breeds[index]
    }
    
    /// Проверяет, является ли индекс допустимым для массива пород
    func isValidIndex(_ index: Int) -> Bool {
        breeds.indices.contains(index)
    }
    
    /// Поиск породы по ID
    func findBreed(by id: String) -> Breed? {
        breeds.first { $0.id == id }
    }
    
    /// Сортирует породы по имени
    func sortByName() {
        breeds.sort { $0.name < $1.name }
        delegate?.didUpdateBreeds()
    }
}

