//
//  ArticleDetailViewModel.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation

enum ArticleDetailState {
    case idle
    case loading
    case loaded(Article)
    case error(String)
}

final class ArticleDetailViewModel {

    private(set) var article: Article
    private let service: ArticleServiceProtocol

    var onStateChange: ((ArticleDetailState) -> Void)?
    var onArticleUpdated: (() -> Void)?

    init(article: Article, service: ArticleServiceProtocol = ArticleService.shared) {
        self.article = article
        self.service = service
    }

    var articleId: Int { article.id }
    var title: String { article.title }
    var newsSite: String { article.newsSite.uppercased() }
    var summary: String { article.summary }
    var articleURL: URL? { URL(string: article.url) }

    /// Sanitizes raw URL strings to use https:// so App Transport Security (ATS) doesn't block loading
    var imageURL: URL? {
        let rawUrl = article.imageUrl
        guard !rawUrl.isEmpty else { return nil }
        if rawUrl.hasPrefix("http://") {
            let secureUrl = rawUrl.replacingOccurrences(of: "http://", with: "https://")
            return URL(string: secureUrl)
        }
        return URL(string: rawUrl)
    }

    var authorName: String {
        article.authors.first?.name ?? article.newsSite
    }

    var formattedPublishedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: article.publishedAt)
    }

    var authorInitials: String {
        let name = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = name.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last = parts[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let firstChar = name.first {
            return String(firstChar).uppercased()
        }
        return "N"
    }

    /// Calls API GET /v4/articles/{id}/ to fetch detailed info for the current article
    func fetchArticleDetails() {
        onStateChange?(.loading)
        
//        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        print("FETCHING ARTICLE DETAIL FOR ID: \(article.id)")
//        print("Endpoint: https://api.spaceflightnewsapi.net/v4/articles/\(article.id)/")
//        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        service.fetchArticle(id: article.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fullArticle):
                self.article = fullArticle
                self.onStateChange?(.loaded(fullArticle))
                self.onArticleUpdated?()
            case .failure(let error):
                // If the detail endpoint fails, gracefully keep using the pre-loaded summary article from the list
                self.onStateChange?(.error(error.errorDescription))
            }
        }
    }
}
