//
//  APIInfo.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

struct APIInfo: Sendable {
    let version: String
    let newsSites: [String]
}

extension APIInfo: nonisolated Decodable {
    enum CodingKeys: String, CodingKey {
        case version
        case newsSites = "news_sites"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(
            String.self,
            forKey: .version
        )

        newsSites = try container.decode(
            [String].self,
            forKey: .newsSites
        )
    }
}
