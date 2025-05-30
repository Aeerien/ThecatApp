
import UIKit

final class BreedDetailViewController: UIViewController {
    private let viewModel: BreedDetailViewModel
    
    weak var navigationDelegate: BreedDetailNavigationDelegate?
    
    private lazy var placeholderImage: UIImage = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        return UIImage(systemName: "photo", withConfiguration: configuration) ?? UIImage()
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var breedImageContainer: BreedImageContainerView = {
        let view = BreedImageContainerView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var energyLevelView = StatView(title: "Energy")
    private lazy var intelligenceView = StatView(title: "Intelligence")
    
    private lazy var wikiButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Wikipedia", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(wikiButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var photosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Watch photos", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(photosButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateView = EmptyStateView()
    
    init(viewModel: BreedDetailViewModel) {
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
        updateEmptyState(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        view.addSubview(emptyStateView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(breedImageContainer)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(wikiButton)
        contentView.addSubview(photosButton)
        
        statsStackView.addArrangedSubview(energyLevelView)
        statsStackView.addArrangedSubview(intelligenceView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            breedImageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            breedImageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            breedImageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            breedImageContainer.heightAnchor.constraint(equalTo: breedImageContainer.widthAnchor, multiplier: 0.75),
            
            nameLabel.topAnchor.constraint(equalTo: breedImageContainer.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            wikiButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            wikiButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            photosButton.topAnchor.constraint(equalTo: wikiButton.bottomAnchor, constant: 8),
            photosButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photosButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func wikiButtonTapped() {
        guard let urlString = viewModel.breed?.wikipediaUrl,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func photosButtonTapped() {
        guard let breed = viewModel.breed else { return }
        navigationDelegate?.showGallery(for: breed.id, title: breed.name)
    }
    
    private func updateUI() {
        guard let breed = viewModel.breed else { return }
        nameLabel.text = breed.name
        descriptionLabel.text = breed.description
        energyLevelView.setValue(breed.energyLevel ?? 0)
        intelligenceView.setValue(breed.intelligence ?? 0)
    }
    
    private func updateEmptyState(_ show: Bool) {
        emptyStateView.isHidden = !show
        scrollView.isHidden = show
    }
    
    private func retryImageLoad() {
        guard let breed = viewModel.breed else { return }
        viewModel.setBreed(breed)
    }
}

extension BreedDetailViewController: BreedListViewControllerDelegate {
    func breedListViewController(_ controller: BreedListViewController, didSelectBreed breed: Breed) {
        updateEmptyState(false)
        viewModel.setBreed(breed)
        updateUI()
    }
}

extension BreedDetailViewController: BreedDetailViewModelDelegate {
    func didStartLoadingImage() {
        breedImageContainer.startLoading()
    }
    
    func didUpdateBreedImage() {
        guard let image = viewModel.breedImage else {
            breedImageContainer.showError()
            return
        }
        breedImageContainer.showImage(image)
    }
    
    func didReceiveError(_ error: Error) {
        breedImageContainer.showError()
        AlertPresenter.showError(error, on: self)
    }
}

extension BreedDetailViewController: BreedImageContainerViewDelegate {
    func retryButtonTapped() {
        guard let breed = viewModel.breed else { return }
        viewModel.setBreed(breed)
    }
}
