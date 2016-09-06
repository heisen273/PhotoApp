//
//  StickyHeaderCollectionViewFlowLayout.swift
//  PhotoApp
//
//  Created by Walter White on 8/19/16.
//  Copyright © 2016 TOHANI4 SOFTWARE. All rights reserved.
//

import UIKit

class StickyHeaderCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard var superAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return super.layoutAttributesForElementsInRect(rect)
        }
        
        let contentOffset = collectionView!.contentOffset
        let missingSections = NSMutableIndexSet()
        
        for layoutAttributes in superAttributes {
            if (layoutAttributes.representedElementCategory == .Cell) {
                missingSections.addIndex(layoutAttributes.indexPath.section)
            }
            
            if let representedElementKind = layoutAttributes.representedElementKind {
                if representedElementKind == UICollectionElementKindSectionHeader {
                    missingSections.removeIndex(layoutAttributes.indexPath.section)
                }
            }
        }
        
        missingSections.enumerateIndexesUsingBlock { idx, stop in
            let indexPath = NSIndexPath(forItem: 0, inSection: idx)
            if let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
                superAttributes.append(layoutAttributes)
            }
        }
        
        for layoutAttributes in superAttributes {
            if let representedElementKind = layoutAttributes.representedElementKind {
                if representedElementKind == UICollectionElementKindSectionHeader {
                    let section = layoutAttributes.indexPath.section
                    let numberOfItemsInSection = collectionView!.numberOfItemsInSection(section)
                    
                    let firstCellIndexPath = NSIndexPath(forItem: 0, inSection: section)
                    let lastCellIndexPath = NSIndexPath(forItem: max(0, (numberOfItemsInSection - 1)), inSection: section)
                    
                    var firstCellAttributes:UICollectionViewLayoutAttributes
                    var lastCellAttributes:UICollectionViewLayoutAttributes
                    
                    if (self.collectionView!.numberOfItemsInSection(section) > 0) {
                        firstCellAttributes = self.layoutAttributesForItemAtIndexPath(firstCellIndexPath)!
                        lastCellAttributes = self.layoutAttributesForItemAtIndexPath(lastCellIndexPath)!
                    }else {
                        firstCellAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: firstCellIndexPath)!
                        lastCellAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: lastCellIndexPath)!
                    }
                    
                    let headerHeight = CGRectGetHeight(layoutAttributes.frame)
                    var origin = layoutAttributes.frame.origin
                    
                    origin.y = min(max(contentOffset.y, (CGRectGetMinY(firstCellAttributes.frame) - headerHeight)), (CGRectGetMaxY(lastCellAttributes.frame) - headerHeight))
                    ;
                    
                    layoutAttributes.zIndex = 1024;
                    layoutAttributes.frame = CGRect(origin: origin, size: layoutAttributes.frame.size)
                    
                }
            }
        }
        
        return superAttributes
    }    
}