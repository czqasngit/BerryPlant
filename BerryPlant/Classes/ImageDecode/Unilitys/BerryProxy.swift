//
//  BerryProxy.swift
//  Berry
//
//  Created by legendry on 2018/7/19.
//

import Foundation

class BerryProxy: NSObject {
    
    weak var target: NSObject?
    init(target: NSObject) {
        super.init()
        self.target = target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return self.target?.responds(to: aSelector) ?? false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.target
    }
    
}
