//
//  BerryAPNGStructure.swift
//  Berry
//
//  Created by legendry on 2018/7/20.
//

import Foundation
import zlib

//MARK: BerryAPNGIHDR
/**
    The IHDR chunk shall be the first chunk in the PNG datastream. It contains:
 
    Width                           4 bytes
    Height                          4 bytes
    Bit depth                       1 byte
    Colour type                     1 byte
    Compression method              1 byte
    Filter method                   1 byte
    Interlace method                1 byte

 */
struct BerryAPNGIHDR {
    var width: UInt32
    var height: UInt32
    var bitDepth: UInt8
    var colourType: UInt8
    var compressionMethod: UInt8
    var filterMethod: UInt8
    var interlaceMethod: UInt8
    init(with data: Data) {
        self.width = UInt32.from(of: data, from: 0, to: 4).bigToHost()
        self.height = UInt32.from(of: data, from: 4, to: 8).bigToHost()
        self.bitDepth = UInt8.from(of: data, from: 8, to: 9)
        self.colourType = UInt8.from(of: data, from: 9, to: 10)
        self.compressionMethod = UInt8.from(of: data, from: 10, to: 11)
        self.filterMethod = UInt8.from(of: data, from: 11, to: 12)
        self.interlaceMethod = UInt8.from(of: data, from: 12, to: 13)
    }
}

//MARK: BerryAPNGSignature
/**
 The first eight bytes of a PNG datastream always contain the following (decimal) values:
 0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A 0x00
 */
struct BerryAPNGSignature {
    /// Header bytes
    var data: Data
    /// Signature name
    var name: String
    init() {
        self.data = Data(bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        self.name = ".PNG"
    }
}

//MARK: BerryAPNGACTL
/**
    The `acTL` chunk is an ancillary chunk as defined in the PNG Specification. It must appear before the first `IDAT` chunk within a valid PNG stream.
    num_frames     (unsigned int)    Number of frames
    num_plays      (unsigned int)    Number of times to loop this APNG.  0 indicates infinite looping.
 */
struct BerryAPNGACTL {
    var num_frames: UInt32
    var num_plays: UInt32
    init(with data: Data) {
        self.num_frames = UInt32.from(of: data, from: 0, to: 4).bigToHost()
        self.num_plays = UInt32.from(of: data, from: 4, to: 8).bigToHost()
    }
}

//MARK: BerryAPNGFCTL
/**
    The `fcTL` chunk is an ancillary chunk as defined in the PNG Specification. It must appear before the `IDAT` or `fdAT` chunks of the frame to which it applies, specifically:
 */
struct BerryAPNGFCTL {
    var sequence_number: UInt32
    var width: UInt32
    var height: UInt32
    var x_offset: UInt32
    var y_offset: UInt32
    var delay_num: UInt16
    var delay_den: UInt16
    var dispose_op: UInt8
    var blend_op: UInt8
    init(with data: Data) {
        self.sequence_number = UInt32.from(of: data, from: 0, to: 4).bigToHost()
        /*
         The frame must be rendered within the region defined by `x_offset`, `y_offset`, `width`, and `height`. The offsets must be non-negative, the dimensions must be positive, and the region may not fall outside of the default image.
         */
        self.width = UInt32.from(of: data, from: 4, to: 8).bigToHost()
        self.height = UInt32.from(of: data, from: 8, to: 12).bigToHost()
        self.x_offset = UInt32.from(of: data, from: 12, to: 16).bigToHost()
        self.y_offset = UInt32.from(of: data, from: 16, to: 20).bigToHost()
        /*
         The `delay_num` and `delay_den` parameters together specify a fraction indicating the time to display the current frame, in seconds. If the denominator is 0, it is to be treated as if it were 100 (that is, `delay_num` then specifies 1/100ths of a second). If the the value of the numerator is 0 the decoder should render the next frame as quickly as possible, though viewers may impose a reasonable lower bound.
         
         Frame timings should be independent of the time required for decoding and display of each frame, so that animations will run at the same rate regardless of the performance of the decoder implementation.
         */
        self.delay_num = UInt16.from(of: data, from: 20, to: 22).bigToHost()
        self.delay_den = UInt16.from(of: data, from: 22, to: 24).bigToHost()
        if self.delay_den == 0 { self.delay_den = 100 }
        
        self.dispose_op =  UInt8.from(of: data, from: 24, to: 25)
        self.blend_op = UInt8.from(of: data, from: 25, to: 26)
    }
}

//MARK: BerryAPNGChunk
/**
 Structure of a single PNG chunk
 
 PNG Signature (8 special bytes), followed by a series of chunks.
 A chunk consists of four parts:
 ---------------------------------------------------------------------------
 
 Length (4 bytes),
 Chunk type (4 bytes),
 Chunk data (length bytes),
 CRC (Cyclic Redundancy Code / Checksum, 4 bytes).
 
 ---------------------------------------------------------------------------
 */
struct BerryAPNGChunk {
    /// Chunk data length
    var length: UInt32
    /// Chunk type
    var type: String
    /// Chunk data: start index of apng file data
    var start: Int
    /// Chunk data: end index of apng file data
    var end: Int
    init(start: Int, end: Int, length: UInt32, type: String) {
        self.start = start
        self.end = end
        self.length = length
        self.type = type
    }
}

//MARK: BerryAPNGCommon
/**
    Common chunk to make full png data
 */
struct BerryAPNGCommon {
    var signature = BerryAPNGSignature()
    var chunks1 = [BerryAPNGChunk]()
    var chunks2 = [BerryAPNGChunk]()
    mutating func appendFirstHalf(_ chunk: BerryAPNGChunk) {
        chunks1.append(chunk)
    }
    mutating func appendSecondHalf(_ chunk: BerryAPNGChunk) {
        chunks2.append(chunk)
    }
    
