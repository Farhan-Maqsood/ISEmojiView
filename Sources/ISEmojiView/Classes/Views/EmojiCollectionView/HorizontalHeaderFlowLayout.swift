//
//  HorizontalHeaderFlowLayout.swift
//  ISEmojiView
//
//  Created by Farhan on 8/4/24.
//

import UIKit

class HorizontalHeaderFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var headers = [UICollectionViewLayoutAttributes]()
        var cellAttributes = [UICollectionViewLayoutAttributes]()
        
        for attribute in attributes {
            if attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                headers.append(attribute)
            } else {
                cellAttributes.append(attribute)
            }
        }
        
        for header in headers {
            let section = header.indexPath.section
            let firstItemIndexPath = IndexPath(item: 0, section: section)
            if let firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath) {
                var frame = header.frame
                frame.origin.x = firstItemAttributes.frame.origin.x
                header.frame = frame
                header.zIndex = 1024
            }
        }
        
        return headers + cellAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
