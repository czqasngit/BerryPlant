//
//  BerryWebpDecoder.swift
//  Berry
//
//  Created by legendry on 2018/7/10.
//

import Foundation

public protocol WebPDecoderProtocol {
    func getWebPInfo(_ data: Data) -> (width: Int32, height: Int32)
    func decodeWebP(_ data: Data, width: inout Int32, height: inout Int32) -> UnsafeMutablePointer<UInt8>?
    func decodeComplete(_ context: UnsafeMutablePointer<UInt8>)
}

public class WebPDecoderImplManager {
    static public let shared = WebPDecoderImplManager()
    internal var webp: WebPDecoderProtocol? = nil
    public func registerWebPDecoderImpl(_ webp: WebPDecoderProtocol) {
        self.webp = webp
    }
    private init() {
        
    }
}

public class BerryWebpDecoder: BerryImageProvider {
    
    var data: Data
    var count: Int
    var width: Int32 = 0
    var height: Int32 = 0
    var webp: WebPDecoderProtocol

    public init(_ data: Data, webp: WebPDecoderProtocol) {
        self.webp = webp
        precondition(BerryImageFormat.getImageFormat(data) == .webp, "The data is not WEBP stream !")
        self.data = data
        self.count = data.count
        let result = self.webp.getWebPInfo(data)
        self.width = result.width
        self.height = result.height
    }
    
    func decode() -> CGImage? {
        var result: CGImage? = nil
        guard let decodeDataPointer = self.webp.decodeWebP(self.data, width: &self.width, height: &self.height) else {
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
                                bitmapInfo: [CGBitmapInfo.init(rawValue: 0), CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)],
                                provider: dataProvider,
                                decode: nil,
                                shouldInterpolate: false,
                                intent: CGColorRenderingIntent.defaultIntent) {
                result = bitmap
        }
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
