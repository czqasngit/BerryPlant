//
//  UInt32+Exensions.swift
//  Berry
//
//  Created by legendry on 2018/7/17.
//

import Foundation


extension UnsignedInteger {
    
    /// Read UInt32 number from data
    ///
    /// - Parameters:
    ///   - data: data
    ///   - start: start index
    ///   - end: end index
    /// - Returns: UInt32 number
    static func from(of data: Data, from start: Int, to end: Int) -> Self {
        let bytes = data.copyBytes(from: start, to: end)
        let number = Self.from(bytes: bytes)
        bytes.deallocate()
        return number
    }
    
    /// Convert UnsafeMutablePointer<UInt8> to UInt32 number
    ///
    /// - Parameter bytes: bytes pointer
    /// - Returns: UInt32 number
    static func from(bytes: UnsafeMutablePointer<UInt8>) -> Self {
        return bytes.withMemoryRebound(to: Self.self, capacity: MemoryLayout<Self>.size) { $0.pointee }
    }
}

extension UInt32 {
    func bigToHost() -> UInt32 {
        return NSSwapBigIntToHost(self)
    }
}
extension UInt16 {
    func bigToHost() -> UInt16 {
        return NSSwapBigShortToHost(self)
    }
}
