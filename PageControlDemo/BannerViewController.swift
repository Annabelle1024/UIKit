//
//  BannerViewController.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/30.
//  Copyright © 2018 杨静. All rights reserved.
//

import UIKit
import SnapKit

class BannerViewController: UIViewController,SINBannerViewDataSource, SINBannerViewDelegate {

    let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    
    lazy var bannerView: BannerView = {
        let banner = BannerView.init(frame: .zero)
        banner.register(BannerCell.self, forCellWithReuseIdentifier: "bannerCell")
//        banner.interItemSpacing = 10
        banner.itemSize = BannerView.automaticSize
        banner.isInfinite = false
//        banner.automaticSlidingInterval = 2
//        banner.interItemSpacing = 10
        banner.cornerRadius = 8
        banner.delegate = self
        banner.dataSource = self
        return banner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bannerView)
        bannerView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(18)
            make.right.equalTo(self.view).offset(-18)
            make.top.equalTo(self.view).offset(100)
            make.height.equalTo(225)
        })
        bannerView.layoutIfNeeded()
//        bannerView.itemSize = bannerView.frame.size.applying(CGAffineTransform(scaleX: 0.9, y: 0.9))
    }


    // MARK: - Banner View Datasource
    func numberOfItems(in bannerView: BannerView) -> Int {
        return self.imageNames.count
    }
    
    func bannerView(_ bannerView: BannerView, cellForItemAt index: Int) -> UICollectionViewCell {
        
        let cell: BannerCell = bannerView.dequeueReusableCell(withReuseIdentifier: "bannerCell", at: index, allowShadow: false) as! BannerCell
        
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int) {
        bannerView.deselectItem(at: index, animated: true)
        bannerView.scrollToItem(at: index, animated: true)
    }
    
    func bannerViewWillEndDragging(_ bannerView: BannerView, targetIndex: Int) {
//        self.pageControl.currentPage = targetIndex
    }
    
    func bannerViewDidEndScrollAnimation(_ pagerView: BannerView) {
//        self.pageControl.currentPage = pagerView.currentIndex
    }

}
