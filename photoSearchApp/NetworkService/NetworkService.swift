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

    func resetPagination() {
        page = 1
    }
    
    func sendRequest(keyword: String, completion: @escaping(Result<[JasonResult]?, NetworkError>)-> Void) {
        let apiKey = "RlyVw9SVOKmK9GNS9i5Db8Pxa47-ZfZBDYTP5dERbgo"
        let perPage = "30"
        let url = "https://api.unsplash.com/search/photos?page=\(page)&per_page=\(perPage)&query=\(keyword)&client_id=\(apiKey)"
        
        guard let urlString = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: urlString) { [weak self] (data, _, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.networkError(string: "Error making api call. \(error.debugDescription)")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIResponse.self, from: data)
                self?.page += 1
                completion(.success(result.results))
                
            } catch {
                completion(.failure(NetworkError.jsonParsing(string: "Error decoding JASON response.\(error)")))
            }
        }
        task.resume()
    }
}
