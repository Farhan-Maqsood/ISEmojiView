//
//  EmojiSectionHeaderView.swift
//  ISEmojiView
//
//  Created by Farhan on 8/4/24.
//

import UIKit

class EmojiSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "EmojiSectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.alpha = 0.35
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:4),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
