//
//  SearchFieldView.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

final class SearchFieldView: UIView {

    let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 15)
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        return textField
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .label
        return button
    }()

    var placeholder: String = "Search" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.systemGray]
            )
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .themeFieldBackground
        layer.cornerRadius = 14

        addSubviews(with: [iconImageView, textField, filterButton])

        iconImageView.width == 18
        iconImageView.height == 18
        iconImageView.leading == leading + .ratioWidthBasedOniPhoneX(14)
        iconImageView.centerY == centerY

        filterButton.width == 22
        filterButton.height == 22
        filterButton.trailing == trailing - .ratioWidthBasedOniPhoneX(14)
        filterButton.centerY == centerY

        textField.leading == iconImageView.trailing + .ratioWidthBasedOniPhoneX(10)
        textField.trailing == filterButton.leading - .ratioWidthBasedOniPhoneX(10)
        textField.centerY == centerY

        placeholder = "Search"
    }
}
