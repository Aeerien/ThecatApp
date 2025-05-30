
import UIKit

// Base protocol for all ViewModels
protocol BaseViewModelProtocol: AnyObject {
    associatedtype State
    var state: State { get }
}

// Protocol for the breed list ViewModel
protocol BreedListViewModelProtocol: BaseViewModelProtocol {
    var breeds: [Breed] { get }
    var breedsCount: Int { get }
    var hasBreeds: Bool { get }
    
    func fetchBreeds() async
    func breed(at index: Int) -> Breed
    func isValidIndex(_ index: Int) -> Bool
    func findBreed(by id: String) -> Breed?
    func sortByName()
}

// Protocol for the breed detail ViewModel
protocol BreedDetailViewModelProtocol: BaseViewModelProtocol {
    var breed: Breed? { get }
    var breedImage: UIImage? { get }
    
    func setBreed(_ breed: Breed)
}

// Delegate for updating the UI when changes occur in the BreedDetailViewModel
protocol BreedDetailViewModelDelegate: AnyObject {
    func didStartLoadingImage()
    func didUpdateBreedImage()
    func didReceiveError(_ error: Error)
}

// Protocol for the photo gallery ViewModel
protocol PhotoGalleryViewModelProtocol: BaseViewModelProtocol {
    var photos: [BreedImage] { get }
    
    func loadNextPage() async
}
