//
//  BerryGIFDecoder.swift
//  Berry
//
//  Created by legendry on 2018/7/19.
//

import Foundation

public class BerryGIFDecoder: BerryImageProvider {
    
    var source: CGImageSource?
    var imageData: Data?
    var size = CGSize.zero
    
    public init(_ data: Data) {
        precondition(BerryImageFormat.getImageFormat(data) == .gif, "The data is not GIF stream !")
        self.imageData = data
        guard let data = self.imageData else { return }
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(imageSource) > 0 else { return }
        self.source = imageSource
        let width = UInt32.from(of: data, from: 6, to: 8)
        let height = UInt32.from(of: data, from: 8, to: 10)
        self.size = CGSize(width: numericCast(width), height: numericCast(height))
    }

    
    public func readImage(at index: Int) -> BerryAnimateFrame? {
        let delayTime = frameDuration(at: index)
        guard let _source = self.source,
              let cgImage = CGImageSourceCreateImageAtIndex(_source, index, nil) else {
                return nil
        }
        let frame = BerryAnimateFrame(duration: delayTime, image: cgImage)
        return frame
    }
    
    public func frameDuration(at index: Int) -> Double {
        var delayTime: Double = 0.1
        guard let _source = self.source,
              let properties = CGImageSourceCopyPropertiesAtIndex(_source, index, nil) else { return delayTime }
        if let gifPropertiesPointer = CFDictionaryGetValue(properties, Unmanaged.passRetained("{GIF}" as NSString).autorelease().toOpaque()) {
            let gifProperties = Unmanaged<CFDictionary>.fromOpaque(gifPropertiesPointer).takeUnretainedValue()
            if let delayTimePointer = CFDictionaryGetValue(gifProperties, Unmanaged.passRetained("DelayTime" as NSString).autorelease().toOpaque()) {
                let delayTimeStr = Unmanaged<NSString>.fromOpaque(delayTimePointer).takeUnretainedValue()
                delayTime = Double(delayTimeStr.floatValue)
            }
        }
        return delayTime
    }
    
    public func numberOfFrames() -> Int {
        guard let _source = self.source else { return 0}
        return CGImageSourceGetCount(_source)
    }
    
    public func canvasSize() -> CGSize {
        return self.size
    }
    
    
}
