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

    var imageURL: URL? { URL(string: article.imageUrl) }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: article.publishedAt, relativeTo: Date())
    }
}
