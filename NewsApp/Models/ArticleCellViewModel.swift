//
//  ArticleCellViewModel.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

struct ArticleCellViewModel {

    let article: Article

    var title: String { article.title }

    var source: String { article.newsSite.uppercased() }

    var authorName: String { article.authors.first?.name ?? article.newsSite }

    /// Upgrades http:// to https:// to comply with ATS policy
    var imageURL: URL? {
        let rawUrl = article.imageUrl
        guard !rawUrl.isEmpty else { return nil }
        if rawUrl.hasPrefix("http://") {
            let secureUrl = rawUrl.replacingOccurrences(of: "http://", with: "https://")
            return URL(string: secureUrl)
        }
        return URL(string: rawUrl)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: article.publishedAt, relativeTo: Date())
    }

    var authorInitials: String {
        let name = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = name.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else if let firstChar = name.first {
            return String(firstChar).uppercased()
        }
        return "N"
    }
}
