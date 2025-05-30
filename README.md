# 🐱 TheCatApp

TheCatApp is an iOS application written in Swift using the MVVM + Coordinator architecture. The app
allows users to browse cat breeds, view breed details, and see breed photo galleries. It implements
image caching to boost performance. Special focus is given to modularity, reusable UI components,
and clean architecture.

---

## 🚀 Key Features

- Fetch a list of cat breeds and their details
- View image galleries for each breed
- Image caching using a custom `ImageCacheManager`
- Image loading handled via `ImageLoaderService`
- MVVM + Coordinator architecture
- Support for empty states
- Reusable and adaptive UI components

---

## 📁 Project Structure

```
TheCatApp/
│
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Navigation/
│       ├── AppCoordinator.swift
│       ├── MainCoordinator.swift
│       └── Coordinator.swift
│
├── Core/
│   ├── Cache/
│   │   └── ImageCacheManager.swift
│   ├── Helpers/
│   │   └── AlertPresenter.swift
│   ├── Models/
│   │   ├── Breed.swift
│   │   └── BreedImage.swift
│   ├── Network/
│   │   ├── APIEndpoint.swift
│   │   └── APIService.swift
│   ├── Protocols/
│   │   ├── CacheConfigurationProtocol.swift
│   │   └── CacheServiceProtocol.swift
│   └── Services/
│       └── ImageLoaderService.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── Info.plist
│
├── Screens/
│   ├── BreedDetail/
│   │   ├── BreedDetailViewController.swift
│   │   └── BreedDetailViewModel.swift
│   ├── BreedList/
│   │   ├── BreedListViewController.swift
│   │   └── BreedListViewModel.swift
│   ├── Common/
│   │   ├── BreedImageContainerView.swift
│   │   ├── EmptyStateView.swift
│   │   ├── PhotoCell.swift
│   │   └── StatView.swift
│   ├── Main/
│   │   ├── MainViewController.swift
│   │   └── ViewControllerFactory.swift
│   └── PhotoGallery/
│       └── PhotoGalleryViewController.swift
```

---

## 🛠 Technologies Used

- Swift 5
- UIKit
- MVVM + Coordinator
- URLSession
- NSCache
- Custom Image Caching Implementation
- REST API

---

## 📦 Getting Started

1. Clone the repository:

```bash
git clone https://github.com/Aeerien/TheCatApp.git
```

2. Open `.xcodeproj` or `.xcworkspace` in Xcode (version 14.0+)

3. Build and run on simulator or real device.

---

## 📸 Screenshots

<img src="https://github.com/user-attachments/assets/22173fd5-23ea-4993-b29c-3281ca048647" width="150"/>
<img src="https://github.com/user-attachments/assets/12f82285-02b4-44ca-80c0-fb9864fdb66e" width="150"/>
<img src="https://github.com/user-attachments/assets/8cbd8ffc-7982-44e6-865f-2ed7fbd69fc5" width="150"/>
<img src="https://github.com/user-attachments/assets/e4ec5383-e225-4d7c-950d-cdbf5843a3f5" width="150"/>
