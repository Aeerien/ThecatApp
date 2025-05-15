//
//  MainViewController.swift
//  ThecatApp
//
//  Created by Irina Arkhireeva on 15.05.2025.
//

import UIKit

final class MainViewController: UIViewController {
    private let breedListViewController: BreedListViewController
    let breedDetailViewController: BreedDetailViewController
    
    private lazy var splitView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var listWidthConstraint: NSLayoutConstraint?
    private let minWidth: CGFloat = 150
    private var maxWidth: CGFloat {
        return view.bounds.width - minWidth
    }
    private var initialListWidth: CGFloat = 0
    private var lastNonMinimumWidth: CGFloat = 300

    init(breedListViewController: BreedListViewController,
         breedDetailViewController: BreedDetailViewController) {
        self.breedListViewController = breedListViewController
        self.breedDetailViewController = breedDetailViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        setupGestures()
        
        navigationItem.title = "Породы кошек"
        
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            ImageCacheManager.shared.printCacheStatus()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCacheManager.shared.clearCache()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let currentWidth = listWidthConstraint?.constant ?? 200
        let currentProportion = currentWidth / view.bounds.width
        
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            
            let newWidth = size.width * currentProportion
            
            if newWidth < self.minWidth {
                self.listWidthConstraint?.constant = self.minWidth
            } else if newWidth > (size.width - self.minWidth) {
                self.listWidthConstraint?.constant = size.width - self.minWidth
            } else {
                self.listWidthConstraint?.constant = newWidth
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        addChild(breedListViewController)
        addChild(breedDetailViewController)
        
        view.addSubview(splitView)
        
        splitView.addArrangedSubview(breedListViewController.view)
        splitView.addArrangedSubview(dividerView)
        splitView.addArrangedSubview(breedDetailViewController.view)
        
        breedListViewController.didMove(toParent: self)
        breedDetailViewController.didMove(toParent: self)
        
        let grabberView = createGrabberView()
        dividerView.addSubview(grabberView)
        grabberView.centerXAnchor.constraint(equalTo: dividerView.centerXAnchor).isActive = true
        grabberView.centerYAnchor.constraint(equalTo: dividerView.centerYAnchor).isActive = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splitView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            splitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splitView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dividerView.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        let initialWidth = view.bounds.width * 0.3 // 30% от ширины экрана
        listWidthConstraint = breedListViewController.view.widthAnchor.constraint(equalToConstant: initialWidth)
        listWidthConstraint?.isActive = true
    }
    
    private func setupDelegates() {
        breedListViewController.delegate = breedDetailViewController
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        dividerView.addGestureRecognizer(panGesture)
        dividerView.isUserInteractionEnabled = true
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        dividerView.addGestureRecognizer(doubleTapGesture)
    }
    
    private func createGrabberView() -> UIView {
        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = .systemGray3
        grabber.layer.cornerRadius = 2
        
        NSLayoutConstraint.activate([
            grabber.widthAnchor.constraint(equalToConstant: 4),
            grabber.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return grabber
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialListWidth = listWidthConstraint?.constant ?? 200
            animateDividerHighlight(highlighted: true)
            
        case .changed:
            let translation = gesture.translation(in: view)
            var newWidth = initialListWidth + translation.x
            newWidth = max(minWidth, min(newWidth, maxWidth))
            
            if newWidth > minWidth {
                lastNonMinimumWidth = newWidth // Сохраняем последнюю не минимальную ширину
            }
            
            UIView.animate(withDuration: 0.1) {
                self.listWidthConstraint?.constant = newWidth
                self.view.layoutIfNeeded()
            }
            
        case .ended, .cancelled:
            animateDividerHighlight(highlighted: false)
            
            let currentWidth = listWidthConstraint?.constant ?? 200
            if currentWidth < minWidth + 20 {
                animateToWidth(minWidth)
            } else if currentWidth > maxWidth - 20 {
                animateToWidth(maxWidth)
            }
            
        default:
            break
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let currentWidth = listWidthConstraint?.constant ?? 200
        
        if currentWidth <= minWidth {
            animateToWidth(lastNonMinimumWidth)
        } else {
            lastNonMinimumWidth = currentWidth
            animateToWidth(minWidth)
        }
    }
    
    private func animateDividerHighlight(highlighted: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.dividerView.backgroundColor = highlighted ? .systemBlue : .systemGray4
            self.dividerView.transform = highlighted ? CGAffineTransform(scaleX: 1.2, y: 1) : .identity
        }
    }
    
    private func animateToWidth(_ width: CGFloat) {
        UIView.animate(withDuration: 0.3,
                      delay: 0,
                      usingSpringWithDamping: 0.8,
                      initialSpringVelocity: 0.2,
                      options: .curveEaseOut) {
            self.listWidthConstraint?.constant = width
            self.view.layoutIfNeeded()
        }
    }
}

