//
//  ArticleService.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation
internal import Alamofire

protocol ArticleServiceProtocol {

    @discardableResult
    func fetchArticles(
        limit: Int,
        offset: Int,
        newsSite: String?,
        searchQuery: String?,
        completion: @escaping (Result<PaginatedResponse<Article>, NetworkError>) -> Void
    ) -> DataRequest?

    @discardableResult
    func fetchArticle(
        id: Int,
        completion: @escaping (Result<Article, NetworkError>) -> Void
    ) -> DataRequest?

    @discardableResult
    func fetchInfo(
        completion: @escaping (Result<APIInfo, NetworkError>) -> Void
    ) -> DataRequest?
}

/// Talks to https://api.spaceflightnewsapi.net/v4/
final class ArticleService: ArticleServiceProtocol {

    static let shared = ArticleService()

    private let baseURL = "https://api.spaceflightnewsapi.net/v4"
    private let session: Session

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            return DateParser.date(from: dateString)
        }
        return decoder
    }()

    init(session: Session = .default) {
        self.session = session
    }

    @discardableResult
    func fetchArticles(
        limit: Int = 10,
        offset: Int = 0,
        newsSite: String? = nil,
        searchQuery: String? = nil,
        completion: @escaping (Result<PaginatedResponse<Article>, NetworkError>) -> Void
    ) -> DataRequest? {

        var parameters: [String: Any] = [
            "limit": limit,
            "offset": offset,
            "ordering": "-published_at"
        ]

        if let searchQuery, !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["search"] = searchQuery
        }

        if let newsSite, !newsSite.isEmpty {
            parameters["news_site"] = newsSite
        }

//        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        print("ARTICLES API")
//        print("Method: GET")
//        print("Endpoint: \(baseURL)/articles/")
//        print("Request Parameters:")
//        print(parameters)

        return session.request(
            "\(baseURL)/articles/",
            method: .get,
            parameters: parameters
        )
        .validate()
        .responseDecodable(
            of: PaginatedResponse<Article>.self,
            decoder: decoder
        ) { [weak self] response in

            print("⬅️ Response Status Code: \(response.response?.statusCode ?? 0)")

            switch response.result {
            case .success(let value):

//                print("API SUCCESS")
//                print("Total Articles: \(value.count)")
//                print("Articles Received: \(value.results.count)")
//                print("Next Page: \(value.next ?? "nil")")
//                print("Previous Page: \(value.previous ?? "nil")")

//                print("Article List:")

//                for article in value.results {
//                    print("""
//                    ------------------------------
//                    ID: \(article.id)
//                    Title: \(article.title)
//                    Source: \(article.newsSite)
//                    Published: \(article.publishedAt)
//                    Image URL: \(article.imageUrl)
//                    ------------------------------
//                    """)
//                }

            case .failure(let error):

                print("API FAILED")
                print("Error: \(error)")
                print("Underlying Error: \(error.underlyingError?.localizedDescription ?? "nil")")
            }

            self?.handle(response: response, completion: completion)
        }
    }

    @discardableResult
    func fetchArticle(
        id: Int,
        completion: @escaping (Result<Article, NetworkError>) -> Void
    ) -> DataRequest? {
        session.request("\(baseURL)/articles/\(id)/", method: .get)
            .validate()
            .responseDecodable(of: Article.self, decoder: decoder) { [weak self] response in

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//                print("ARTICLE DETAIL API")
//                print("Method: GET")
//                print("Endpoint: \(self?.baseURL)/articles/\(id)/")
//                print("Response Status Code: \(response.response?.statusCode ?? 0)")
//                print("RAW FULL RESPONSE:")
                
                if let data = response.data,
                   let rawResponse = String(data: data, encoding: .utf8) {
                    print(rawResponse)
                } else {
                    print("No response data")
                }

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                self?.handle(response: response, completion: completion)
            }
    }

    @discardableResult
    func fetchInfo(
        completion: @escaping (Result<APIInfo, NetworkError>) -> Void
    ) -> DataRequest? {
        session.request("\(baseURL)/info/", method: .get)
            .validate()
            .responseDecodable(of: APIInfo.self, decoder: decoder) { [weak self] response in
                self?.handle(response: response, completion: completion)
            }
    }

    // MARK: - Error mapping

    private func handle<T>(
        response: AFDataResponse<T>,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        switch response.result {
        case .success(let value):
            completion(.success(value))

        case .failure(let error):
            if error.isExplicitlyCancelledError {
                completion(.failure(.cancelled))
                return
            }

            if let urlError = error.underlyingError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                    completion(.failure(.noInternetConnection))
                    return
                default:
                    break
                }
            }

            if error.isResponseSerializationError {
                completion(.failure(.decodingFailed))
                return
            }

            if let statusCode = response.response?.statusCode {
                completion(.failure(.requestFailed("Server returned an error (\(statusCode)). Please try again.")))
                return
            }

            completion(.failure(.unknown))
        }
    }
}
