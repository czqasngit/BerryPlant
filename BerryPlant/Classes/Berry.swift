
import UIKit


public protocol UIAsyncable {
    
}

public class Berry<Base> {
    public var base: Base
    init(_ b: Base) {
        self.base = b
    }
    public func submitTransaction(do block: @escaping AsycnDoBlock) {
        let transaction = BerryTransaction(asyncDoBlock: block)
        BerryTransactionManager.shared.submitTransaction(transaction)
    }
}

public extension UIAsyncable {
    public var async: Berry<Self> {
        return Berry(self)
    }
}


//MARK:
extension UIImageView: UIAsyncable { }
extension Berry where Base: UIImageView {
    public func setImage(image: UIImage){
        self.submitTransaction {
            self.base.image = image
        }
    }
}
extension UIButton: UIAsyncable { }
extension Berry where Base: UIButton {
    public func setImage(image: UIImage, state: UIControlState) {
        self.submitTransaction {
            self.base.setImage(image, for: state)
        }
    }
}


