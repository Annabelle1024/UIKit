//
//  SINPageControl.swift
//  SINUIKit
//
//  Created by Annabelle on 2018/10/17.
//

import UIKit

public enum SINPageControlStyle {
    case dot
    case numerical
}

public struct SINPageDefaultColor {
    public static var current: UIColor {
        return UIColor.yellow
    }
    public static var other: UIColor {
        return UIColor.lightGray
    }
}

public struct SINPageDefaultSize {
    public static var current: CGSize {
        return CGSize(width: 16, height: 16)
    }
    public static var other: CGSize {
        return CGSize(width: 14, height: 14)
    }
}

public struct SINPageDefaultImage {
    public static var other: UIImage {
        return UIImage.sin_image(color: UIColor.lightGray, size: CGSize(width: 14, height: 14)) ?? UIImage()
    }
    public static var current: UIImage {
        return UIImage.sin_image(color: UIColor.yellow, size: CGSize(width: 16, height: 16)) ?? UIImage()
    }
}

public class SINPageControl: UIControl {
    

    //MARK: > Common Properties
    public var currentPage: Int = 0
    
    // 设置numberOfPages会移除indicator再重新创建添加，numberOfPages应该大于0
    public var numberOfPages: Int = 0 {
        didSet {
            if self.numberOfPages <= 0 {
                self.isHidden = true
                return
            }
            self.isHidden = false
        }
    }
    
    // hide the the indicator if there is only one page. default is NO
    public var hideForSinglePage: Bool = false {
        didSet {
            self.isHidden = (1 == self.numberOfPages && self.hideForSinglePage)
        }
    }
    
    
    //MARK: > Dot Style
    // 点的间距
    public var indicatorSpace: CGFloat = 4
    
    // 非currentPage的点大小
    public var indicatorSize: CGSize = SINPageDefaultSize.other
    
    // currentPage的点大小
    public var currentIndicatorSize: CGSize = SINPageDefaultSize.current
    
    /// 非currentPage点颜色
    /// - Note: indicatorColor 和 currentIndicatorColor 配对使用
    /// - Note: indicatorColor 和 indicatorImage 互斥
    public var indicatorColor: UIColor? 
    
    /// currentPage点颜色
    /// - Note: indicatorColor 和 currentIndicatorColor 配对使用
    /// - Note: currentIndicatorColor 和 currentIndicatorImage 互斥
    public var currentIndicatorColor: UIColor?
    
    /// 非currentPage的图片
    /// - Note: indicatorImage 和 currentIndicatorImage 配对使用
    /// - Note: indicatorColor 和 indicatorImage 互斥
    public var indicatorImage: UIImage? = SINPageDefaultImage.other
    
    /// currentPage的图片
    /// - Note: indicatorImage 和 currentIndicatorImage 配对使用
    /// - Note: currentIndicatorColor 和 currentIndicatorImage 互斥
    public var currentIndicatorImage: UIImage? = SINPageDefaultImage.current
    
    public var ignoreCornerRadius: Bool = false
    
    //MARK: > Numberical Style
    
    /**
     显示当前页是否从0开始，默认为NO
     */
    public var startFromZero: Bool = false
//
//    var currentFont: UIFont?
//
//    var currentTextColor: UIColor
//
//    var font: UIFont
//
//    var textColor: UIColor

//    public func setCurrentPage(attrText: NSAttributedString) {
//
//    }
//
//    public func setNumberOfPage(attrText: NSAttributedString) {
//
//    }
    
    
    //MARK: > Private Properties

    
    //MARK: > init
    public class func pageControl(style: SINPageControlStyle, numberOfPages pages: Int) -> SINPageControl {
        switch (style) {
        case .dot:
            return SINDotPageControl.init(style: style, numberOfPages: pages)
        case .numerical:
            return SINNumericalPageControl.init(style: style, numberOfPages: pages)
        }
    }
    
    init(style: SINPageControlStyle, numberOfPages: Int) {
        super.init(frame: .zero)
        self.numberOfPages = numberOfPages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

