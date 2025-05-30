
import UIKit

protocol BreedImageContainerViewDelegate: AnyObject {
    func retryButtonTapped()
}

final class BreedImageContainerView: UIView {
    weak var delegate: BreedImageContainerViewDelegate?
    
    private let placeholderImage: UIImage = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        return UIImage(systemName: "photo", withConfiguration: configuration) ?? UIImage()
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = placeholderImage
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry loading", for: .normal)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        
        addSubview(imageView)
        addSubview(activityIndicator)
        addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc private func retryTapped() {
        delegate?.retryButtonTapped()
    }
    
    func startLoading() {
        imageView.image = placeholderImage
        imageView.contentMode = .center
        activityIndicator.startAnimating()
        retryButton.isHidden = true
    }
    
    func showError() {
        activityIndicator.stopAnimating()
        retryButton.isHidden = false
        
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve) {
            self.imageView.contentMode = .center
            self.imageView.image = self.placeholderImage
        }
    }
    
    func showImage(_ image: UIImage) {
        activityIndicator.stopAnimating()
        retryButton.isHidden = true
        
        UIView.transition(with: imageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve) {
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.image = image
        }
    }
}
