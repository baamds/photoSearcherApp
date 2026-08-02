//
//  APIResponse.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-07-31.
//


import Foundation


struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [JasonResult]
}

struct JasonResult: Codable {
    let id: String
    let likes: Int
    let color: String
    let user: User
    let urls: URLS
}

struct URLS: Codable {
    let raw: String
    let regular: String
    let small: String
}

struct User: Codable {
    let id: String
    let name: String
    let username: String
    let profile_image: ProfileImage
    var location: String?
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