    func meger(with frame: BerryAPNGFrame, from chunks: [BerryAPNGChunk], from fileData: Data, to data: inout Data) {
        for i in 0..<chunks.count {
            if chunks[i].type == "IHDR" {
                let IHDRChunk = chunks[i]
                var IHDR_DATA = Data()
                IHDR_DATA.append(fileData.subdata(in: IHDRChunk.start..<(IHDRChunk.start + 8)))
                var width = NSSwapHostIntToBig(frame.fctl.width)
                var height = NSSwapHostIntToBig(frame.fctl.height)
                withUnsafeBytes(of: &width) { IHDR_DATA.append(contentsOf: [UInt8]($0)) }
                withUnsafeBytes(of: &height) { IHDR_DATA.append(contentsOf:  [UInt8]($0)) }
                IHDR_DATA.append(fileData.subdata(in: (IHDRChunk.start + 8 + 8)..<(IHDRChunk.start + 8 + 8 + 5)))
                let bytes = IHDR_DATA.copyAllBytes()
                let crcValue = crc32(0, bytes + 4, numericCast(IHDR_DATA.count) - 4)
                bytes.deallocate()
                var crc = NSSwapHostIntToBig(numericCast(crcValue))
                withUnsafeBytes(of: &crc) { IHDR_DATA.append(contentsOf: [UInt8]($0)) }
                data.append(IHDR_DATA)
            } else {
                data.append(fileData.subdata(in: chunks[i].start..<chunks[i].end))
            }
        }
    }
    
    func appendIDAT(with frame: BerryAPNGFrame, from fileData: Data, to data: inout Data) {
        for i in 0..<frame.chunkNum {
            let idat = frame.idat[i]
            let fdatData = fileData.subdata(in: idat.start..<idat.end)
            if idat.type == "IDAT" {
                data.append(fdatData)
            } else {
                let dataLength = idat.length - 16 //IDAT length
                var resultData = Data()
                var dataLengthLittleSequence = NSSwapHostIntToBig(dataLength)
                withUnsafeBytes(of: &dataLengthLittleSequence) {
                    let buffer = [UInt8]($0)
                    resultData.append(contentsOf: buffer)
                }
                let idat = ["I", "D", "A", "T"]
                resultData.append(contentsOf: idat.map { UInt8.init(ascii: Unicode.Scalar.init($0)! ) })
                //chunk data
                let chunkDataStart = 12
                let chunkDataEnd: Int = numericCast(12 + dataLength)
                resultData.append(fdatData.subdata(in: chunkDataStart..<chunkDataEnd))
                let bytes = resultData.copyAllBytes()
                let crcValue = crc32(0, bytes + 4, numericCast(resultData.count) - 4)
                bytes.deallocate()
                var crc = NSSwapHostIntToBig(numericCast(crcValue))
                withUnsafeBytes(of: &crc) {
                    let buffer = [UInt8]($0)
                    resultData.append(contentsOf: buffer)
                }
                data.append(resultData)
            }
        }
    }
    /**
     Create single png image data
     --
     |PNG Signature|
     --
     |Common Chunks(IHDR,PLTE,tEXt...,before first fcTL chunk)|
     --
     |IDAT(fdAT -> IDAT)|
     --
     |Common Chunks(IHDR,PLTE,tEXt...,after last IDAT/fdAT chunk)|
     --
     |IEND|
     */
    func getPNGData(with frame: BerryAPNGFrame, fileData data: Data) -> Data {
        var pngData = Data()
        pngData.append(signature.data)
        meger(with: frame, from: chunks1, from: data, to: &pngData)
        appendIDAT(with: frame, from: data, to: &pngData)
        meger(with: frame, from: chunks2, from: data, to: &pngData)
        return pngData
    }
}

//MARK: BerryAPNGFrame
struct BerryAPNGFrame {
    var fctl: BerryAPNGFCTL
    var idat: BerryAPNGChunk
    init(idat: BerryAPNGChunk, fctlData: Data) {
        self.idat = idat
        self.fctl = BerryAPNGFCTL(with: fctlData)
    }
    var isIDAT: Bool {
        return self.idat.type == "IDAT"
    }
}


