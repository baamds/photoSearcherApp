//
//  ViewController.swift
//  photo-search
//
//  Created by Amir Bakhshi on 2026-07-29.
//
// "https://api.unsplash.com/search/photos?page=1&per_page=10&query=people&client_id=mqKcgxYy5V4Ql6Kvomv1vRl-3ddemoqBaG890i1-OOY"

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    var results: [JasonResult] = []
    private var collectionView: UICollectionView?
    var query = "people"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        fetchPhotos(from: query)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        
    }
    
 // MARK: - Networking ======================================================
    
    func fetchPhotos(from keyword: String) {
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
}
// MARK: UIConfiguration ==========================================================
extension MainViewController {
    private func configureView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width - 20,
                                 height: view.frame.size.width/2)
        
        let collectionVeiw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionVeiw.register(UINib(nibName: PhotoCell.identifier,
                                      bundle: nil),
                                forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionVeiw.dataSource = self
        collectionVeiw.delegate = self
        
        view.addSubview(collectionVeiw)
        self.collectionView = collectionVeiw
    }
}

// MARK: UICollectionView Methods ====================================================
extension MainViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = results[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        // Configure the cell here if needed, e.g., pass imageURLString to it
        // cell.configure(with: imageURLString)
        
        cell.configure(with: photo)
        return cell
    }
}
