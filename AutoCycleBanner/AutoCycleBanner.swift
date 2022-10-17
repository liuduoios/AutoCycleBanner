//
//  AutoCycleBanner.swift
//  AutoCycleBanner
//
//  Created by liuduo on 2022/9/20.
//

import UIKit
import SDWebImage

private let cellIdentifier = "BannerCell"

open class AutoCycleBanner: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }()
    
    public lazy var pageControl: UIPageControl = innerPageControl! {
        didSet {
            pageControl.numberOfPages = imageUrls.count
            oldValue.removeFromSuperview()
            innerPageControl = nil
        }
    }
    private var innerPageControl: UIPageControl? = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    /// 图片未加载到时的占位图
    public var placeholderImage: UIImage?
    
    /// 图片的 url 数据
    public var imageUrls = [String]() {
        didSet {
            pageControl.numberOfPages = imageUrls.count
            collectionView.reloadData()
        }
    }
    
    /// 点击某个图片时回调，参数为图片索引下标
    public var didTapIndex: ((Int) -> Void)?
    
    /// 每次滚动的间隔时间
    public var scrollInterval: TimeInterval = 2 {
        didSet {
            if scrollInterval != oldValue {
                endScrolling()
                startScrolling()
            }
        }
    }
    
    private var timer: Timer?
    private var pageIndex = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(collectionView)
        addSubview(pageControl)
        startScrolling()
    }
    
    deinit {
        print(#function)
    }
    
    /// 开始滚动
    public func startScrolling() {
        if let timer = timer, timer.isValid {
            return
        }
        
        timer = Timer(timeInterval: scrollInterval, repeats: true, block: { [weak self] timer in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            self.scrollToNextPage()
        })
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    /// 结束滚动
    public func endScrolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public override func layoutSubviews() {
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = bounds.size
        
        if let pageControl = innerPageControl {
            pageControl.frame = CGRect(x: (bounds.width - pageControl.frame.width) * 0.5,
                                       y: bounds.height - pageControl.frame.height,
                                       width: pageControl.frame.width,
                                       height: pageControl.frame.height)
        }
    }
    
    private func reset() {
        pageIndex = 1
        scrollToIndex(pageIndex, animated: false)
    }
    
    private func resetToLastImage() {
        pageIndex = imageUrls.count
        scrollToIndex(pageIndex, animated: false)
    }
    
    private func scrollToNextPage() {
        pageIndex = pageIndex + 1
        if pageIndex == imageUrls.count {
            scrollToExtraPage()
        } else {
            scrollToIndex(pageIndex, animated: true)
        }
    }
    
    private func scrollToExtraPage() {
        scrollToIndex(imageUrls.count, animated: true)
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool) {
        let offset = Double(index) * collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        pageControl.currentPage = imageIndexWithItemIndex(index)
    }
    
    private func imageIndexWithItemIndex(_ item: Int) -> Int {
        var index: Int
        if item == 0 {
            index = imageUrls.count - 1
        } else if item == collectionView.numberOfItems(inSection: 0) - 1 {
            index = 0
        } else {
            index = item - 1
        }
        return index
    }
}

extension AutoCycleBanner: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageUrls.count > 0 {
            return 1 + imageUrls.count + 1 // 首尾各多一个
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BannerCell
        
        let index = imageIndexWithItemIndex(indexPath.item)
        cell.label.text = "\(index)"
        if let imageURL = URL(string: imageUrls[index]) {
            cell.imageView.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
        
        return cell
    }
}

extension AutoCycleBanner: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageIndex = imageIndexWithItemIndex(indexPath.item)
        didTapIndex?(imageIndex)
    }
}

extension AutoCycleBanner: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.width {
            // 如果滚动到后面的附加页，则刷成第一张图片
            reset()
        } else if scrollView.contentOffset.x == 0 {
            // 如果滚动到前面的附加页，则刷成最后一张图片
            resetToLastImage()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageIndex = pageIndexWithOffset()
        pageControl.currentPage = imageIndexWithItemIndex(pageIndex)
    }
    
    private func pageIndexWithOffset() -> Int {
        Int(collectionView.contentOffset.x / collectionView.bounds.width)
    }
}
