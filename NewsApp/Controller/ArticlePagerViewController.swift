//
//  ArticlePagerViewController.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

final class ArticlePagerViewController: UIPageViewController {

    private var articles: [Article]
    private var currentIndex: Int

    init(articles: [Article], initialIndex: Int) {
        self.articles = articles
        self.currentIndex = initialIndex
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .systemBackground

        if let initialVC = viewController(at: currentIndex) {
            setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide standard navigation bar so custom top floating buttons are used
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func viewController(at index: Int) -> ArticleDetailViewController? {
        guard index >= 0 && index < articles.count else { return nil }
        let article = articles[index]
        
        let viewModel = ArticleDetailViewModel(article: article)
        let detailVC = ArticleDetailViewController(viewModel: viewModel)
        detailVC.view.tag = index
        return detailVC
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate

extension ArticlePagerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewController(at: index - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewController(at: index + 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? ArticleDetailViewController {
            currentIndex = currentVC.view.tag
        }
    }
}
