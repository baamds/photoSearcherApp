//
//  NetworkService.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//

import Foundation


class NetworkService {
    
    static let shared = NetworkService()
    var page = 1
    
    func sendRequest(keyword: String, completion: @escaping(Result<[JasonResult]?, NetworkError>)-> Void) {
        let apiKey = "tYfYoUXHNfDpZQFA-mqKcgxYy5V4Ql6Kvomv1vRl-3ddemoqBaG890i1-OOY"
        let perPage = "30"
        let url = "https://api.unsplash.com/search/photos?page=\(page)&per_page=\(perPage)&query=\(keyword)&client_id=\(apiKey)"
        // "https://api.unsplash.com/search/photos?page=1&per_page=10&query=people&client_id=mqKcgxYy5V4Ql6Kvomv1vRl-3ddemoqBaG890i1-OOY"
        
        guard let urlString = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { [weak self] (data, _, error) in
            guard let data = data, error == nil else { return }
            do {
                let jasonResult = try JSONDecoder().decode(APIResponse.self, from: data)
            } catch {
                print(error)
            }
          
            
        }
        task.resume()
    }
    
    
    
}
