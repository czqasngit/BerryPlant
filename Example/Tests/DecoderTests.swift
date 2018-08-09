//
//  DecoderTests.swift
//  BerryPlant_Example
//
//  Created by legendry on 2018/8/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import BerryPlant
import CoreFoundation

class DecoderTests: XCTestCase {
    
    func testAPNGDecoder() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dance", ofType: "apng")!))
        let apngDecoder = FindImageDecoder(with: data)
        XCTAssertNotNil(apngDecoder)
        XCTAssertEqual(49, apngDecoder.numberOfFrames())
        XCTAssertEqual(CGSize(width: 360, height: 240), apngDecoder.canvasSize())
        XCTAssertEqual(Double(0.1), apngDecoder.frameDuration(at: 0))
        XCTAssertNotNil(apngDecoder.readImage(at: 0))
    }
    
    func testWebPDecoder() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "j", ofType: "webp")!))
        let apngDecoder = FindImageDecoder(with: data)
        XCTAssertNotNil(apngDecoder)
        XCTAssertEqual(1, apngDecoder.numberOfFrames())
        XCTAssertEqual(CGSize(width: 521.0, height: 438.0), apngDecoder.canvasSize())
        XCTAssertEqual(Double(0), apngDecoder.frameDuration(at: 0))
        XCTAssertNotNil(apngDecoder.readImage(at: 0))
    }
    
    func testGIFDecoder() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dance", ofType: "gif")!))
        let apngDecoder = FindImageDecoder(with: data)
        XCTAssertNotNil(apngDecoder)
        XCTAssertEqual(49, apngDecoder.numberOfFrames())
        XCTAssertEqual(CGSize(width: 360, height: 240), apngDecoder.canvasSize())
        XCTAssertEqual(Double(0.10000000149011612), apngDecoder.frameDuration(at: 0))
        XCTAssertNotNil(apngDecoder.readImage(at: 0))
    }
    
    func testJPGDecoder() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "jpg")!))
        let apngDecoder = FindImageDecoder(with: data)
        XCTAssertNotNil(apngDecoder)
        XCTAssertEqual(1, apngDecoder.numberOfFrames())
        XCTAssertEqual(CGSize(width: 1413.0, height: 1080.0), apngDecoder.canvasSize())
        XCTAssertEqual(Double(0), apngDecoder.frameDuration(at: 0))
        XCTAssertNotNil(apngDecoder.readImage(at: 0))
    }
    
    func testPNGDecoder() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "j", ofType: "png")!))
        let apngDecoder = FindImageDecoder(with: data)
        XCTAssertNotNil(apngDecoder)
        XCTAssertEqual(1, apngDecoder.numberOfFrames())
        XCTAssertEqual(CGSize(width: 521.0, height: 438.0), apngDecoder.canvasSize())
        XCTAssertEqual(Double(0), apngDecoder.frameDuration(at: 0))
        XCTAssertNotNil(apngDecoder.readImage(at: 0))
    }
}
