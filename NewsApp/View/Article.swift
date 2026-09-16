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
    let featured: Bool

    init(
        id: Int,
        title: String,
        authors: [Author],
        url: String,
        imageUrl: String,
        newsSite: String,
        summary: String,
        publishedAt: Date,
        featured: Bool
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.url = url
        self.imageUrl = imageUrl
        self.newsSite = newsSite
        self.summary = summary
        self.publishedAt = publishedAt
        self.featured = featured
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

extension Article: nonisolated Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case authors
        case url
        case imageUrl = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case featured
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)

        authors = try container.decodeIfPresent(
            [Author].self,
            forKey: .authors
        ) ?? []

        url = try container.decode(String.self, forKey: .url)

        imageUrl = try container.decodeIfPresent(
            String.self,
            forKey: .imageUrl
        ) ?? ""

        newsSite = try container.decode(String.self, forKey: .newsSite)

        summary = try container.decodeIfPresent(
            String.self,
            forKey: .summary
        ) ?? ""

        publishedAt = try container.decode(Date.self, forKey: .publishedAt)

        featured = try container.decodeIfPresent(
            Bool.self,
            forKey: .featured
        ) ?? false
    }
}

struct Author: Decodable, Equatable, Sendable {
    let name: String
}
