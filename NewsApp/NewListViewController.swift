//
//  NewsFeedViewController.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

class NewsFeedViewController: UIViewController {

    private let viewModel = NewsFeedViewModel()
    private var selectedCategoryIndex = 0

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "News from all around the world"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let searchField = SearchFieldView()

    private let categoriesLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return layout
    }()

    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: categoriesLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryChipCell.self, forCellWithReuseIdentifier: CategoryChipCell.reuseIdentifier)
        return collectionView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 108
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        return tableView
    }()

    private let refreshControl = UIRefreshControl()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No articles found."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let paginationFooterIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupTableView()
        setupSearchField()
        setupBindings()

        viewModel.start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubviews(with: [
            titleLabel, subtitleLabel, searchField, categoriesCollectionView,
            tableView, loadingIndicator, emptyStateLabel
        ])

        titleLabel.leading == view.safeAreaLayoutGuide.leading + .ratioWidthBasedOniPhoneX(20)
        titleLabel.trailing == view.safeAreaLayoutGuide.trailing - .ratioWidthBasedOniPhoneX(20)
        titleLabel.top == view.safeAreaLayoutGuide.top + .ratioHeightBasedOniPhoneX(12)

        subtitleLabel.leading == titleLabel.leading
        subtitleLabel.trailing == titleLabel.trailing
        subtitleLabel.top == titleLabel.bottom + .ratioHeightBasedOniPhoneX(4)

        searchField.leading == titleLabel.leading
        searchField.trailing == titleLabel.trailing
        searchField.top == subtitleLabel.bottom + .ratioHeightBasedOniPhoneX(16)
        searchField.height == .ratioHeightBasedOniPhoneX(48)

        categoriesCollectionView.leading == view.leading
        categoriesCollectionView.trailing == view.trailing
        categoriesCollectionView.top == searchField.bottom + 16
        categoriesCollectionView.height == 40

        tableView.leading == view.leading
        tableView.trailing == view.trailing
        tableView.top == categoriesCollectionView.bottom + 8
        tableView.bottom == view.bottom

        loadingIndicator.centerX == tableView.centerX
        loadingIndicator.centerY == tableView.centerY - 40

        emptyStateLabel.centerY == tableView.centerY - 40
        emptyStateLabel.leading == tableView.leading + .ratioWidthBasedOniPhoneX(32)
        emptyStateLabel.trailing == tableView.trailing - .ratioWidthBasedOniPhoneX(32)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    private func setupSearchField() {
        searchField.textField.delegate = self
        searchField.textField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
    }

    private func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.categoriesCollectionView.reloadData()
            }
        }

        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
        }
    }

    private func render(_ state: ArticleListState) {
        switch state {
        case .idle:
            break

        case .loading:
            emptyStateLabel.isHidden = true
            if viewModel.numberOfArticles == 0 {
                loadingIndicator.startAnimating()
            }
            tableView.tableFooterView = nil

        case .loadingMore:
            paginationFooterIndicator.startAnimating()
            tableView.tableFooterView = paginationFooterIndicator

        case .refreshing:
            emptyStateLabel.isHidden = true

        case .loaded:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            paginationFooterIndicator.stopAnimating()
            tableView.tableFooterView = nil
            emptyStateLabel.isHidden = true

        case .empty:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.tableFooterView = nil
            emptyStateLabel.isHidden = false

        case .error(let message):
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            paginationFooterIndicator.stopAnimating()
            tableView.tableFooterView = nil
            presentErrorAlert(message: message)
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Couldn't load news", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadInitial()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
    }

    @objc private func searchTextFieldDidChange(_ textField: UITextField) {
        let query = textField.text ?? ""
        viewModel.search(query)
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension NewsFeedViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfArticles
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.cellViewModel(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let pagerVC = ArticlePagerViewController(
            articles: (0..<viewModel.numberOfArticles).map { viewModel.article(at: $0) },
            initialIndex: indexPath.row
        )
        navigationController?.pushViewController(pagerVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension NewsFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryChipCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryChipCell else {
            return UICollectionViewCell()
        }

        cell.configure(title: viewModel.categories[indexPath.item], isSelected: false)
        cell.isSelected = indexPath.item == selectedCategoryIndex
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedCategoryIndex else { return }
        selectedCategoryIndex = indexPath.item
        viewModel.didSelectCategory(viewModel.categories[indexPath.item])
        collectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate

extension NewsFeedViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.clearSearch()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
