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
        
        let pageControl =  SINPageControl.pageControl(controlStyle: .dot, numberOfPages: 10)
        pageControl.currentIndicatorColor = UIColor.yellow
        pageControl.indicatorColor = UIColor.lightGray
        pageControl.currentPage = 2
        self.view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 10))
        }
    }


}

