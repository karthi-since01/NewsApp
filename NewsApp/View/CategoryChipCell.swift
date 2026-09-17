//
//  CategoryChipCell.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

final class CategoryChipCell: UICollectionViewCell {

    static let reuseIdentifier = "CategoryChipCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private var isChipSelected = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isChipSelected = false
        updateAppearance()
    }

    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.addSubviews(with: [titleLabel])

        titleLabel.leading == contentView.leading + .ratioWidthBasedOniPhoneX(16)
        titleLabel.trailing == contentView.trailing - .ratioWidthBasedOniPhoneX(16)
        titleLabel.top == contentView.top + .ratioWidthBasedOniPhoneX(8)
        titleLabel.bottom == contentView.bottom - .ratioWidthBasedOniPhoneX(8)

        updateAppearance()
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        isChipSelected = isSelected
        updateAppearance()
    }

    private func updateAppearance() {
        if isChipSelected {
            contentView.backgroundColor = .themePrimary
            contentView.layer.borderColor = UIColor.themePrimary.cgColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .systemBackground
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            titleLabel.textColor = .darkGray
        }
    }
}
