//
//  ArticleDetailViewController.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

final class ArticleDetailViewController: UIViewController {

    private let article: Article

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = article.newsSite

        view.addSubviews(with: [titleLabel, metaLabel, summaryLabel])

        titleLabel.leading == view.safeAreaLayoutGuide.leading + .ratioWidthBasedOniPhoneX(20)
        titleLabel.trailing == view.safeAreaLayoutGuide.trailing - .ratioWidthBasedOniPhoneX(20)
        titleLabel.top == view.safeAreaLayoutGuide.top + .ratioHeightBasedOniPhoneX(20)

        metaLabel.leading == titleLabel.leading
        metaLabel.trailing == titleLabel.trailing
        metaLabel.top == titleLabel.bottom + 8

        summaryLabel.leading == titleLabel.leading
        summaryLabel.trailing == titleLabel.trailing
        summaryLabel.top == metaLabel.bottom + 16

        titleLabel.text = article.title
        metaLabel.text = "\(article.authors.first?.name ?? article.newsSite) · \(article.newsSite)"
        summaryLabel.text = article.summary
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
