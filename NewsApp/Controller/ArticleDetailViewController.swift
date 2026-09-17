//
//  ArticleDetailViewController.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit
import SafariServices
import AlamofireImage
internal import Alamofire

final class ArticleDetailViewController: UIViewController {

    let viewModel: ArticleDetailViewModel

    private var isSaved: Bool = false

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.alwaysBounceHorizontal = false
        sv.isDirectionalLockEnabled = true
        return sv
    }()

    private let contentView = UIView()

    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        return iv
    }()

    // MARK: - Custom Floating Top Bar Controls

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 18
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        button.setImage(UIImage(systemName: "bookmark", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 18
        return button
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 18
        return button
    }()

    private let categoryBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .themePrimary
        view.layer.cornerRadius = 12
        return view
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let authorAvatarView = AuthorAvatarView()

    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let readFullArticleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read Full Article on Web", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .themePrimary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(viewModel: ArticleDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(article: Article) {
        self.init(viewModel: ArticleDetailViewModel(article: article))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        renderContent()
        viewModel.fetchArticleDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide standard navigation bar so custom top floating buttons are used
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        categoryBadgeView.addSubview(categoryLabel)

        contentView.addSubviews(with: [
            headerImageView, categoryBadgeView, cardContainerView, loadingIndicator
        ])

        cardContainerView.addSubviews(with: [
            titleLabel, authorAvatarView, authorNameLabel, dateLabel, summaryLabel, readFullArticleButton
        ])

        // Custom floating top bar controls
        view.addSubviews(with: [backButton, saveButton, moreButton])

        scrollView.leading == view.leading
        scrollView.trailing == view.trailing
        scrollView.top == view.top
        scrollView.bottom == view.bottom

        contentView.leading == scrollView.contentLayoutGuide.leading
        contentView.trailing == scrollView.contentLayoutGuide.trailing
        contentView.top == scrollView.contentLayoutGuide.top
        contentView.bottom == scrollView.contentLayoutGuide.bottom

        contentView.widthAnchor
            .constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            .isActive = true

        // Top bar buttons constraints (floating over top image)
        backButton.leading == view.safeAreaLayoutGuide.leading + .ratioWidthBasedOniPhoneX(16)
        backButton.top == view.safeAreaLayoutGuide.top + .ratioHeightBasedOniPhoneX(8)
        backButton.width == .ratioHeightBasedOniPhoneX(36)
        backButton.height == .ratioHeightBasedOniPhoneX(36)

        moreButton.trailing == view.safeAreaLayoutGuide.trailing - .ratioWidthBasedOniPhoneX(16)
        moreButton.top == backButton.top
        moreButton.width == .ratioHeightBasedOniPhoneX(36)
        moreButton.height == .ratioHeightBasedOniPhoneX(36)

        saveButton.trailing == moreButton.leading - .ratioWidthBasedOniPhoneX(12)
        saveButton.top == backButton.top
        saveButton.width == .ratioHeightBasedOniPhoneX(36)
        saveButton.height == .ratioHeightBasedOniPhoneX(36)

        headerImageView.top == contentView.top
        headerImageView.leading == contentView.leading
        headerImageView.trailing == contentView.trailing
        headerImageView.height == .ratioHeightBasedOniPhoneX(300)

        categoryBadgeView.leading == contentView.leading + .ratioWidthBasedOniPhoneX(20)
        categoryBadgeView.bottom == headerImageView.bottom - .ratioHeightBasedOniPhoneX(24)

        categoryLabel.leading == categoryBadgeView.leading + .ratioWidthBasedOniPhoneX(12)
        categoryLabel.trailing == categoryBadgeView.trailing - .ratioHeightBasedOniPhoneX(12)
        categoryLabel.top == categoryBadgeView.top + .ratioHeightBasedOniPhoneX(6)
        categoryLabel.bottom == categoryBadgeView.bottom - .ratioHeightBasedOniPhoneX(6)

        cardContainerView.top == headerImageView.bottom - .ratioHeightBasedOniPhoneX(20)
        cardContainerView.leading == contentView.leading
        cardContainerView.trailing == contentView.trailing
        cardContainerView.bottom == contentView.bottom

        titleLabel.top == cardContainerView.top + .ratioHeightBasedOniPhoneX(24)
        titleLabel.leading == cardContainerView.leading + .ratioWidthBasedOniPhoneX(20)
        titleLabel.trailing == cardContainerView.trailing - .ratioHeightBasedOniPhoneX(20)

        authorAvatarView.width == .ratioHeightBasedOniPhoneX(28)
        authorAvatarView.height == .ratioHeightBasedOniPhoneX(28)
        authorAvatarView.leading == titleLabel.leading
        authorAvatarView.top == titleLabel.bottom + .ratioHeightBasedOniPhoneX(16)

        authorNameLabel.leading == authorAvatarView.trailing + .ratioWidthBasedOniPhoneX(10)
        authorNameLabel.top == authorAvatarView.top
        authorNameLabel.trailing == titleLabel.trailing

        dateLabel.leading == authorNameLabel.leading
        dateLabel.top == authorNameLabel.bottom + .ratioHeightBasedOniPhoneX(2)
        dateLabel.trailing == titleLabel.trailing

        summaryLabel.top == authorAvatarView.bottom + .ratioHeightBasedOniPhoneX(20)
        summaryLabel.leading == titleLabel.leading
        summaryLabel.trailing == titleLabel.trailing

        readFullArticleButton.top == summaryLabel.bottom + .ratioHeightBasedOniPhoneX(32)
        readFullArticleButton.leading == titleLabel.leading
        readFullArticleButton.trailing == titleLabel.trailing
        readFullArticleButton.height == .ratioHeightBasedOniPhoneX(50)
        readFullArticleButton.bottom == cardContainerView.bottom - .ratioHeightBasedOniPhoneX(40)

        // Button actions
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(handleSaveToggle), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(handleMoreTap), for: .touchUpInside)
        readFullArticleButton.addTarget(self, action: #selector(handleReadFullArticle), for: .touchUpInside)

        loadingIndicator.centerX == cardContainerView.centerX
        loadingIndicator.top == summaryLabel.bottom + .ratioHeightBasedOniPhoneX(10)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    self?.loadingIndicator.startAnimating()
                case .loaded:
                    self?.loadingIndicator.stopAnimating()
                    self?.renderContent()
                case .error:
                    self?.loadingIndicator.stopAnimating()
                case .idle:
                    break
                }
            }
        }
    }

    private func renderContent() {
        categoryLabel.text = viewModel.newsSite
        titleLabel.text = viewModel.title
        authorNameLabel.text = viewModel.authorName
        dateLabel.text = viewModel.formattedPublishedDate
        summaryLabel.text = viewModel.summary.isEmpty ? "No summary available for this article." : viewModel.summary

        authorAvatarView.configure(initials: viewModel.authorInitials)

        let placeholder = UIImage(systemName: "photo.fill")
        if let imageURL = viewModel.imageURL {
            headerImageView.af.setImage(withURL: imageURL, placeholderImage: placeholder)
        } else {
            headerImageView.image = placeholder
        }
    }

    // MARK: - Actions

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSaveToggle() {
        isSaved.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let imageName = isSaved ? "bookmark.fill" : "bookmark"
        saveButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        saveButton.tintColor = isSaved ? .themePrimary : .white
    }

    @objc private func handleMoreTap() {
        // UI action placeholder for horizontal 3 dots (...) menu
    }

    @objc private func handleReadFullArticle() {
        guard let url = viewModel.articleURL else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
