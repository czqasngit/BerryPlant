
import UIKit


public protocol UIAsyncable {
    var task: BerryTransaction? { set get}
}
let kUIImageViewTask = UnsafeMutablePointer<Int>.allocate(capacity: 0)
extension UIAsyncable where Self: NSObjectProtocol {
    public var task: BerryTransaction? {
        set {
            objc_setAssociatedObject(self, kUIImageViewTask, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, kUIImageViewTask) as? BerryTransaction
        }
    }
}

public class Berry<Base: UIAsyncable> {
    public var base: Base
    init(_ b: Base) {
        self.base = b
    }
    public func submitTransaction(do block: @escaping AsycnDoBlock) -> BerryTransaction {
        let transaction = BerryTransaction(asyncDoBlock: block)
        BerryTransactionManager.shared.submitTransaction(transaction)
        return transaction
    }
    /// 取消当次执行的图片加载
    public func cancel() {
        DispatchQueue.main.async {
            self.base.task?.isCancel = true
        }
    }
}

public extension UIAsyncable where Self : UIAsyncable {
    public var async: Berry<Self> {
        return Berry(self)
    }
}

//MARK:
extension UIImageView: UIAsyncable {
    
}
extension Berry where Base: UIImageView {
    public func setImage(image: UIImage?){
        if let _image = image {
            let task = self.submitTransaction {
                defer {
                    /// 任务完成, 重围任务
                    self.base.task = nil
                }
                guard !(self.base.task?.isCancel ?? false) else { return }
                self.base.image = _image
            }
            self.base.task = task
        } else {
            DispatchQueue.main.async {
                self.base.image = nil
                self.base.task = nil
            }
        }
    }
}
extension UIButton: UIAsyncable { }
extension Berry where Base: UIButton {
    public func setImage(image: UIImage, state: UIControlState) {
        let task = self.submitTransaction {
            defer {
                /// 任务完成, 重围任务
                self.base.task = nil
            }
            guard !(self.base.task?.isCancel ?? false) else { return }
            self.base.setImage(image, for: state)
        }
        self.base.task = task
    }
}


