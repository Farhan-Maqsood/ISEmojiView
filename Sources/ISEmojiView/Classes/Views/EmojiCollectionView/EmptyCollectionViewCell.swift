//
//  EmptyCollectionViewCell.swift
//  ISEmojiView
//
//  Created by Farhan on 8/5/24.
//

import UIKit

class EmptyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmptyCollectionViewCell"
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
