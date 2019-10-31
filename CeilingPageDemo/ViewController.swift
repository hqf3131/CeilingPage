//
//  ViewController.swift
//  CeilingPageDemo
//
//  Created by Hubery on 2019/10/31.
//  Copyright © 2019 Hubery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bt = UIButton(type: .custom)
        bt.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        bt.backgroundColor = .yellow
        bt.addTarget(self, action: #selector(actionEvent), for: .touchUpInside)
        view.addSubview(bt)
    }
    
    @objc func actionEvent() {
        let vc = HomeMainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

