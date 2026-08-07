//
//  NetworkService.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//

import Foundation

protocol PhotoSearching {
    func searchPhotos(keyword: String, page: Int, completion: @escaping (Result<[JasonResult], NetworkError>) -> Void)
}

final class NetworkService: PhotoSearching {

    static let shared = NetworkService()

    private enum Constants {
        static let accessKey = ""
        static let resultsPerPage = 30
    }
    
    // what the @escaping means:  The closure may be called after searchPhotos returns (i.e., it “escapes” the function’s lifetime).
    // This is required because the network request is asynchronous and completes later.
    func searchPhotos(keyword: String, page: Int, completion: @escaping (Result<[JasonResult], NetworkError>) -> Void) {
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(Constants.resultsPerPage)),
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL(string: "Couldn't create a valid URL from the provided components.")))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.networkError(string: error?.localizedDescription ?? "No response data.")))
                return
            }

//            guard let httpResponse = response as? HTTPURLResponse,
//                  200..<300 ~= httpResponse.statusCode else {
//                completion(.failure(.networkError(string: "The server returned an invalid response.")))
//                return
//            }

            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data).results
                completion(.success(jsonResult))
            } catch {
                completion(.failure(.jsonParsing(string: error.localizedDescription)))
            }
        }.resume()
    }
}
