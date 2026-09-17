//
//  Article.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

struct Article: Equatable, Sendable {
    let id: Int
    let title: String
    let authors: [Author]
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: Date
    let updatedAt: Date?
    let featured: Bool
    let launches: [Launch]
    let events: [Event]
}

extension Article: nonisolated Decodable {
    enum CodingKeys: String, CodingKey {
        case id, title, authors, url
        case imageUrl = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case featured, launches, events
    }
}

struct Author: Decodable, Equatable, Sendable {
    let name: String
}

struct Launch: Decodable, Equatable, Sendable {
    let launchId: String
    let provider: String

    enum CodingKeys: String, CodingKey {
        case launchId = "launch_id"
        case provider
    }
}

struct Event: Decodable, Equatable, Sendable {
    let eventId: Int
    let provider: String

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case provider
    }
}
