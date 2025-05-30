
import UIKit

protocol BreedListViewControllerDelegate: AnyObject {
    func breedListViewController(_ controller: BreedListViewController, didSelectBreed breed: Breed)
}

final class BreedListViewController: UIViewController {
    weak var delegate: BreedListViewControllerDelegate?
    private let viewModel: BreedListViewModel
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "BreedCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(viewModel: BreedListViewModel) {
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
        loadBreeds()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadBreeds() {
        activityIndicator.startAnimating()
        viewModel.fetchBreeds()
    }
}

extension BreedListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.breeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell", for: indexPath)
        let breed = viewModel.breed(at: indexPath.row)
        cell.textLabel?.text = breed.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breed = viewModel.breed(at: indexPath.row)
        delegate?.breedListViewController(self, didSelectBreed: breed)
    }
}

extension BreedListViewController: BreedListViewModelDelegate {
    func didUpdateBreeds() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
        
        if let firstBreed = viewModel.breeds.first {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            delegate?.breedListViewController(self, didSelectBreed: firstBreed)
        }
    }
    
    func didReceiveError(_ error: Error) {
        activityIndicator.stopAnimating()
        AlertPresenter.showError(error, on: self)
    }
}
