//
//  TableViewController.swift
//  Berry_Example
//
//  Created by legendry on 2018/7/20.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var images: [String] = ["dance.apng", "j.webp", "kk.gif", "j.png", "1.jpg", "测试取消任务"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 5 {
            let name = images[indexPath.row]
            guard let url = Bundle.main.url(forResource: name, withExtension: nil),
                let data = try? Data(contentsOf: url),
                let c = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
                else {
                    return
            }
            c.configure(with: data)
            c.title = name
            self.navigationController?.pushViewController(c, animated: true)
        } else if indexPath.row == 5 {
            let c = TaskCancelViewController()
            self.navigationController?.pushViewController(c, animated: true)
        }
    }


}
