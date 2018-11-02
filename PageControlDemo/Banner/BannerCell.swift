//
//  BannerCell.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/30.
//  Copyright © 2018 杨静. All rights reserved.
//

import UIKit

public class BannerCell: UICollectionViewCell {
    

    /// Returns the image view of the pager view cell. Default is nil.
    @objc open var imageView: UIImageView? {
        if let _ = _imageView {
            return _imageView
        }
        let imageView = UIImageView(frame: .zero)
        self.contentView.addSubview(imageView)
        _imageView = imageView
        return imageView
    }

    fileprivate weak var _imageView: UIImageView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = _imageView {
            imageView.frame = self.contentView.bounds
        }
    }
    
}
