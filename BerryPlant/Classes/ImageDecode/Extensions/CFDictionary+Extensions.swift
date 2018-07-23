//
//  CFDictionary+Extensions.swift
//  Berry
//
//  Created by legendry on 2018/7/20.
//

import Foundation

extension CFDictionary {
    func getValue<T: AnyObject>(forKey key: String) -> T? {
        let key = Unmanaged.passRetained(key as NSString).autorelease().toOpaque()
        guard let opaque = CFDictionaryGetValue(self, key) else { return nil }
        return Unmanaged<T>.fromOpaque(opaque).takeUnretainedValue()
    }
}
