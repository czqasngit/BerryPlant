
import UIKit


public protocol UIAsyncable {
    
}

public class Berry<Base> {
    var base: Base
    init(_ b: Base) {
        self.base = b
    }
    func submitTransaction(do block: @escaping AsycnDoBlock) {
        let transaction = BerryTransaction(asyncDoBlock: block)
        BerryTransactionManager.shared.submitTransaction(transaction)
    }
}

public extension UIAsyncable {
    public var async: Berry<Self> {
        return Berry(self)
    }
}



