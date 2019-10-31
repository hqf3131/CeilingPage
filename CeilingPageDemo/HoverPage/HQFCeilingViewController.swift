//
//  HQFHoverViewController.swift
//  CeilingPageDemo
//
//  Created by Hubery on 2019/10/31.
//  Copyright © 2019 Hubery. All rights reserved.
//

import UIKit

protocol CeilingChildViewControllerDelegate: NSObjectProtocol {
    func ceilingChildViewController(_ viewController: CeilingChildViewController, scrollViewDidScroll scrollView: UIScrollView)
}

protocol CeilingPageViewControllerDelegate: NSObjectProtocol {
    func ceilingPageViewController(_ viewController: HQFCeilingViewController, scrollViewDidScroll scrollView: UIScrollView)
    func ceilingPageViewController(_ viewController: HQFCeilingViewController, scrollViewDidEndDecelerating scrollView: UIScrollView)
    /**
     mainTableView滑动，用于实现导航栏渐变、头图缩放等
     
     @param scrollView mainTableView
     @param isMainCanScroll 是否到达临界点，YES表示到达临界点，mainTableView不再滑动，NO表示我到达临界点，mainTableView仍可滑动
     */
    func mainTableViewDidScroll(scrollView: UIScrollView,isMainCanScroll: Bool)
}

class CeilingChildViewController: UIViewController {
    
    public var offsetY: CGFloat = 0.0
    public var isCanScroll: Bool = false
    public weak var scrollDelegate: CeilingChildViewControllerDelegate?
    public func getScrollView () -> UIScrollView? {
        return nil
    }
}

class CeilingPageScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    public var scrollViewWhites: Set<UIScrollView>?
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollViewWhites = scrollViewWhites else { return true }
        for item in scrollViewWhites {
            if let view = otherGestureRecognizer.view, view == item {
                return true
            }
        }
        return false
    }
}

class HQFCeilingViewController: UIViewController {
    
    weak var delegate: CeilingPageViewControllerDelegate?
    
    fileprivate(set) var viewControllers = [CeilingChildViewController]()
    fileprivate(set) var headerView: UIView!
    fileprivate(set) var pageTitleView: UIView!
    fileprivate(set) var currentIndex: Int = 0
    fileprivate var mainScrollView: CeilingPageScrollView!
    fileprivate var pageScrollView: UIScrollView!
    fileprivate var hover: CGFloat = 0
    // 吸顶临界点高度（headerView高度-(状态栏+导航栏)）
    fileprivate var ceilPointHeight: CGFloat = 0
    // 是否滑到临界点
    fileprivate var isCriticalPoint: Bool = false
    // mainTableView 是否可以滑动
    fileprivate var isMainCanScroll: Bool = true
    // listScrollView 是否可以滑动
    fileprivate var isListCanScroll: Bool = false
    
    init(_ viewControllers: [CeilingChildViewController], _ headerView: UIView, _ pageTitleView: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        self.headerView = headerView
        self.pageTitleView = pageTitleView
        self.ceilPointHeight = headerView.height - NAVIGATION_BAR_HEIGHT
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func move(to: Int, animated: Bool) {
        view.isUserInteractionEnabled = false
        viewControllers.forEach { $0.isCanScroll = true }
        pageScrollView.setContentOffset(CGPoint(x: CGFloat(to) * view.frame.width, y: 0), animated: animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.scrollViewDidEndDecelerating(self.pageScrollView)
            self.view.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mainScrollHeigt = (headerView.height - NAVIGATION_BAR_HEIGHT) + APP_FRAME_HEIGHT
        mainScrollView.frame = view.bounds
        mainScrollView.contentSize = CGSize(width: 0, height: mainScrollHeigt)
        pageTitleView.frame.origin.y = headerView.frame.maxY
        pageScrollView.frame.origin.y = pageTitleView.frame.maxY
        pageScrollView.frame.size = CGSize(width: view.frame.width, height: mainScrollHeigt - pageTitleView.frame.maxY)
        pageScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(viewControllers.count), height: 0)
        
        var scrollViews = Set<UIScrollView>()
        for i in 0..<viewControllers.count {
            let child = viewControllers[i]
            child.view.frame = CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: pageScrollView.width, height: pageScrollView.height)
            if let scrollView = child.getScrollView() {
                scrollViews.insert(scrollView)
            }
        }
        mainScrollView.scrollViewWhites = scrollViews
    }
}

