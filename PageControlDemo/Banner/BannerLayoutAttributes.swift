//
//  BannerLayoutAttributes.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/30.
//  Copyright © 2018 杨静. All rights reserved.
//

import UIKit

open class BannerLayoutAttributes: UICollectionViewLayoutAttributes {
    
    open var position: CGFloat = 0
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? BannerLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! BannerLayoutAttributes
        copy.position = self.position
        return copy
    }
}
