//
//  PhotoCell.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

protocol PhotoCellDelegate: AnyObject {
    func photoCellDidTapRetry(_ cell: PhotoCell)
}

final class PhotoCell: UICollectionViewCell {
    private lazy var placeholderImage: UIImage = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        return UIImage(systemName: "photo", withConfiguration: configuration) ?? UIImage()
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = placeholderImage
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Повторить", for: .normal)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentImageUrl: String?
    private var loadingTask: Task<Void, Never>?
    private let imageLoader: ImageLoaderServiceProtocol
    weak var delegate: PhotoCellDelegate?
    
    init(imageLoader: ImageLoaderServiceProtocol = ImageLoaderService()) {
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        self.imageLoader = ImageLoaderService()
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        loadingTask?.cancel()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with url: String) {
        currentImageUrl = url
        showPlaceholder()
        activityIndicator.startAnimating()
        
        loadingTask?.cancel()
        loadingTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                let image = try await imageLoader.loadImage(from: url)
                await MainActor.run {
                    guard self.currentImageUrl == url else { return }
                    self.showImage(image)
                }
            } catch {
                await MainActor.run {
                    guard self.currentImageUrl == url else { return }
                    self.showError()
                }
            }
        }
    }
    
    private func showPlaceholder() {
        imageView.contentMode = .center
        imageView.image = placeholderImage
        retryButton.isHidden = true
    }
    
    private func showImage(_ image: UIImage) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        activityIndicator.stopAnimating()
        retryButton.isHidden = true
    }
    
    private func showError() {
        imageView.contentMode = .center
        imageView.image = placeholderImage
        activityIndicator.stopAnimating()
        retryButton.isHidden = false
    }
    
    @objc private func retryButtonTapped() {
        if let url = currentImageUrl {
            configure(with: url)
        }
        delegate?.photoCellDidTapRetry(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingTask?.cancel()
        loadingTask = nil
        currentImageUrl = nil
        imageView.contentMode = .center
        imageView.image = placeholderImage
        activityIndicator.stopAnimating()
        retryButton.isHidden = true
    }
}

