//
//  BannerView.swift
//  PageControlDemo
//
//  Created by Annabelle on 2018/10/30.
//  Copyright © 2018 杨静. All rights reserved.
//

import UIKit

@objc
public protocol SINBannerViewDataSource: NSObjectProtocol {
    
    /// Asks your data source object for the number of items in the banner View.
    @objc(numberOfItemsInBannerView:)
    func numberOfItems(in bannerView: BannerView) -> Int
    
    /// Asks your data source object for the cell that corresponds to the specified item in the banner View.
    @objc(bannerView:cellForItemAtIndex:)
    func bannerView(_ bannerView: BannerView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

@objc
public protocol SINBannerViewDelegate: NSObjectProtocol {
    
    /// Asks the delegate if the item should be highlighted during tracking.
    @objc(bannerView:shouldHighlightItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, shouldHighlightItemAt index: Int) -> Bool

    /// Tells the delegate that the item at the specified index was highlighted.
    @objc(bannerView:didHighlightItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, didHighlightItemAt index: Int)
    
    /// Asks the delegate if the specified item should be selected.
    @objc(bannerView:shouldSelectItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, shouldSelectItemAt index: Int) -> Bool
    
    /// Tells the delegate that the item at the specified index was selected.
    @objc(bannerView:didSelectItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int)
    
    /// Tells the delegate that the specified cell is about to be displayed in the banner view.
    @objc(bannerView:willDisplayCell:forItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    /// Tells the delegate that the specified cell was removed from the banner view.
    @objc(bannerView:didEndDisplayingCell:forItemAtIndex:)
    optional func bannerView(_ bannerView: BannerView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    /// Tells the delegate when the banner view is about to start scrolling the content.
    @objc(pagerViewWillBeginDragging:)
    optional func bannerViewWillBeginDragging(_ bannerView: BannerView)
    
    /// Tells the delegate when the user finishes scrolling the content.
    @objc(pagerViewWillEndDragging:targetIndex:)
    optional func bannerViewWillEndDragging(_ bannerView: BannerView, targetIndex: Int)
    
    /// Tells the delegate when the user scrolls the content view within the receiver.
    @objc(pagerViewDidScroll:)
    optional func bannerViewDidScroll(_ bannerView: BannerView)
    
    /// Tells the delegate when a scrolling animation in the banner View concludes.
    @objc(pagerViewDidEndScrollAnimation:)
    optional func bannerViewDidEndScrollAnimation(_ bannerView: BannerView)
    
    /// Tells the delegate that the banner View has ended decelerating the scrolling movement.
    @objc(pagerViewDidEndDecelerating:)
    optional func bannerViewDidEndDecelerating(_ bannerView: BannerView)
    
}

public class BannerView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    // MARK: - Public properties
    
    /// The object that acts as the data source of the banner View.
    open weak var dataSource: SINBannerViewDataSource?
    
    /// The object that acts as the delegate of the banner View.
    open weak var delegate: SINBannerViewDelegate?
    
    /// The scroll direction of the banner View. Default is horizontal.
    @objc
    open var scrollDirection: BannerView.ScrollDirection = .horizontal {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0.
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    /// The spacing to use between items in the banner View. Default is 0.
    @IBInspectable
    open var interItemSpacing: CGFloat = 0 {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// The item size of the banner view. When the value of this property is BannerView.automaticSize, the items fill the entire visible area of the banner View. Default is BannerView.automaticSize.
    open var itemSize: CGSize = automaticSize {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// A Boolean value indicates that whether the banner View has infinite items. Default is false.
    open var isInfinite: Bool = false {
        didSet {
            self.collectionViewLayout.needsReprepare = true
            self.collectionView.reloadData()
        }
    }
    
    /// An unsigned integer value that determines the deceleration distance of the banner View, which indicates the number of passing items during the deceleration. When the value of this property is BannerView.automaticDistance, the actual 'distance' is automatically calculated according to the scrolling speed of the banner View. Default is 1.
    open var decelerationDistance: UInt = 1
    
    /// A Boolean value that determines whether scrolling is enabled.
    open var isScrollEnabled: Bool {
        set { self.collectionView.isScrollEnabled = newValue }
        get { return self.collectionView.isScrollEnabled }
    }
    
    // 回弹
    /// A Boolean value that controls whether the banner View bounces past the edge of content and back again.
    open var bounces: Bool {
        get { return self.collectionView.bounces }
        set { self.collectionView.bounces = newValue }
    }
    
    /// A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
    open var alwaysBounceHorizontal: Bool {
        set { self.collectionView.alwaysBounceHorizontal = newValue }
        get { return self.collectionView.alwaysBounceHorizontal }
    }
    
    /// A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content view.
    open var alwaysBounceVertical: Bool {
        set { self.collectionView.alwaysBounceVertical = newValue }
        get { return self.collectionView.alwaysBounceVertical }
    }
    
    /// A Boolean value that controls whether the infinite loop is removed if there is only one item. Default is false.
    open var removesInfiniteLoopForSingleItem: Bool = false {
        didSet {
            self.refreshData()
        }
    }
    
    open var cornerRadius: CGFloat {
        
        set {
            if self.itemSize == BannerView.automaticSize {
                self.collectionView.layer.cornerRadius = newValue
                self.collectionView.layer.masksToBounds = true
                
            } else {
                // 需要设置cell的layer corner
            }
        }
        
        get {
            return self.collectionView.layer.cornerRadius
        }
    }
    
//    /// The background view of the banner View.
//    open var backgroundView: UIView? {
//        didSet {
//            if let backgroundView = self.backgroundView {
//                if backgroundView.superview != nil {
//                    backgroundView.removeFromSuperview()
//                }
//                self.insertSubview(backgroundView, at: 0)
//                self.setNeedsLayout()
//            }
//        }
//    }
    
     // MARK: - Public readonly-properties
    
    /// Returns whether the user has touched the content to initiate scrolling.
    @objc
    open var isTracking: Bool {
        return self.collectionView.isTracking
    }
    
    /// The percentage of x position at which the origin of the content view is offset from the origin of the pagerView view.
    @objc
    open var scrollOffset: CGFloat {
        let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
        let scrollOffset = Double(contentOffset / self.collectionViewLayout.itemSpacing)
        
        // 浮点数取模
        return fmod(CGFloat(scrollOffset), CGFloat(Double(self.numberOfItems)))
    }
    
    
    /// The underlying gesture recognizer for pan gestures.
    @objc
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    @objc open internal(set) dynamic var currentIndex: Int = 0

    
    // MARK: - Private properties
    internal weak var collectionViewLayout: BannerLayout!
    internal weak var collectionView: BannerCollectionView!
    internal weak var contentView: UIView!
    
    internal var timer: Timer?
    internal var numberOfItems: Int = 0
    internal var numberOfSections: Int = 0
    
    // 当前入队section(正在展示的cell所在section)
    fileprivate var dequeingSection = 0
    
    // 最中间的indexPath
    fileprivate var middlemostIndexPath: IndexPath {
        guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        
        let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
            
            // 上一张
            let leftFrame = self.collectionViewLayout.frame(for: l)
            // 下一张
            let rightFrame = self.collectionViewLayout.frame(for: r)
            
            var leftCenter: CGFloat
            var rightCenter: CGFloat
            // 标尺
            var ruler: CGFloat
            
            switch self.scrollDirection {
            case .horizontal:
                leftCenter = leftFrame.midX
                rightCenter = rightFrame.midX
                ruler = self.collectionView.bounds.midX
            case .vertical:
                leftCenter = leftFrame.midY
                rightCenter = rightFrame.midY
                ruler = self.collectionView.bounds.midY
            }
            
            return abs(ruler - leftCenter) < abs(ruler - rightCenter)
        }
        
        let indexPath = sortedIndexPaths.first
        if let indexPath = indexPath {
            return indexPath
        }
        return IndexPath(item: 0, section: 0)
    }
    
    
    fileprivate var possibleTargetingIndexPath: IndexPath?

    // MARK: - Overriden functions
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
//        self.backgroundView?.frame = self.bounds
        self.contentView.frame = self.bounds
        self.collectionView.frame = self.contentView.bounds
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }
    
    // MARK: - Public functions
    
    /// 注册 cell
    @objc open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// 返回一个可复用的cell
    ///
    /// - Parameters:
    ///   - allowShadow: 是否需要阴影
    /// - Returns: 返回 UICollectionViewCell
    @objc open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int, allowShadow: Bool) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if allowShadow {
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowRadius = 5
            cell.contentView.layer.shadowOpacity = 0.75
            cell.contentView.layer.shadowOffset = .zero
        }
        
        return cell
    }
    
    /// 刷新 collectionView 数据和布局
    @objc open func refreshData() {
        self.collectionViewLayout.needsReprepare = true;
        self.collectionView.reloadData()
    }
    
    /// 选中指定 index 处的 item，并可将其滚动到视图中
    @objc open func selectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    /// 取消选中指定 index 处的 item
    @objc open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    /// 滚动视图 content 到指定的 index
    @objc open func scrollToItem(at index: Int, animated: Bool) {
        guard index < self.numberOfItems else {
            fatalError("index \(index) is out of range [0...\(self.numberOfItems-1)]")
        }
        let indexPath = { () -> IndexPath in
            if let indexPath = self.possibleTargetingIndexPath, indexPath.item == index {
                defer {
                    self.possibleTargetingIndexPath = nil
                }
                return indexPath
            }
            return self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        }()
        let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    /// 返回指定 cell 的 index, 如果没有, 则返回 NSNotFound
    @objc open func index(for cell: UICollectionViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }
    
    /// 返回指定 index 的可见 cell
    /// 如果当前 cell 不可见, 或者 index 超出范围, 则返回 nil
    @objc open func cellForItem(at index: Int) -> UICollectionViewCell? {
        let indexPath = self.nearbyIndexPath(for: index)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0;
        }
        
        // section = Int(Int16.max) / self.numberOfItems
        self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? self.numberOfItems : 1
//        self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? Int(Int16.max) / self.numberOfItems : 1
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.bannerView(self, cellForItemAt: index)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.bannerView(_:shouldHighlightItemAt:) else {
            return true
        }

        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didHighlightItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        guard let function = self.delegate?.bannerView(_:shouldSelectItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didSelectItemAt:) else {
            return
        }
        self.possibleTargetingIndexPath = indexPath
        defer {
            self.possibleTargetingIndexPath = nil
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:willDisplay:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self, cell, index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.bannerView(_:didEndDisplaying:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self, cell, index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.numberOfItems > 0 {
            // In case someone is using KVO
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if (currentIndex != self.currentIndex) {
                self.currentIndex = currentIndex
            }
        }
        guard let function = self.delegate?.bannerViewDidScroll else {
            return
        }
        function(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewWillBeginDragging(_:) {
            function(self)
        }
        if self.automaticSlidingInterval > 0 {
            self.cancelTimer()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = self.delegate?.bannerViewWillEndDragging(_:targetIndex:) {
            let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset / self.collectionViewLayout.itemSpacing))
            function(self, targetItem % self.numberOfItems)
        }
        if self.automaticSlidingInterval > 0 {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewDidEndDecelerating {
            function(self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let function = self.delegate?.bannerViewDidEndScrollAnimation {
            function(self)
        }
    }

    
    // MARK: - Private functions
    
    fileprivate func setup() {
        
        // Content View
        let contentView = UIView(frame:CGRect.zero)
        contentView.backgroundColor = UIColor.clear
        self.addSubview(contentView)
        self.contentView = contentView
        
        // UICollectionView
        let collectionViewLayout = BannerLayout()
        let collectionView = BannerCollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
        
    }
    
    // 开启时钟
    fileprivate func startTimer() {
        guard self.automaticSlidingInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval), target: self, selector: #selector(self.updateTimer(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    // 更新时钟
    @objc fileprivate func updateTimer(sender: Timer?) {
        guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.isTracking else {
            return
        }
        
        // indexPath.section + (indexPath.item + 1) / self.numberOfItems 会直接取整
        let contentOffset: CGPoint = {
            let indexPath = self.middlemostIndexPath
            let section = self.numberOfSections > 1 ? (indexPath.section + (indexPath.item + 1) / self.numberOfItems) : 0
            let item = (indexPath.item + 1) % self.numberOfItems
            return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
        }()
        self.collectionView.setContentOffset(contentOffset, animated: true)
    }
    
    // 销毁时钟
    fileprivate func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    fileprivate func nearbyIndexPath(for index: Int) -> IndexPath {
        let currentIndex = self.currentIndex
        let currentSection = self.middlemostIndexPath.section
        if abs(currentIndex - index) <= self.numberOfItems/2 {
            return IndexPath(item: index, section: currentSection)
        } else if (index - currentIndex >= 0) {
            return IndexPath(item: index, section: currentSection - 1)
        } else {
            return IndexPath(item: index, section: currentSection + 1)
        }
    }
}

extension BannerView {
    
    /// Constants indicating the direction of scrolling for the banner View.
    @objc public enum ScrollDirection: Int {
        /// The banner View scrolls content horizontally
        case horizontal
        /// The banner View scrolls content vertically
        case vertical
    }
    
    /// Requests that BannerView use the default value for a given distance.
    public static let automaticDistance: UInt = 0
    
    /// Requests that BannerView use the default value for a given size.
    public static let automaticSize: CGSize = .zero
    
}

