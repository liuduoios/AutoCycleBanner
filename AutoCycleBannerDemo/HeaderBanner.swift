//
//  HeaderBanner.swift
//  AutoCycleBannerDemo
//
//  Created by liuduo on 2022/9/21.
//

import UIKit
import AutoCycleBanner

class HeaderBanner: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    let banner: AutoCycleBanner = {
        let banner = AutoCycleBanner()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.backgroundColor = .blue
        return banner
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    private func commonInit() {
        banner.imageUrls = [
            "https://t7.baidu.com/it/u=963301259,1982396977&fm=193&f=GIF",
            "https://t7.baidu.com/it/u=1575628574,1150213623&fm=193&f=GIF",
            "https://t7.baidu.com/it/u=737555197,308540855&fm=193&f=GIF"
        ]
        banner.didTapIndex = {
            print($0)
        }
        banner.scrollInterval = 5
        addSubview(banner)
        
        NSLayoutConstraint.activate([
            banner.leftAnchor.constraint(equalTo: leftAnchor),
            banner.topAnchor.constraint(equalTo: topAnchor),
            banner.rightAnchor.constraint(equalTo: rightAnchor),
            banner.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        addSubview(pageControl)
        banner.pageControl = pageControl
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: banner.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
