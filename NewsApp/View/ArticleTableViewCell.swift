//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit
import AlamofireImage
internal import Alamofire

final class ArticleTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ArticleTableViewCell"

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .themePrimary
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let authorAvatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 8
        return view
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.af.cancelImageRequest()
        thumbnailImageView.image = nil
    }

    func configure(with viewModel: ArticleCellViewModel) {
        sourceLabel.text = viewModel.source
        titleLabel.text = viewModel.title
        metaLabel.text = "\(viewModel.authorName) · \(viewModel.relativeDate)"

        let placeholder = UIImage(systemName: "photo")
        if let url = viewModel.imageURL {
            thumbnailImageView.af.setImage(withURL: url, placeholderImage: placeholder)
        } else {
            thumbnailImageView.image = placeholder
        }
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubviews(with: [thumbnailImageView, sourceLabel, titleLabel, authorAvatarView, metaLabel])

        thumbnailImageView.width == .ratioWidthBasedOniPhoneX(84)
        thumbnailImageView.height == .ratioHeightBasedOniPhoneX(84)
        thumbnailImageView.leading == contentView.leading + .ratioWidthBasedOniPhoneX(16)
        thumbnailImageView.top == contentView.top + .ratioHeightBasedOniPhoneX(12)
        thumbnailImageView.bottom == contentView.bottom - .ratioHeightBasedOniPhoneX(12)

        sourceLabel.leading == thumbnailImageView.trailing + .ratioWidthBasedOniPhoneX(12)
        sourceLabel.trailing == contentView.trailing - .ratioWidthBasedOniPhoneX(16)
        sourceLabel.top == thumbnailImageView.top + .ratioHeightBasedOniPhoneX(2)

        titleLabel.leading == sourceLabel.leading
        titleLabel.trailing == sourceLabel.trailing
        titleLabel.top == sourceLabel.bottom + .ratioHeightBasedOniPhoneX(4)

        authorAvatarView.width == .ratioWidthBasedOniPhoneX(16)
        authorAvatarView.height == .ratioHeightBasedOniPhoneX(16)
        authorAvatarView.leading == titleLabel.leading
        authorAvatarView.top == titleLabel.bottom + .ratioHeightBasedOniPhoneX(8)

        metaLabel.leading == authorAvatarView.trailing + .ratioWidthBasedOniPhoneX(6)
        metaLabel.trailing == titleLabel.trailing
        metaLabel.centerY == authorAvatarView.centerY
    }
}
