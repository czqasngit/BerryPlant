//
//  BerryAPNGDecoder.swift
//  Berry

//
//  Created by legendry on 2018/7/12.
//

import Foundation

import zlib

/*
 APNG_DISPOSE_OP_NONE: no disposal is done on this frame before rendering the next; the contents of the output buffer are left as is.
 APNG_DISPOSE_OP_BACKGROUND: the frame's region of the output buffer is to be cleared to fully transparent black before rendering the next frame.
 APNG_DISPOSE_OP_PREVIOUS: the frame's region of the output buffer is to be reverted to the previous contents before rendering the next frame.
 */
enum APNG_DISPOSE_OP: UInt8 {
    ///nothing to do before render next frame
    case none = 0
    ///clear region before render next frame
    case background = 1
    ///restore content with previous before render next frame
    case previous = 2
}
/*
 If `blend_op` is APNG_BLEND_OP_SOURCE all color components of the frame, including alpha, overwrite the current contents of the frame's output buffer region. If `blend_op` is APNG_BLEND_OP_OVER the frame should be composited onto the output buffer based on its alpha, using a simple OVER operation as described in the "Alpha Channel Processing" section of the PNG specification [PNG-1.2]. Note that the second variation of the sample code is applicable.
 */
enum APNG_BLEND_OP: UInt8 {
    case source = 0
    case over = 1
}
/**
 APNG Decoder
 The Animated Portable Network Graphics (APNG) file format is an extension to the Portable Network Graphics (PNG) specification. It allows for animated PNG files that work similarly to animated GIF files, while supporting 24-bit images and 8-bit transparency not available for GIFs. It also retains backward compatibility with non-animated PNG files.
 
 The first frame of an APNG file is stored as a normal PNG stream, so most standard PNG decoders are able to display the first frame of an APNG file. The frame speed data and extra animation frames are stored in extra chunks (as provided for by the original PNG specification).
 
 APNG competes with Multiple-image Network Graphics (MNG), a comprehensive format for bitmapped animations created by the same team as PNG. APNG's advantage is the smaller library size and compatibility with older PNG implementations.
 
 */
public class BerryAPNGDecoder: BerryImageProvider {
    
    /// File data
    var data: Data
    /// All chunks
    var chunks = [BerryAPNGChunk]()
    /// All frames
    var frames = [BerryAPNGFrame]()
    /// APNG Signature
    var signature: BerryAPNGSignature
    /// APNG Common data
    var common: BerryAPNGCommon
    /// actl
    var actl: BerryAPNGACTL!
    var ihdr: BerryAPNGIHDR!
    /// Off-screen context
    var context: CGContext!
    
