//
//  HorizontalHeaderFlowLayout.swift
//  ISEmojiView
//
//  Created by Farhan on 8/4/24.
//

import UIKit

class HorizontalHeaderFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // Create a mutable array to hold updated layout attributes
        var updatedAttributes = [UICollectionViewLayoutAttributes]()
        
        // Track the sections that need their headers updated
        let sectionsWithHeaders = NSMutableIndexSet()
        
        for layoutAttributes in attributes {
            if layoutAttributes.representedElementCategory == .cell {
                sectionsWithHeaders.add(layoutAttributes.indexPath.section)
            }
        }
        
        // Remove headers from the list of attributes to avoid duplicate entries
        for layoutAttributes in attributes {
            if layoutAttributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                sectionsWithHeaders.remove(layoutAttributes.indexPath.section)
            }
            updatedAttributes.append(layoutAttributes)
        }
        
        // Add headers to the updated attributes with their positions adjusted
        sectionsWithHeaders.enumerate({ (index, stop) in
            let indexPath = IndexPath(item: 0, section: index)
            if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                updatedAttributes.append(headerAttributes)
            }
        })
        
        // Adjust headers' positions to stay at the top
        for layoutAttributes in updatedAttributes {
            if layoutAttributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                guard let collectionView = collectionView else { continue }
                var frame = layoutAttributes.frame
                let contentOffset = collectionView.contentOffset
                frame.origin.y = 0
                layoutAttributes.frame = frame
                layoutAttributes.zIndex = 1024 // Ensure headers are on top of cells
            }
        }
        
        return updatedAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
        
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        guard let collectionView = collectionView, let layoutAttributes = attributes else { return attributes }
        
        // Adjust the header's y position based on the collection view's content offset
        let contentOffsetY = collectionView.contentOffset.y
        layoutAttributes.frame.origin.y = 0
        layoutAttributes.zIndex = 1024
        
        return layoutAttributes
    }
}