extension HQFCeilingViewController {
    
    fileprivate func prepareView() {
        mainScrollView = CeilingPageScrollView()
        mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(headerView)
        mainScrollView.addSubview(pageTitleView)
        
        pageScrollView = UIScrollView()
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.isPagingEnabled = true
        pageScrollView.delegate = self
        pageScrollView.bounces = false
        mainScrollView.addSubview(pageScrollView)
        
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        for child in viewControllers {
            child.scrollDelegate = self
            pageScrollView.addSubview(child.view)
            addChild(child)
        }
    }
}

extension HQFCeilingViewController: CeilingChildViewControllerDelegate {
    
    func ceilingChildViewController(_ viewController: CeilingChildViewController, scrollViewDidScroll scrollView: UIScrollView) {
        
        // listScrollView 下滑至offsetY 小于0，禁止其滑动，让mainTableView 可下滑
        if scrollView.contentOffset.y <= 0 {
            self.isMainCanScroll = true
            self.isListCanScroll = false
            let child = viewControllers[currentIndex]
            child.offsetY = 0
        }else {
            if self.isListCanScroll {
                // 如果此时mainTableView 并没有滑动，则禁止listView滑动
                if mainScrollView.contentOffset.y == 0 {
                    self.isMainCanScroll = true
                    self.isListCanScroll = false
                    let child = viewControllers[currentIndex]
                    child.offsetY = 0
                }else {
                    // 矫正mainTableView 的位置
                    mainScrollView.contentOffset = CGPoint(x: 0, y: ceilPointHeight)
                }
            }else{
                let child = viewControllers[currentIndex]
                child.offsetY = 0
            }
        }
    }
}

extension HQFCeilingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pageScrollView.isScrollEnabled = true
        mainScrollView.isScrollEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageScrollView.isScrollEnabled = true
        mainScrollView.isScrollEnabled = true
        currentIndex = Int(pageScrollView.contentOffset.x / pageScrollView.frame.width + 0.5) % viewControllers.count
        if scrollView == pageScrollView {
            delegate?.ceilingPageViewController(self, scrollViewDidEndDecelerating: scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            pageScrollView.isScrollEnabled = false
            
            //根据偏移量判断是否上滑到临界点
            if scrollView.contentOffset.y >= ceilPointHeight {
                self.isCriticalPoint = true
            }else {
                self.isCriticalPoint = false
            }
            
            if self.isCriticalPoint {
                // 上滑到临界点后，固定其位置
                scrollView.contentOffset = CGPoint(x: 0, y: ceilPointHeight)
                self.isMainCanScroll = false
                self.isListCanScroll = true
            }else{
                if self.isMainCanScroll {
                    // 未到达临界点，mainScrollview 可滑动，需要重置所有listScrollView 的位置
                    let child = viewControllers[currentIndex]
                    child.offsetY = 0
                }else{
                    // 未到达临界点，mainScrollview 不可滑动，固定其位置
                    scrollView.contentOffset = CGPoint(x: 0, y: ceilPointHeight)
                }
            }
            delegate?.mainTableViewDidScroll(scrollView: scrollView, isMainCanScroll: self.isMainCanScroll)
        } else if scrollView == pageScrollView {
            mainScrollView.isScrollEnabled = false
            delegate?.ceilingPageViewController(self, scrollViewDidScroll: scrollView)
        }
    }
}
