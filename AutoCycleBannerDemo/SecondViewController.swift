//
//  SecondViewController.swift
//  AutoCycleBannerDemo
//
//  Created by liuduo on 2022/9/20.
//

import UIKit
import AutoCycleBanner

class SecondViewController: UIViewController {

    let banner: AutoCycleBanner = {
        let banner = AutoCycleBanner()
        return banner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(banner)
        banner.startScrolling()
    }
    
    override func viewWillLayoutSubviews() {
        banner.frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 200)
        banner.imageUrls = [
            "https://t7.baidu.com/it/u=963301259,1982396977&fm=193&f=GIF",
            "https://t7.baidu.com/it/u=1575628574,1150213623&fm=193&f=GIF",
            "https://t7.baidu.com/it/u=737555197,308540855&fm=193&f=GIF"
        ]
    }
}
