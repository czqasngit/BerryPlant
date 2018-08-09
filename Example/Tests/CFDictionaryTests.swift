//
//  CFDictionaryTests.swift
//  BerryPlant_Example
//
//  Created by legendry on 2018/8/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import BerryPlant
import CoreFoundation

class CFDictionaryTests: XCTestCase {
    
    func testGetValue(){
        let cfDictionary = CFDictionaryCreateMutable(CFAllocatorGetDefault()!.takeUnretainedValue(), 0, nil, nil)
        let key = Unmanaged<NSString>.passRetained("name" as NSString).autorelease().toOpaque()
        let value = Unmanaged<NSString>.passRetained("9527" as NSString).autorelease().toOpaque()
        CFDictionaryAddValue(cfDictionary, key, value)
        XCTAssertTrue(CFDictionaryGetCount(cfDictionary) == 1)
        let result: NSString? = cfDictionary?.getValue(forKey: "name")
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "9527")
    }
    
}
