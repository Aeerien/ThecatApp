//
//  ViewModelProtocols.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

/// Базовый протокол для всех ViewModel
protocol BaseViewModelProtocol: AnyObject {
    associatedtype State
    var state: State { get }
}

/// Протокол для ViewModel списка пород
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

/// Протокол для ViewModel детальной информации о породе
protocol BreedDetailViewModelProtocol: BaseViewModelProtocol {
    var breed: Breed? { get }
    var breedImage: UIImage? { get }

    func setBreed(_ breed: Breed)
}

/// Делегат для обновления UI при изменениях в BreedDetailViewModel
protocol BreedDetailViewModelDelegate: AnyObject {
    func didStartLoadingImage()
    func didUpdateBreedImage()
    func didReceiveError(_ error: Error)
}

/// Протокол для ViewModel галереи фотографий
protocol PhotoGalleryViewModelProtocol: BaseViewModelProtocol {
    var photos: [BreedImage] { get }

    func loadNextPage() async
}

