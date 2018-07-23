//
//  BerryWebpDecoder.swift
//  Berry
//
//  Created by legendry on 2018/7/10.
//

import Foundation


public class BerryWebpDecoder: BerryImageProvider {
    
    var bytes: UnsafeMutablePointer<UInt8>
    var count: Int
    var width: Int32 = 0
    var height: Int32 = 0
    
    deinit {
        bytes.deallocate()
    }
    public init(_ data: Data) {
        precondition(BerryImageFormat.getImageFormat(data) == .webp, "The data is not WEBP stream !")
        self.bytes = data.copyAllBytes()
        self.count = data.count
        WebPGetInfo(self.bytes, self.count, &width, &height)
    }
    
    func decode() -> CGImage? {
        var result: CGImage? = nil
        guard let decodeDataPointer = WebPDecodeRGBA(bytes, count, &width, &height) else {
            return nil
        }
        let size = width * height * 4
        let callback: CGDataProviderReleaseDataCallback = { (_, _, _) in }
        if  let dataProvider = CGDataProvider(dataInfo: nil, data: decodeDataPointer, size: numericCast(size), releaseData: callback),
            let bitmap = CGImage(width: numericCast(width),
                                height: numericCast(height),
                                bitsPerComponent: 8,
                                bitsPerPixel: 4 * 8,
                                bytesPerRow: numericCast(width) * 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: [CGBitmapInfo.init(rawValue: 0)],
                                provider: dataProvider,
                                decode: nil,
                                shouldInterpolate: false,
                                intent: CGColorRenderingIntent.defaultIntent) {
                result = bitmap
        }
        
        WebPFree(decodeDataPointer)
        return result
        
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
        return (self.width == 0 || self.height == 0) ? 0 : 1
    }
    public func canvasSize() -> CGSize {
       return CGSize(width: numericCast(self.width), height: numericCast(self.height))
    }
    
}
