//
//  ImageProvider.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//

import UIKit

class ImageProvider {
    
    static let shared = ImageProvider()
    
    private let cache = NSCache<NSString, UIImage>()
    
    public func fetchImage(url: String, completion: @escaping (UIImage?) -> Void) {
        if let image = cache.object(forKey: url as NSString) {
            // print("From cache ...")
            completion(image)
            return
        }
        
        guard let urlString = URL(string: url) else { return }
        // print("Fetching image from api ...")
        let task = URLSession.shared.dataTask(with: urlString) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
                
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                
                // Caching ...
                self?.cache.setObject(image, forKey: url as NSString)
                completion(image)
            }
        }
        task.resume()
    }
}
