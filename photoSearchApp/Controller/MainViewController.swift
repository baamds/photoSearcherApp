//
//  ViewController.swift
//  photo-search
//
//  Created by Amir Bakhshi on 2026-07-29.
//


import UIKit

class MainViewController: UIViewController {
    
    
    var results: [JasonResult] = []
    private var collectionView: UICollectionView?
    private let searchBar = UISearchBar()
    
    var query = "people"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        configureView()
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            query = text
            results.removeAll()
            collectionView?.reloadData()
            fetchPhotos(from: text)
        }
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
        searchBar.placeholder = "Search here ..."
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
