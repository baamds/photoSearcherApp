//
//  APIResponse.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//


import Foundation


struct APIResponse: Codable {
    let total: String
    let total_pages: String
    let results: [JasonResult]
}

struct JasonResult: Codable {
    let id: String
    let description: String
    let likes: Int
    let user: User
    let urls: URLS
}

struct URLS: Codable {
    let full: String
    let small: String
    let regular: String
}

struct User: Codable {
    let id: String
}
