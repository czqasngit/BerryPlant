//
//  BerryImageFormat.swift
//  Berry
//
//  Created by legendry on 2018/7/19.
//

import Foundation


public enum BerryImageFormat {
    //BerryAPNGDecoder
    case apng
    //BerryDefaultDecoder
    case png
    //BerryWebpDecoder
    case webp
    //BerryGifDecoder
    case gif
    //BerryDefaultDecoder
    case other
    
    static public func getImageFormat(_ data: Data) -> BerryImageFormat {
        let header = data.subArray(from: 0, to: 4)
        var format: BerryImageFormat = .other
        if header == BerryImageFormat._GIF_Header {
            format = .gif
        } else if header == BerryImageFormat._PNG_Header {
            if data.count > 41 && data.subArray(from: 37, to: 41) == [0x61, 0x63, 0x54, 0x4C]{
                format = .apng
            } else {
                format = .png
            }
        } else {
            if data.subArray(from: 8, to: 12) == BerryImageFormat._WEBP_Header {
                format = .webp
            }
        }
        return format
    }
    
    static var _GIF_Header: [UInt8] {
        return [0x47, 0x49, 0x46, 0x38]
    }
    static var _PNG_Header: [UInt8] {
        return [0x89, 0x50, 0x4E, 0x47]
    }
    static var _WEBP_Header: [UInt8] {
        return [0x57, 0x45, 0x42, 0x50]
    }
    
}

public func FindImageDecoder(with data: Data, webp: BerryWebpDecoderProtocol? = nil) -> BerryImageProvider {
    let imageProvider: BerryImageProvider!
    let format = BerryImageFormat.getImageFormat(data)
    switch format {
    case .apng:
        imageProvider = BerryAPNGDecoder(data)
    case .gif:
        imageProvider = BerryGIFDecoder(data)
    case .webp:
        precondition(webp != nil)
        imageProvider = BerryWebpDecoder(data, webp: webp!)
    default:
        imageProvider = BerryDefaultDecoder(data)
    }
    return imageProvider
}

