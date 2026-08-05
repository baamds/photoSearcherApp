//
//  ViewController.swift
//  photo-search
//
//  Created by Amir Bakhshi on 2026-07-29.
//


import UIKit
import Combine

class MainViewController: UIViewController {
    
    
    var results: [JasonResult] = []
    private var collectionView: UICollectionView?
    private let searchBar = UISearchBar()
    private var cancellables = Set<AnyCancellable>()
    
    var query = "people"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        configureView()
        bindSearchBar()
        fetchPhotos(from: query)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0,
                                       y: view.safeAreaInsets.top + 55,
                                       width: view.frame.size.width,
                                       height: view.frame.size.height - 55)
        searchBar.frame = CGRect(x: 10,
                                 y: view.safeAreaInsets.top,
                                 width: view.frame.size.width - 20,
                                 height: 50)
    }
}

// MARK: - Networking ======================================================
extension MainViewController {
    private func fetchPhotos(from keyword: String) {
        NetworkService.shared.sendRequest(keyword: keyword) { [weak self] result in
            switch result {
            case .success(let results):
                guard let results = results else { return }
                DispatchQueue.main.async {
                    self?.results = results
                    self?.collectionView?.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchNextBatch(from keyword: String) {
        NetworkService.shared.sendRequest(keyword: keyword, completion: { [weak self] result in
            switch result {
            case .success(let results):
                guard let results = results else { return }
                DispatchQueue.main.async {
                    self?.results.append(contentsOf: results)
                    self?.collectionView?.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
// MARK: UIConfiguration ==========================================================
extension MainViewController {
    
    /// Turns typing in the search bar into a debounced Combine stream.
    /// This avoids an API request for every character the user types.
    private func bindSearchBar() {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: searchBar.searchTextField
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .debounce(for: .milliseconds(450), scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { [weak self] keyword in
            self?.search(for: keyword)
        }
        .store(in: &cancellables)
    }
    
    private func search(for keyword: String) {
        guard keyword != query else { return }
        
        query = keyword
        NetworkService.shared.resetPagination()
        results.removeAll()
        collectionView?.reloadData()
        fetchPhotos(from: keyword)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func configureView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width - 20,
                                 height: view.frame.size.width/2)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UINib(nibName: PhotoCell.identifier,
                                      bundle: nil),
                                forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        searchBar.placeholder = "Type here ..."
        self.collectionView = collectionView
    }
}

// MARK: UICollectionView Methods ====================================================
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = results[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == results.count - 12 {
            fetchNextBatch(from: query)
        }
    }
}
