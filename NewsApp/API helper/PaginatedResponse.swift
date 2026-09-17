//
//  PaginatedResponse.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

struct PaginatedResponse<T: Sendable>: Sendable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}

extension PaginatedResponse: nonisolated Decodable where T: Decodable {
}
