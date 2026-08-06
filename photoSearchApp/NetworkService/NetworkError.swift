//
//  NetworkError.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case networkError(string: String)
    case jsonParsing(string: String)
    case unknown(string : String)
}
