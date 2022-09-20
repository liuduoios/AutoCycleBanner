//
//  AutoCycleBanner.swift
//  AutoCycleBanner
//
//  Created by liuduo on 2022/9/20.
//

import UIKit
import SDWebImage

private let cellIdentifier = "BannerCell"

public class AutoCycleBanner: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    public var imageUrls = [String]() {
        didSet {
            pageControl.numberOfPages = imageUrls.count
            collectionView.reloadData()
        }
    }
    
//    public var items: [(imageUrl: String, title: String, didSelectAction: () -> Void)] = [] {
//        didSet {
//            pageControl.numberOfPages = imageUrls.count
//            collectionView.reloadData()
//        }
//    }
    
    private var timer: Timer?
    private var currentIndex = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    deinit {
        print(#function)
    }
    
    public func startScrolling() {
        if let timer = timer, timer.isValid {
            return
        }
        
        timer = Timer(timeInterval: 2, repeats: true, block: { [weak self] timer in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            self.scrollToNextIndex()
        })
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    public func endScrolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public override var frame: CGRect {
        didSet {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = bounds.size
        }
    }
    
    public override func layoutSubviews() {
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: (bounds.width - pageControl.frame.width) * 0.5,
                                   y: bounds.height - pageControl.frame.height,
                                   width: pageControl.frame.width,
                                   height: pageControl.frame.height)
    }
    
    public func reset() {
        currentIndex = 0
        scrollToIndex(currentIndex, animated: false)
    }
    
    public func scrollToNextIndex() {
        currentIndex = currentIndex + 1
        if currentIndex == imageUrls.count {
            scrollToExtraPage()
            pageControl.currentPage = 0
        } else {
            scrollToIndex(currentIndex, animated: true)
            pageControl.currentPage = currentIndex
        }
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool) {
        let offset = Double(index) * collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }
    
    public func scrollToExtraPage() {
        collectionView.setContentOffset(CGPoint(x: Double(imageUrls.count) * collectionView.bounds.width, y: 0), animated: true)
    }
}

extension AutoCycleBanner: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageUrls.count > 0 {
            return imageUrls.count + 1
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BannerCell
        if indexPath.item == imageUrls.count {
            cell.label.text = "\(0)"
            if let imageURL = URL(string: imageUrls[0]) {
                cell.imageView.sd_setImage(with: imageURL, placeholderImage: nil)
            }
        } else {
            cell.label.text = "\(indexPath.item)"
            if let imageURL = URL(string: imageUrls[indexPath.item]) {
                cell.imageView.sd_setImage(with: imageURL, placeholderImage: nil)
            }
        }
        
        return cell
    }
}

extension AutoCycleBanner: UICollectionViewDelegate {
    
}

extension AutoCycleBanner: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果滚动到的附加页，则重新刷成第一页
        if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.width {
            reset()
        }
    }
}
