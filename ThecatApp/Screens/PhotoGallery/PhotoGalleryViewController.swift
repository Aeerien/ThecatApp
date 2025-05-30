
import UIKit

final class PhotoGalleryViewController: UIViewController {
    private let viewModel: PhotoGalleryViewModel
    private var isLoading = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.prefetchDataSource = self
        return collection
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var loadingFooter: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(viewModel: PhotoGalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        viewModel.delegate = self
        loadInitialPhotos()
    }
    
    private func setupUI() {
        title = "Photos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeButtonTapped))
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(loadingFooter)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingFooter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingFooter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loadingFooter.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func loadInitialPhotos() {
        activityIndicator.startAnimating()
        viewModel.loadNextPage()
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension PhotoGalleryViewController: UICollectionViewDataSource,
                                      UICollectionViewDelegate,
                                      UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                            for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        let photo = viewModel.photos[indexPath.item]
        cell.configure(with: photo.url)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > contentHeight - height * 2 && !isLoading {
            isLoading = true
            loadingFooter.startAnimating()
            viewModel.loadNextPage()
        }
    }
}

extension PhotoGalleryViewController: PhotoGalleryViewModelDelegate {
    func didUpdatePhotos() {
        activityIndicator.stopAnimating()
        isLoading = false
        loadingFooter.stopAnimating()
        collectionView.reloadData()
    }
    
    func didReceiveError(_ error: Error) {
        activityIndicator.stopAnimating()
        isLoading = false
        loadingFooter.stopAnimating()
        AlertPresenter.showError(error, on: self)
    }
}

extension PhotoGalleryViewController: PhotoCellDelegate {
    func photoCellDidTapRetry(_ cell: PhotoCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let photo = viewModel.photos[indexPath.item]
        cell.configure(with: photo.url)
    }
}

extension PhotoGalleryViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { indexPath -> String? in
            guard indexPath.item < viewModel.photos.count else { return nil }
            return viewModel.photos[indexPath.item].url
        }
        viewModel.prefetchImages(urls: urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { indexPath -> String? in
            guard indexPath.item < viewModel.photos.count else { return nil }
            return viewModel.photos[indexPath.item].url
        }
        viewModel.cancelPrefetching(urls: urls)
    }
}
