//
//  NewsFeedViewModel.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import Foundation
internal import Alamofire

enum ArticleListState: Equatable {
    case idle
    case loading        // first page / filter change — show full-screen spinner
    case loadingMore     // pagination — show footer spinner
    case refreshing      // pull to refresh — UIRefreshControl handles its own spinner
    case loaded
    case empty
    case error(String)
}

final class NewsFeedViewModel {
    
    /// Called whenever the visible article list changes.
    var onUpdate: (() -> Void)?
    /// Called whenever the loading/error/empty state changes.
    var onStateChange: ((ArticleListState) -> Void)?
    /// Called once category chips have been fetched from /v4/info/.
    var onCategoriesUpdate: (() -> Void)?
    
    private(set) var articles: [Article] = []
    private(set) var categories: [String] = ["All"]
    
    private let service: ArticleServiceProtocol
    private let pageSize: Int
    
    private var currentOffset = 0
    private var totalCount = 0
    private var isFetching = false
    private var canLoadMore = true
    
    private var selectedCategory = "All"
    private var searchQuery = ""
    
    private var searchWorkItem: DispatchWorkItem?
    private var listRequest: DataRequest?
    
    private var currentRequestToken = 0
    
    init(service: ArticleServiceProtocol = ArticleService.shared, pageSize: Int = 10) {
        self.service = service
        self.pageSize = pageSize
    }
    
    var numberOfArticles: Int { articles.count }
    
    func article(at index: Int) -> Article {
        articles[index]
    }
    
    func cellViewModel(at index: Int) -> ArticleCellViewModel {
        ArticleCellViewModel(article: articles[index])
    }
    
    // MARK: - Lifecycle
    
    /// Call once from viewDidLoad. Kicks off the category chips fetch and the first page of articles.
    func start() {
        loadCategories()
        loadInitial()
    }
    
    func loadInitial() {
        currentOffset = 0
        canLoadMore = true
        fetch(state: .loading)
    }
    
    func refresh(completion: (() -> Void)? = nil) {
        currentOffset = 0
        canLoadMore = true
        fetch(state: .refreshing, completion: completion)
    }
    
    /// Call from `willDisplay cell` (or `scrollViewDidScroll`) with the row about to appear.
    func loadNextPageIfNeeded(currentIndex: Int) {
        
        guard canLoadMore, !isFetching else {
            return
        }
        
        guard currentIndex >= articles.count - 3 else {
            return
        }
        
        currentOffset += pageSize
        
//        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
//        print("PAGINATION")
//        print("Loading next page")
//        print("Current Index: \(currentIndex)")
//        print("Offset: \(currentOffset)")
//        print("Page Size: \(pageSize)")
//        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        fetch(state: .loadingMore)
    }
    
    func didSelectCategory(_ category: String) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        currentOffset = 0
        canLoadMore = true
        fetch(state: .loading)
    }
    
    /// Searches for a query string with debounce.
    /// If the query is empty, executes immediately to prevent search state glitches.
    func search(_ query: String) {
        searchWorkItem?.cancel()
        searchWorkItem = nil
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed != searchQuery else { return }
        
        if trimmed.isEmpty {
            searchQuery = ""
            currentOffset = 0
            canLoadMore = true
            fetch(state: .loading)
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.searchQuery = trimmed
            self.currentOffset = 0
            self.canLoadMore = true
            self.fetch(state: .loading)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }
    
    /// Called when the user explicitly taps the ✕ to clear the search field.
    func clearSearch() {
        searchWorkItem?.cancel()
        searchWorkItem = nil
        guard !searchQuery.isEmpty else { return }
        searchQuery = ""
        currentOffset = 0
        canLoadMore = true
        fetch(state: .loading)
    }
    
    // MARK: - Private
    
    private func loadCategories() {
        service.fetchInfo { [weak self] result in
            guard let self else { return }
            if case .success(let info) = result {
                self.categories = ["All"] + info.newsSites.sorted()
                self.onCategoriesUpdate?()
            }
        }
    }
    
    private func fetch(state: ArticleListState, completion: (() -> Void)? = nil) {
        listRequest?.cancel()
        isFetching = true
        onStateChange?(state)

        currentRequestToken += 1
        let requestToken = currentRequestToken

        let newsSite = selectedCategory == "All" ? nil : selectedCategory

        listRequest = service.fetchArticles(
            limit: pageSize,
            offset: currentOffset,
            newsSite: newsSite,
            searchQuery: searchQuery.isEmpty ? nil : searchQuery
        ) { [weak self] result in
            guard let self else { return }

            guard requestToken == self.currentRequestToken else {
                completion?()
                return
            }
            
            self.isFetching = false

            switch result {
            case .success(let response):
                self.totalCount = response.count
                self.articles = self.currentOffset == 0
                    ? response.results
                    : self.articles + response.results
                self.canLoadMore = self.articles.count < self.totalCount

                self.onUpdate?()
                self.onStateChange?(self.articles.isEmpty ? .empty : .loaded)

            case .failure(let error):
                if error == .cancelled {
                    completion?()
                    return
                }
                if self.currentOffset >= self.pageSize {
                    self.currentOffset -= self.pageSize
                }
                self.onStateChange?(.error(error.errorDescription))
            }

            completion?()
        }
    }
}
