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
    let name: String
    let username: String
    var location: String?
    let profile_image: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
