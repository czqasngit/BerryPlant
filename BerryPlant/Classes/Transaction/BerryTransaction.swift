//
//  BerryTransaction.swift
//  Berry
//
//  Created by legendry on 2018/7/6.
//

import Foundation

public typealias AsycnDoBlock = () -> ()

public struct BerryTransaction {
    var asyncDoBlock: AsycnDoBlock
    var isCancel: Bool = false
    public init(asyncDoBlock block: @escaping AsycnDoBlock) {
        self.asyncDoBlock = block
    }
}


public class BerryTransactionManager {
    
    public static let shared = BerryTransactionManager()
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    private var transations = [BerryTransaction]()
    
    private init(){
        self.listenRunloopIDLE()
    }
    
    private func listenRunloopIDLE(){
        let callback: CFRunLoopObserverCallBack = {(observe: CFRunLoopObserver?, activity: CFRunLoopActivity, context: UnsafeMutableRawPointer?) in
            BerryTransactionManager.shared.execTransaction()
        }
        let observe = CFRunLoopObserverCreate(CFAllocatorGetDefault().takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, true, 0, callback, nil)
        CFRunLoopAddObserver(CFRunLoopGetMain(), observe, CFRunLoopMode.commonModes)
    }
    
    public func submitTransaction(_ transaction: BerryTransaction) {
        pthread_mutex_lock(&mutex)
        self.transations.append(transaction)
        pthread_mutex_unlock(&mutex)
        CFRunLoopWakeUp(CFRunLoopGetMain())
    }
    
    public func execTransaction() {
        guard self.transations.count > 0 else { return }
        pthread_mutex_lock(&mutex)
        self.transations.forEach {
            $0.asyncDoBlock()
        }
        self.transations.removeAll()
        pthread_mutex_unlock(&mutex)
    }
    
    
    
}
