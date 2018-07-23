//
//  Data+Extensions.swift
//  Berry
//
//  Created by legendry on 2018/7/17.
//

import Foundation

extension Data {
    
    /// Copy bytes
    ///
    /// - Parameters:
    ///   - start: start index
    ///   - end: end index
    /// - Returns: return un deallocate bytes
    func copyBytes(from start: Int, to end: Int) -> UnsafeMutablePointer<UInt8> {
        assert(start >= 0 && end >= 0, "start and end must be greater than 0")
        assert(end >= start, "end index must be greater than start")
        let length = end - start
        assert(self.count >= length, "data count must be >= length")
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        bytes.initialize(to: 0)
        if start < self.count && end <= self.count {
            self.copyBytes(to: bytes, from: start..<end)
        } else {
            print("--------------")
        }
        return bytes
    }
    
    /// Copy all bytes
    ///
    /// - Returns: return un deallocate bytes
    func copyAllBytes() -> UnsafeMutablePointer<UInt8> {
        return self.copyBytes(from: 0, to: self.count)
    }
}

extension Data {
    func subArray(from start: Int, to end: Int) -> [UInt8] {
        let bytes = self.copyBytes(from: start, to: end)
        let tmps = bytes.toArrays(count: end - start)
        bytes.deallocate()
        return tmps
    }
}

extension UnsafeMutablePointer {
    func toArrays(count: Int) -> [Pointee] {
        let buffer = UnsafeMutableBufferPointer<Pointee>.init(start: self, count: count)
        let tmps = [Pointee](buffer)
        return tmps
    }
}
