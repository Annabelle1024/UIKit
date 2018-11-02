//
//  BannerCollectionView.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/30.
//  Copyright © 2018 杨静. All rights reserved.
//

import UIKit

class BannerCollectionView: UICollectionView {

    fileprivate var pagerView: BannerView? {
        return self.superview?.superview as? BannerView
    }
    
    #if !os(tvOS)
    override var scrollsToTop: Bool {
        set {
            super.scrollsToTop = false
        }
        get {
            return false
        }
    }
    #endif
    
    override var contentInset: UIEdgeInsets {
        get {
            return super.contentInset
        }
        
        set {
            super.contentInset = .zero
            if (newValue.top > 0) {
                let contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + newValue.top);
                self.contentOffset = contentOffset
            }
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.contentInset = .zero
        // 减速速率
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        #if !os(tvOS)
        self.scrollsToTop = false
        self.isPagingEnabled = false
        #endif
    }

}
