//
//  NetworkService.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//

import Foundation

protocol PhotoSearching {
    // func searchPhotos(keyword: String, page: Int, completion: @escaping (Result<[JasonResult], NetworkError>) -> Void)
    func searchPhotos(keyword:String, page: Int) async throws -> [JasonResult]
}

final class NetworkService: PhotoSearching {

    static let shared = NetworkService()

    private enum Constants {
        static let accessKey = ""
        static let resultsPerPage = 30
    }
    
    // what the @escaping means:  The closure may be called after searchPhotos returns (i.e., it “escapes” the function’s lifetime).
    // This is required because the network request is asynchronous and completes later.
    func searchPhotos(keyword: String, page: Int) async throws -> [JasonResult] {
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(Constants.resultsPerPage)),
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL(string: "Couldn't create a valid URL.")        }
        
        // Built-in async URLSession API — no dataTask closure
               let (data, _) = try await URLSession.shared.data(from: url)
               let response = try JSONDecoder().decode(APIResponse.self, from: data)
               return response.results
    }
}
