//
//  SystemDecoder.swift
//  Berry
//
//  Created by legendry on 2018/7/12.
//

import Foundation

public class BerryDefaultDecoder: BerryImageProvider {
    
    var imageSource: CGImageSource?
    var width: Int = 0
    var height: Int = 0
    
    public init(_ data: Data) {
        imageSource = CGImageSourceCreateWithData(data as CFData, nil)
        if let properties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) {
            if let wh: NSNumber = properties.getValue(forKey: "PixelWidth") {
                self.width = wh.intValue
            }
            if let ph: NSNumber = properties.getValue(forKey: "PixelHeight") {
                self.height = ph.intValue
            }
        }
    }
    
    func decode() -> CGImage? {
        guard let source = self.imageSource,
              numberOfFrames() > 0 else { return nil }
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        return cgImage
    }
    
    public func readImage(at index: Int) -> BerryAnimateFrame? {
        guard let cgImage = self.decode() else { return nil }
        let frame = BerryAnimateFrame(duration: 0, image: cgImage)
        return frame
    }
    
    public func frameDuration(at index: Int) -> Double {
        return 0
    }
    
    public func numberOfFrames() -> Int {
        guard let source = self.imageSource else { return 0 }
        return CGImageSourceGetCount(source)
    }
    
    public func canvasSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
}
