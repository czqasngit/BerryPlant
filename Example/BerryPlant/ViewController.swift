//
//  ViewController.swift
//  Berry
//
//  Created by czqasngit on 07/11/2018.
//  Copyright (c) 2018 czqasngit. All rights reserved.
//

import UIKit
import BerryPlant

class ViewController: UIViewController {

    
    var imageView: BerryAnimateImage!
    var data: Data!
    public func configure(with data: Data) {
        self.data = data
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        setup()
    }
    
    func setup(){
        self.imageView = BerryAnimateImage(data, frame: CGRect(x: 0, y: 200, width: self.view.frame.size.width, height: 300), cache: BerryAnimateImage.Policy.noCache)
        self.view.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.animationRepeatCount = 0
        
    }
    
    @IBAction func start(sender: UIButton) {
        guard !self.imageView._isAnimating else { return }
        self.imageView.startAnimating()
    }
}