    public init(_ data: Data) {
        precondition(BerryImageFormat.getImageFormat(data) == .apng, "The data is not APNG stream !")
        self.data = data
        self.signature = BerryAPNGSignature()
        self.common = BerryAPNGCommon()
        self.parseChunks()
        if self.ihdr != nil {
            context = CGContext.init(data: nil, width: Int(self.ihdr.width), height: Int( self.ihdr.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue )
        }
    }
    
    func parseChunks() {
        var offset = 8
        var stop = false
        var beforeIDATA = true
        var firstFrameCover = false
        var fcTLNum = 0
        while !stop {
            let chunkDataLength = UInt32.from(of: data, from: offset, to: offset + 4).bigToHost()
            let chunkLength = 4 + 4 + chunkDataLength + 4
            let chunkType = String.from(source: data, from: offset + 4, to: offset + 8)
            let chunk = BerryAPNGChunk(start: offset, end: offset + numericCast(chunkLength), length: chunkLength, type: chunkType)
            if chunk.type == "" {
                break
            }
            self.chunks.append(chunk)
            if chunk.type == "IEND" {
                stop = true
            }
            offset += numericCast(chunkLength)
            if chunk.type == "IDAT" {
                beforeIDATA = false
                if (fcTLNum != 0) {
                    firstFrameCover = true
                }
            }
            if chunk.type != "fcTL" && chunk.type != "fdAT" && chunk.type != "IDAT", chunk.type != "acTL" {
                if beforeIDATA { common.appendFirstHalf(chunk) }
                else { common.appendSecondHalf(chunk) }
            }
            
            if chunk.type == "fcTL" {
                fcTLNum += 1
            }
            
            if chunk.type == "acTL" {
                self.actl = BerryAPNGACTL(with: data.subdata(in: (chunk.start + 8)..<chunk.end - 4))
            }
            if chunk.type == "IHDR" {
                self.ihdr = BerryAPNGIHDR(with: data.subdata(in: (chunk.start + 8)..<chunk.end - 4))
            }
            
        }
        
        var frameIndex = -1
        //fdAT and IDat is allowed multiple.
        for i in 0..<chunks.count {
            switch chunks[i].type {
            case "fcTL":
                frameIndex += 1
                let frame = BerryAPNGFrame(fctlData: self.data.subdata(in: (chunks[i].start + 8)..<chunks[i].end))
                frames.append(frame)
                break
            case "fdAT":
                let frame = frames[frameIndex]
                frame.appendIDAT(chunks[i])
                frame.chunkNum += 1
                break
            case "IDAT":
                let frame = frames[frameIndex]
                if (frame.apngFirstFrame == 0) {
                    frame.apngFirstFrame = i
                }
                if (firstFrameCover) { //If no fcTL before, not include this IDAT.
                    frame.appendIDAT(chunks[i])
                    frame.chunkNum += 1
                }
                break
            default:
                break
            }
        }
    }

    public func decode(at index: Int) -> CGImage? {
        guard frames.count > index else { return nil }
        let frame = frames[index]
        let data = common.getPNGData(with: frame, fileData: self.data)
        guard let provider = CGDataProvider(data: data as CFData),
              let source = CGImageSourceCreateWithDataProvider(provider, nil),
              let originCGImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        var image: CGImage? = nil
        let offsetY = self.ihdr.height - frame.fctl.y_offset - frame.fctl.height
        let fullRect = CGRect(x: 0, y: 0, width: CGFloat(self.ihdr.width), height: CGFloat(self.ihdr.height))
        let drawRect = CGRect(x: CGFloat(frame.fctl.x_offset), y: CGFloat(offsetY), width: CGFloat(frame.fctl.width), height: CGFloat(frame.fctl.height))
        if frame.fctl.dispose_op == APNG_DISPOSE_OP.none.rawValue {
            if(frame.fctl.blend_op == APNG_BLEND_OP.source.rawValue) {
                context.clear(drawRect)
            }
            context.draw(originCGImage, in: drawRect)
            image = context.makeImage()
        } else if frame.fctl.dispose_op == APNG_DISPOSE_OP.background.rawValue {
            if(frame.fctl.blend_op == APNG_BLEND_OP.source.rawValue) {
                context.clear(drawRect)
            }
            context.draw(originCGImage, in: drawRect)
            image = context.makeImage()
            context.clear(drawRect)
        } else {
            let previousCGImage = context.makeImage()
            if(frame.fctl.blend_op == APNG_BLEND_OP.source.rawValue) {
                context.clear(drawRect)
            }
            context.draw(originCGImage, in: drawRect)
            image = context.makeImage()
            if let previousCGImage = previousCGImage {
                context.clear(fullRect)
                context.draw(previousCGImage, in: fullRect)
            }
        }
        return image
    }
    
    
    public func readImage(at index: Int) -> BerryAnimateFrame? {
        guard let cgImage = self.decode(at: index) else { return nil }
        let frame = frames[index]
        let animateFrame = BerryAnimateFrame(duration: Double(frame.fctl.delay_num) / Double(frame.fctl.delay_den) ,
                                             image: cgImage)
        return animateFrame
    }
    public func frameDuration(at index: Int) -> Double {
        let frame = frames[index]
        return Double(frame.fctl.delay_num) / Double(frame.fctl.delay_den)
    }
    
    public func numberOfFrames() -> Int {
        guard self.actl != nil else { return 0 }
        return numericCast(self.actl.num_frames)
    }
    public func canvasSize() -> CGSize {
        guard self.ihdr != nil else { return .zero }
        return CGSize(width: numericCast(self.ihdr.width), height: numericCast(self.ihdr.height))
    }
}





