//
//  HomeMainViewController.swift
//  CeilingPageDemo
//
//  Created by Hubery on 2019/10/31.
//  Copyright © 2019 Hubery. All rights reserved.
//

import UIKit

class HomeMainViewController: UIViewController {

    var ceilingViewController:HQFCeilingViewController!
    
    //top header Item
    lazy var topHeaderView: UIView = {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: APP_FRAME_WIDTH, height: 300)
        headerView.backgroundColor = .red
        return headerView
    }()
    
    //title Item
    lazy var pageTitleView: UIView = {
        let titleView = UIView()
        titleView.frame.size = CGSize(width: view.frame.width, height: 40)

        /// 添加3个按钮
        let buttonSize = CGSize(width: view.frame.width / 3, height: 40)
        for i in 0..<3 {
            let button = UIButton()
            button.tag = 100 + i
            button.frame.size = buttonSize
            button.backgroundColor = UIColor.lightGray
            button.frame.origin.x = CGFloat(i) * buttonSize.width
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle("控制器\(i)", for: .normal)
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            titleView.addSubview(button)
        }
        return titleView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "吸顶页面"
        self.view.backgroundColor = .white
        
        /// 添加子控制器
        var viewControllers = [HomeMainChildViewController]()
        let vc1 = HomeMainChildViewController()
        let vc2 = HomeMainChildViewController()
        let vc3 = HomeMainChildViewController()
        viewControllers.append(vc1)
        viewControllers.append(vc2)
        viewControllers.append(vc3)
        
        /// 添加分页控制器
        ceilingViewController = HQFCeilingViewController(viewControllers, topHeaderView, pageTitleView)
        ceilingViewController.delegate = self
        ceilingViewController.view.frame = CGRect(x: 0, y: 0, width: APP_FRAME_WIDTH, height: APP_FRAME_HEIGHT)
        addChild(ceilingViewController)
        view.addSubview(ceilingViewController.view)
    }
    
    @objc func buttonClick(btn: UIButton) {
        ceilingViewController.move(to: btn.tag-100, animated: true)
    }
}

extension HomeMainViewController:CeilingPageViewControllerDelegate {
    
    func mainTableViewDidScroll(scrollView: UIScrollView, isMainCanScroll: Bool) {
        
    }
    
    func ceilingPageViewController(_ viewController: HQFCeilingViewController, scrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    func ceilingPageViewController(_ viewController: HQFCeilingViewController, scrollViewDidEndDecelerating scrollView: UIScrollView) {
        
    }
    
}
