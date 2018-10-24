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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let pageControl =  SINPageControl.pageControl(style: .dot, numberOfPages: 5)
        pageControl.currentIndicatorColor = UIColor.yellow
        pageControl.indicatorColor = UIColor.lightGray
        pageControl.currentPage = 2
        pageControl.backgroundColor = UIColor.red
//        pageControl.indicatorSize = CGSize(width: 120, height: 120)
//        pageControl.indicatorSize = CGSize(width: 120, height: 120)
        self.view.addSubview(pageControl)
        
        let point = touches.first?.location(in: self.view)
        
        pageControl.snp.makeConstraints { (make) in
            make.center.equalTo(point ?? self.view.snp.center)
            make.size.equalTo(CGSize(width: 300, height: 200))
        }
    }


}

