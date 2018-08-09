//
//  DataTests.swift
//  BerryPlant_Example
//
//  Created by legendry on 2018/8/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import BerryPlant
import CoreFoundation

class DataTests: XCTestCase {
    
    let _bytes: [UInt8] = [0x52, 0x49, 0x46, 0x46, 0x90, 0xF8, 0x00, 0x00, 0x57, 0x45, 0x42, 0x50, 0x56, 0x50, 0x38, 0x20, 0x84, 0xF8, 0x00, 0x00, 0x30, 0xA2, 0x01, 0x9D, 0x01, 0x2A, 0x09, 0x02, 0xB6, 0x01, 0x3E, 0x04, 0x01, 0x35, 0x00, 0x00, 0x08, 0x96, 0x36, 0xEF, 0xC6, 0x7F, 0x9C] ;
    var _data: Data! = nil
    
    
    override func setUp() {
        super.setUp()
        _data = Data(bytes: _bytes)
    }
    func testData() {
        var rangeBytes = [UInt8](UnsafeMutableBufferPointer<UInt8>.init(start: _data.copyBytes(from: 0, to: 4), count: 4))
        XCTAssertEqual(rangeBytes, [0x52, 0x49, 0x46, 0x46])
        rangeBytes = [UInt8](UnsafeMutableBufferPointer<UInt8>.init(start: _data.copyBytes(from: 6, to: 9), count: 3))
        XCTAssertEqual(rangeBytes, [0x00, 0x00, 0x57])
        let fullBytes = [UInt8](UnsafeMutableBufferPointer<UInt8>(start: _data.copyAllBytes(), count: _data.count))
        XCTAssertEqual(fullBytes, _bytes)
        XCTAssertEqual(_data.copyBytes(from: 0, to: 4).toArrays(count: 4), [0x52, 0x49, 0x46, 0x46])
        XCTAssertEqual(_data.copyBytes(from: 6, to: 9).toArrays(count: 3), [0x00, 0x00, 0x57])
        XCTAssertEqual(_data.subArray(from: 0, to: 4), [0x52, 0x49, 0x46, 0x46])
        XCTAssertEqual(_data.subArray(from: 6, to: 9),  [0x00, 0x00, 0x57])
    }
    
}
