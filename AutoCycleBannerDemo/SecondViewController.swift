//
//  SecondViewController.swift
//  AutoCycleBannerDemo
//
//  Created by liuduo on 2022/9/20.
//

import UIKit
import AutoCycleBanner

class SecondViewController: UIViewController {

    let banner = HeaderBanner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(banner)
    }
    
    override func viewWillLayoutSubviews() {
        banner.frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 200)
    }
}
