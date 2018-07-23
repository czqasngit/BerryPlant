//
//  String+Extensions.swift
//  Berry
//
//  Created by legendry on 2018/7/17.
//

import Foundation

extension String {
    
    
    /// Read string from data  
    ///
    /// - Parameters:
    ///   - data: data
    ///   - start: start index
    ///   - end: end index
    /// - Returns: String
    static func from(source data: Data, from start: Int, to end: Int) -> String {
        let bytes = data.copyBytes(from: start, to: end)
        let string = String(cString: bytes)
        bytes.deallocate()
        return string
    }
    
}
