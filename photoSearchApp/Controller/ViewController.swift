//
//  ViewController.swift
//  photo-search
//
//  Created by Amir Bakhshi on 2026-07-29.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    
    var page = 1
    let keyword = "people"
    let apiKey = "tYfYoUXHNfDpZQFA-DIifgLw_WLIDgimfCrpI8FUP5E"
    let perPage = "30"
   
    private var collectionView: UICollectionView?
    
    
    var results: [JasonResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        
        let collectionView = UICollectionView(frame:.zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        self.collectionView = collectionView
        collectionView.backgroundColor = .systemBackground
        fetchPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        
    }
    
    
    
    func fetchPhotos() {
        let url = "https://api.unsplash.com/search/photos?page=\(page)&per_page=\(perPage)&query=\(keyword)&client_id=\(apiKey)"
        
        guard let urlString = URL(string: url) else { return }
        
        
        let task = URLSession.shared.dataTask(with: urlString) { (data, response, error) in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async { [weak self] in
                do {
                    let decoder = JSONDecoder()
                    let jasonResult = try decoder.decode(APIResponse.self, from: data)
                    self?.results = jasonResult.results
                    self?.collectionView?.reloadData()
                } catch {
                    print(error)
                }
            }
           
        }
        task.resume()
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = results[indexPath.row].urls.regular
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Configure the cell here if needed, e.g., pass imageURLString to it
        // cell.configure(with: imageURLString)
        
        cell.setup(with: imageURLString)
        return cell
    }
    
    

}


