//
//  BerryImageFormatTests.swift
//  BerryPlant_Example
//
//  Created by legendry on 2018/8/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import BerryPlant

class BerryImageFormatTests: XCTestCase {
    
    func testBerryImageFormat(){
        let dataJPG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "jpg")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataJPG), BerryImageFormat.other)
        let dataGIF = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "apng", ofType: "gif")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataGIF), BerryImageFormat.gif)
        let dataGIF2 = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "basketball", ofType: "gif")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataGIF2), BerryImageFormat.gif)
        let dataAPNG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dance", ofType: "apng")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataAPNG), BerryImageFormat.apng)
        let dataPNG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "j", ofType: "png")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataPNG), BerryImageFormat.png)
        let dataEmpty = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "mm", ofType: "apng")!))
        XCTAssertEqual(BerryImageFormat.getImageFormat(dataEmpty), BerryImageFormat.other)
    }
    
    func testBerryImageFormatDecoder() {
        let dataJPG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "jpg")!))
        XCTAssertTrue(FindImageDecoder(with: dataJPG) is BerryDefaultDecoder)
        let dataGIF = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "apng", ofType: "gif")!))
        XCTAssertTrue(FindImageDecoder(with: dataGIF) is BerryGIFDecoder)
        let dataGIF2 = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "basketball", ofType: "gif")!))
        XCTAssertTrue(FindImageDecoder(with: dataGIF2) is BerryGIFDecoder)
        let dataAPNG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dance", ofType: "apng")!))
        XCTAssertTrue(FindImageDecoder(with: dataAPNG) is BerryAPNGDecoder)
        let dataPNG = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "j", ofType: "png")!))
        XCTAssertTrue(FindImageDecoder(with: dataPNG) is BerryDefaultDecoder)
        let dataEmpty = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "mm", ofType: "apng")!))
        XCTAssertTrue(FindImageDecoder(with: dataEmpty) is BerryDefaultDecoder)
    }
    
}
