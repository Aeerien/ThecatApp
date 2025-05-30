
import Foundation

// Delegate for updating the UI when the breed list changes
protocol BreedListViewModelDelegate: AnyObject {
    func didUpdateBreeds()
    func didReceiveError(_ error: Error)
}

// ViewModel for managing the list of cat breeds
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
    
    // Creates a ViewModel with the specified API service
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    // Loads the list of breeds
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
    
    // Returns a breed by index from the breeds array
    func breed(at index: Int) -> Breed {
        return breeds[index]
    }
    
    // Checks if the index is valid for the breeds array
    func isValidIndex(_ index: Int) -> Bool {
        breeds.indices.contains(index)
    }
    
    // Finds a breed by its ID
    func findBreed(by id: String) -> Breed? {
        breeds.first { $0.id == id }
    }
    
    // Sorts breeds by name
    func sortByName() {
        breeds.sort { $0.name < $1.name }
        delegate?.didUpdateBreeds()
    }
}
