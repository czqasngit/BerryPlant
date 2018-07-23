//
//  BerryImageProvider.swift
//  Berry
//
//  Created by legendry on 2018/7/20.
//

import Foundation

public protocol BerryImageProvider {
    func readImage(at index: Int) -> BerryAnimateFrame?
    func frameDuration(at index: Int) -> Double
    func numberOfFrames() -> Int
    func canvasSize() -> CGSize
}
