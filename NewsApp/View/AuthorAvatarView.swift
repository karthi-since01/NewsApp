//
//  AuthorAvatarView.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

final class AuthorAvatarView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .themePrimary

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(initials: String, backgroundColor: UIColor = .themePrimary) {
        label.text = initials
        self.backgroundColor = backgroundColor
    }
}
