//
//  TaskCancelViewController.swift
//  BerryPlant_Example
//
//  Created by legendry on 2019/2/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import BerryPlant

class TaskCancelViewController: UIViewController {

    public let imageView = UIImageView(frame: CGRect.init(x: 100, y: 100, width: 200, height: 200))
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.imageView)
        DispatchQueue.global().async {
            let image = UIImage(named: "t")!
            self.imageView.async.setImage(image: image)
//            self.imageView.async.cancel()
            self.imageView.async.setImage(image: UIImage(named: "x")!)
        }
    }

}
