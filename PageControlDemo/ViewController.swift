//
//  ViewController.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/22.
//  Copyright © 2018年 杨静. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var count = 0
    var pages = 5
    
    lazy var pageControl: SINPageControl = {
        let control =  SINPageControl.pageControl(style: .dot, numberOfPages:pages)
        control.backgroundColor = UIColor.red
//        control.currentIndicatorColor = UIColor.blue
//        control.indicatorColor = UIColor.lightGray
//        control.indicatorSize = CGSize(width: 20, height: 20)
//        control.currentIndicatorSize = CGSize(width: 24, height: 24)
//        control.currentIndicatorImage = UIImage.sin_image(color: UIColor.yellow, size: CGSize(width: 20, height: 20))
//        control.indicatorImage = UIImage.sin_image(color: UIColor.blue, size: CGSize(width: 6, height: 6))

        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.size.equalTo(CGSize(width: 300, height: 200))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        count += 1
        count = count % pages
        self.pageControl.currentPage = count

    }

}

