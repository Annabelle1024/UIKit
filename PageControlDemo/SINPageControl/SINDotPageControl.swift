//
//  SINDotPageControl.swift
//  SINUIKit
//
//  Created by Annabelle on 2018/10/17.
//

import UIKit
import SnapKit

public class SINDotPageControl: SINPageControl {
    
    //MARK: Stored Properties
    var selectedButton = UIButton()
    var leftMarginConstraints = [ConstraintMakerEditable]()
    var containerView = UIView()
    
    //MARK: Computed Properties
    var indicatorCorner: CGFloat {
        if self.ignoreCornerRadius {
            return 0.0
        } else {
            return min(self.indicatorSize.width, self.indicatorSize.height)/2
        }
    }
    
    var currentIndicatorCorner: CGFloat {
        if self.ignoreCornerRadius {
            return 0.0
        } else {
            return min(self.currentIndicatorSize.width, self.currentIndicatorSize.height)/2
        }
    }
    
    var buttonArray: [UIButton] {
        var array = [UIButton]()
        for subview in self.containerView.subviews where subview.isKind(of: UIButton.classForCoder()) {
            array.append(subview as! UIButton)
        }
        return array
    }
    
    //MARK: Override
    override public var numberOfPages: Int {
        didSet {
            // 初始化
            self.containerView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            
            let container = UIView()
            self.addSubview(container)
            
            container.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalTo(max(self.indicatorSize.height, self.currentIndicatorSize.height))
            }
            
            var lastButton = UIButton()
            for index in 0..<self.numberOfPages {
                
                let button = UIButton(type: .custom)
                button.tag = index
                button.setBackgroundImage(self.indicatorImage, for: .normal)
                button.setBackgroundImage(self.currentIndicatorImage, for: .highlighted)
                button.setBackgroundImage(self.currentIndicatorImage, for: .selected)
                button.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchDown)
                button.layer.masksToBounds = true
                button.layer.cornerRadius = self.indicatorCorner
                container.addSubview(button)
                
                let defaultSize = CGSize(width: self.indicatorSize.width, height: self.indicatorSize.height)
                
                button.snp.makeConstraints { (make) in
                    make.centerY.equalTo(container)
                    make.size.equalTo(defaultSize)
                    if index == 0 {
                        make.left.equalTo(container)
                    } else {
                        let constraint = make.left.equalTo(lastButton.snp.right).offset(self.indicatorSpace)
                        self.leftMarginConstraints.append(constraint)
                    }
                }
                
                lastButton = button
            }
            
            lastButton.snp.makeConstraints { (make) in
                make.right.equalTo(container)
            }
            self.containerView = container
            self.isHidden = (numberOfPages == 1 && self.hideForSinglePage)
        }
    }
    
    override public var currentPage: Int {
        didSet {

            if self.currentPage > buttonArray.count { return }
            let currentBtn = buttonArray[self.currentPage]
            if currentBtn == self.selectedButton { return }

            self.selectedButton.isSelected = false
            self.selectedButton.layer.cornerRadius = self.indicatorCorner
            self.selectedButton.snp.updateConstraints { (make) in
                make.size.equalTo(self.indicatorSize)
            }

            // 设置 '当前' pageControl
            currentBtn.isSelected = true
            currentBtn.layer.cornerRadius = self.currentIndicatorCorner
            currentBtn.snp.updateConstraints { (make) in
                make.size.equalTo(self.currentIndicatorSize)
            }

            //更新containerview高度
            let height = self.currentIndicatorSize.height > 0 ? self.currentIndicatorSize.height : SINPageDefaultSize.current.height
            self.containerView.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }

            if oldValue != self.currentPage {
                sendActions(for: .touchDown)
            }

            // 更新当前选中
            self.selectedButton = currentBtn
        }
    }

    override public var indicatorSpace: CGFloat {
        didSet {
            if self.indicatorSpace == 0 {
                assertionFailure("indicatorSpace can't be zero")
            }
            layoutIfNeeded()
        }
    }

    override public var indicatorSize: CGSize {
        didSet {
            if self.indicatorSize == CGSize.zero {
                assertionFailure("indicatorSize can't be zero")
            }
            self.setNeedsUpdateConstraints()
        }
    }

    override public var currentIndicatorSize: CGSize {
        didSet {
            if self.currentIndicatorSize == CGSize.zero {
                assertionFailure("currentIndicatorSize can't be zero")
            }
            self.setNeedsUpdateConstraints()
        }
    }

    override public var indicatorColor: UIColor? {
        didSet {
            p_setImage(with: self.indicatorColor, and: nil)
        }
    }

    override public var currentIndicatorColor: UIColor? {
        didSet {
           p_setImage(with: nil, and: self.currentIndicatorColor)
        }
    }

    override public var indicatorImage: UIImage? {
        didSet {
            p_setImage(with: self.indicatorImage, and: nil)
        }
    }

    override public var currentIndicatorImage: UIImage? {
        didSet {
            p_setImage(with: nil, and: self.currentIndicatorImage)
        }
    }

    override public func updateConstraints() {
        super.updateConstraints()

        for button in buttonArray {

            // 更新布局
            button.snp.updateConstraints { (make) in
                if self.currentPage == button.tag {
                    make.size.equalTo(self.currentIndicatorSize)
                } else {
                    make.size.equalTo(self.indicatorSize)
                }
            }

            // 更新圆角
            button.layer.cornerRadius = (self.currentPage == button.tag) ? self.currentIndicatorCorner : self.indicatorCorner
        }

        for constraint in self.leftMarginConstraints {
            constraint.offset(self.indicatorSpace)
        }
    }
    
    override init(style: SINPageControlStyle, numberOfPages: Int) {
        super.init(style: style, numberOfPages: numberOfPages)
        self.numberOfPages = numberOfPages
        self.currentPage = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SINPageControl {
    @objc func buttonDidClick(_ sender: UIButton) {
        self.currentPage = sender.tag
    }
}

extension SINDotPageControl {
    fileprivate func p_setImage(with color: UIColor?, and currentColor: UIColor?) {
        
        if let color = color {
            let image = UIImage.sin_image(color: color, size: self.indicatorSize) ?? nil
            p_setImage(with: image, and: nil)
        }
        
        if let currentColor = currentColor {
            let currentImage = UIImage.sin_image(color: currentColor, size: self.currentIndicatorSize) ?? nil
            p_setImage(with: nil, and: currentImage)
        }
    }
    
    fileprivate func p_setImage(with image: UIImage?, and currentImage: UIImage?) {
        
        if image == nil && currentImage == nil {
            return
        }
        
        // OC里面这里记录了self.indicatorImage和self.currentIndicatorImage, 这里需要吗? 如果需要该怎么记录

        for button in buttonArray {
            if let indicatorImage = image {
                button.setBackgroundImage(indicatorImage, for: .normal)
            }
            if let currentIndicatorImage = currentImage {
                button.setBackgroundImage(currentIndicatorImage, for: .highlighted)
                button.setBackgroundImage(currentIndicatorImage, for: .selected)
            }
        }

    }
}

