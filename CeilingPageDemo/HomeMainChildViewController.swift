//
//  HomeMainChildViewController.swift
//  CeilingPageDemo
//
//  Created by Hubery on 2019/10/31.
//  Copyright © 2019 Hubery. All rights reserved.
//

import UIKit

class HomeMainChildViewController: HQFCeilingChildViewController {

    private lazy var dataList: [String] = {
        var items = [String]()
        for i in 0..<100 {
            items.append("UITableView====\(i)")
        }
        return items
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            self.tableView.reloadData()
        })
    }
}

extension HomeMainChildViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "HQFCELL", for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
