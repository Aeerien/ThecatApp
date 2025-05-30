
import UIKit

final class EmptyStateView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        imageView.image = UIImage(systemName: "pawprint.circle", withConfiguration: configuration)
        imageView.tintColor = .systemGray3
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select a cat breed from the list"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        
        addSubview(imageView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
