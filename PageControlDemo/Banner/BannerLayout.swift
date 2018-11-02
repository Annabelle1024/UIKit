
import UIKit

class BannerLayout: UICollectionViewLayout {
    
    internal var contentSize: CGSize = .zero
    internal var leadingSpacing: CGFloat = 0
    internal var itemSpacing: CGFloat = 0
    internal var needsReprepare = true
    internal var scrollDirection: BannerView.ScrollDirection = .horizontal
    
    open override class var layoutAttributesClass: AnyClass {
        return BannerLayoutAttributes.self
    }
    
    fileprivate var bannerView: BannerView? {
        return self.collectionView?.superview?.superview as? BannerView
    }
    
    fileprivate var isInfinite: Bool = true
    fileprivate var collectionViewSize: CGSize = .zero
    fileprivate var numberOfSections = 1
    fileprivate var numberOfItems = 0
    fileprivate var actualInteritemSpacing: CGFloat = 0
    fileprivate var actualItemSize: CGSize = .zero
    
    override init() {
        super.init()
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    deinit {
        #if !os(tvOS)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
    }
    
    // collection view 初次布局时调用该方法作为layout实例的首个信息, 如果布局被销毁重置(invalidateLayout()), 会重新调用改方法
    override open func prepare() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return
        }
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        self.needsReprepare = false
        self.collectionViewSize = collectionView.frame.size
        
        // 计算基础参数变量
        self.numberOfSections = bannerView.numberOfSections(in: collectionView)
        self.numberOfItems = bannerView.collectionView(collectionView, numberOfItemsInSection: 0)
        
        // item尺寸
        self.actualItemSize = {
            var size = bannerView.itemSize
            if size == .zero {
                size = collectionView.frame.size
            }
            return size
        }()
        
        // item之间间距
        self.actualInteritemSpacing = {
            return bannerView.interItemSpacing
        }()
        
        self.scrollDirection = bannerView.scrollDirection
        
        let horizontalLeadingSpace = (collectionView.frame.width - self.actualItemSize.width) * 0.5
        let verticalLeadingSpace = (collectionView.frame.height - self.actualItemSize.height) * 0.5
        self.leadingSpacing = self.scrollDirection == .horizontal ? horizontalLeadingSpace : verticalLeadingSpace
        
        self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
        
