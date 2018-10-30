//
//  BerryWebpDecoder.swift
//  Berry
//
//  Created by legendry on 2018/7/10.
//

import Foundation

public protocol BerryWebpDecoderProtocol {
    func getInfo(_ data: Data) -> (width: Int32, height: Int32)
    func decode(_ data: Data, width: inout Int32, height: inout Int32) -> UnsafeMutablePointer<UInt8>?
    func decodeComplete(_ context: UnsafeMutablePointer<UInt8>)
}

public class BerryWebpDecoder: BerryImageProvider {
    
//    var bytes: UnsafeMutablePointer<UInt8>
    var data: Data
    var count: Int
    var width: Int32 = 0
    var height: Int32 = 0
    var webp: BerryWebpDecoderProtocol
//    deinit {
//        bytes.deallocate()
//    }
    public init(_ data: Data, webp: BerryWebpDecoderProtocol) {
        self.webp = webp
        precondition(BerryImageFormat.getImageFormat(data) == .webp, "The data is not WEBP stream !")
//        self.bytes = data.copyAllBytes()
        self.data = data
        self.count = data.count
//        WebPGetInfo(self.bytes, self.count, &width, &height)
        let result = self.webp.getInfo(data)
        self.width = result.width
        self.height = result.height
    }
    
    func decode() -> CGImage? {
        var result: CGImage? = nil
        guard let decodeDataPointer = self.webp.decode(self.data, width: &self.width, height: &self.height)/*WebPDecodeRGBA(bytes, count, &width, &height)*/ else {
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
        
//        WebPFree(decodeDataPointer)
        self.webp.decodeComplete(decodeDataPointer)
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