        // 计算并缓存contentSize, 不用每次都计算
        self.contentSize = {
            // item总数量
            let numberOfItems = self.numberOfItems * self.numberOfSections
            switch self.scrollDirection {
            case .horizontal:
                // leadingSpace + (n - 1)*interitemSpacing + n*itemSize + trailingSpace
                var contentSizeWidth: CGFloat = self.leadingSpacing * 2 // Leading & trailing spacing
                contentSizeWidth += CGFloat(numberOfItems-1) * self.actualInteritemSpacing // Interitem spacing
                contentSizeWidth += CGFloat(numberOfItems) * self.actualItemSize.width // Item sizes
                let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                return contentSize
            case .vertical:
                var contentSizeHeight: CGFloat = self.leadingSpacing * 2 // Leading & trailing spacing
                contentSizeHeight += CGFloat(numberOfItems-1) * self.actualInteritemSpacing // Interitem spacing
                contentSizeHeight += CGFloat(numberOfItems) * self.actualItemSize.height // Item sizes
                let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                return contentSize
            }
        }()
        self.adjustCollectionViewBounds()
    }
    
    
    /// 返回collectionView的内容的尺寸
    override open var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    /// 当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    // UICollectionView 通过调用layoutAttributesForElements和layoutAttributesForIteml方法去决定布局的属性
    
    /// 为指定 rect 中所有元素布局, 并返回所有的元素的布局属性.
    /// rect初始的layout的外观将由该方法返回的UICollectionViewLayoutAttributes来决定
    override open func layoutAttributesForElements(in rectOrigin: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemSpacing > 0, !rectOrigin.isEmpty else {
            return layoutAttributes
        }
        
        // 获取contentSize范围内的rect
        let rect = rectOrigin.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !rect.isEmpty else {
            return layoutAttributes
        }
        
        print("原始rect: \(rectOrigin)\n 计算后rect: \(rect)")
        
        // 计算 rect 范围内 items 的起点位置 && items 的 indexes
        
        // 1. 当前 rect 之前的 item 数量
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX - self.leadingSpacing)/self.itemSpacing), 0) : max(Int((rect.minY - self.leadingSpacing) / self.itemSpacing), 0)
        
        // 2. 当前 rect 范围内, item 的起点位置
        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore) * self.itemSpacing
        // 3. 当前 rect 范围内, item 的 index
        let startIndex = numberOfItemsBefore
       
        // 4. 创建布局属性
        var itemIndex = startIndex
        var origin = startPosition
        
        // 5. 当前 rect 范围内, 最大位置(根据滚动方向决定是横向还是纵向最大位置)
        // (self.contentSize.width - self.actualItemSize.width - self.leadingSpacing) 为最后一个 Item 的 x 坐标位置
        let maxHorizontalPosition = min(rect.maxX, self.contentSize.width - self.actualItemSize.width - self.leadingSpacing)
        let maxVerticalPosiztion = min(rect.maxY, self.contentSize.height - self.actualItemSize.height - self.leadingSpacing)
        
        let maxPosition = self.scrollDirection == .horizontal ? maxHorizontalPosition : maxVerticalPosiztion
        
        /// https://stackoverflow.com/a/10335601/2398107
        /// 浮点数比较时的精度问题: (fabs(x-y) < K * FLT_EPSILON * fabs(x+y))
        /// leastNonzeroMagnitude 最小非零数, ulpOfOne 代表允许误差为1.0
        /// k 代表最后累计计算误差在 k 个单位内
        
        // 计算 rect 范围内每个 item 的属性
        while origin - maxPosition <= max(CGFloat(100.0) * .ulpOfOne * abs(origin + maxPosition), .leastNonzeroMagnitude) {
            let indexPath = IndexPath(item: itemIndex % self.numberOfItems, section: itemIndex/self.numberOfItems)
            let attributes = self.layoutAttributesForItem(at: indexPath) as! BannerLayoutAttributes
            //            self.applyTransform(to: attributes, with: self.bannerView?.transformer)
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemSpacing
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = BannerLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        return attributes
    }
    
    /// 如果 bannerViewWillBeginDragging 方法被调用, 重写 targetContentOffset 方法会被调用, 返回 targetOffset
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return proposedContentOffset
        }
        var suggestedContentOffset = proposedContentOffset

        func calculateTargetOffset(by proposedOffset: CGFloat, boundedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            
            // 如果减速距离 == 0
            if bannerView.decelerationDistance == BannerView.automaticDistance {
                if abs(velocity.x) >= 0.3 {
                    let vector: CGFloat = velocity.x >= 0 ? 1.0 : -1.0
                    // Ceil by 0.15, rather than 0.5
                    targetOffset = round(proposedOffset / self.itemSpacing + 0.35 * vector) * self.itemSpacing
                } else {
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            } else {
                let extraDistance = max(bannerView.decelerationDistance - 1, 0)
                switch velocity.x {
                case 0.3 ... CGFloat.greatestFiniteMagnitude:
                    targetOffset = ceil(collectionView.contentOffset.x / self.itemSpacing + CGFloat(extraDistance)) * self.itemSpacing
                case -CGFloat.greatestFiniteMagnitude ... -0.3:
                    targetOffset = floor(collectionView.contentOffset.x / self.itemSpacing - CGFloat(extraDistance)) * self.itemSpacing
                default:
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            }
            targetOffset = max(0, targetOffset)
            targetOffset = min(boundedOffset, targetOffset)
            return targetOffset
        }
        let proposedContentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return suggestedContentOffset.x
            }
            let boundedOffset = collectionView.contentSize.width - self.itemSpacing
            return calculateTargetOffset(by: suggestedContentOffset.x, boundedOffset: boundedOffset)
        }()
        let proposedContentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return suggestedContentOffset.y
            }
            let boundedOffset = collectionView.contentSize.height - self.itemSpacing
            return calculateTargetOffset(by: suggestedContentOffset.y, boundedOffset: boundedOffset)
        }()
        suggestedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffsetY)
        return suggestedContentOffset
    }
    
    // MARK:- Internal functions
    
    /// 重置layout
    internal func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    // 计算指定 indexPath 的 contentOffset
    internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width * 0.5 - self.actualItemSize.width * 0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height * 0.5 - self.actualItemSize.height * 0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }
    
    internal func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems * indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (self.collectionView!.frame.width - self.actualItemSize.width) * 0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (self.collectionView!.frame.height - self.actualItemSize.height) * 0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.actualItemSize)
        return frame
    }
    
    // MARK:- Notification
    @objc
    fileprivate func didReceiveNotification(notification: Notification) {
        if self.bannerView?.itemSize == .zero {
            self.adjustCollectionViewBounds()
        }
    }
    
    // MARK:- Private functions
    
    fileprivate func setup() {
        #if !os(tvOS)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
    }
    
    // 调整collectionView的bounds
    fileprivate func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let bannerView = self.bannerView else {
            return
        }
        // 每次重新调整, indexPath都从中间section的currentIndex算起
        let currentIndex = max(0, min(bannerView.currentIndex, bannerView.numberOfItems - 1))
        let newIndexPath = IndexPath(item: currentIndex, section: self.isInfinite ? self.numberOfSections/2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
        bannerView.currentIndex = currentIndex
    }
}
