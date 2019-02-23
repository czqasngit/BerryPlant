//
//  AnimateImage.swift
//  Berry
//
//  Created by legendry on 2018/7/17.
//

import Foundation


//MARK: BerryAnimateFrame
public struct BerryAnimateFrame {
    /// duration(s)
    public var duration: Double
    /// image data
    public var image: CGImage
}

//MARK: BerryAnimateImage
open class BerryAnimateImageView: UIImageView {
    
    public enum Policy {
        case noCache
        case cacheAfterShow
        case cacheAllBeforeShow
    }
    
    var imageProvider: BerryImageProvider?
    var currentIndex: Int = 0
    var currentDelay: Double = 0
    var policy: Policy
    var numberOfFrames: Int
    var cavansSize: CGSize
    var link: CADisplayLink?
    var cache = [Int: CGImage]()
    var loopCount = 0
//    var _animating = false
    
    deinit {
        self.cache.removeAll()
        self.imageProvider = nil
        if let link = self.link {
            link.invalidate()
        }
        self.link = nil
        print(#file,#function)
    }
    public init(with imageProvider: BerryImageProvider?, frame: CGRect, cache policy: Policy = .noCache) {
        self.imageProvider = imageProvider
        self.numberOfFrames = imageProvider?.numberOfFrames() ?? 0
        self.cavansSize = imageProvider?.canvasSize() ?? .zero
        self.policy = policy
        super.init(frame: frame)
        self.showNextImage()
    }
    public convenience init(_ data: Data? = nil, frame: CGRect, cache policy: Policy = .noCache) {
        if let data = data {
            let decoder = FindImageDecoder(with: data)
            self.init(with: decoder, frame: frame, cache: policy)
        } else {
            self.init(with: nil, frame: frame, cache: policy)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @available(iOS, deprecated: 8.0, message: "use _isAnimating instead of")
//    open override var isAnimating: Bool  {
//        return self._isAnimating
//    }
//    public var _isAnimating: Bool  {
//        return self._animating
//    }
    func showNextImage() {
        guard let privider = self.imageProvider else { return }
        if let cacheCGImage = self.cache[self.currentIndex] {
            self.async.setImage(image: UIImage(cgImage: cacheCGImage))
        } else {
            if let frame = privider.readImage(at: currentIndex) {
                if self.policy == .cacheAfterShow {
                    self.cache[currentIndex] = frame.image
                }
                self.async.setImage(image: UIImage(cgImage: frame.image))
            }
        }
        self.currentIndex += 1
        if self.animationRepeatCount == 0 || self.animationRepeatCount > self.loopCount{
            if currentIndex >= self.numberOfFrames {
                self.currentIndex = 0
                self.loopCount += 1
            }
        } else {
            self.stopAnimating()
        }
    }
   
    @objc func render(){
        guard let link = self.link else { return }
        let linkDuration = link.duration
        self.currentDelay -= linkDuration
        if self.currentDelay <= 0 {
            self.showNextImage()
            if let delay = imageProvider?.frameDuration(at: self.currentIndex) {
                self.currentDelay = (self.currentDelay + delay)
            }
        }
    }
    open func set(animated data: Data) {
        self.cache.removeAll()
        self.imageProvider = FindImageDecoder(with: data)
        self.numberOfFrames = imageProvider?.numberOfFrames() ?? 0
        self.cavansSize = imageProvider?.canvasSize() ?? .zero
        self.showNextImage()
    }
    open override func stopAnimating() {
        self.link?.invalidate()
        self.link = nil
//        _animating = false
        
    }
    open override func startAnimating() {
        guard self.imageProvider != nil else { return }
        guard self.numberOfFrames > 1 else { return }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if self.policy == .cacheAllBeforeShow {
                for i in 0..<self.numberOfFrames {
                    if let frame = self.imageProvider?.readImage(at: i) {
                       self.cache[i] = frame.image
                    }
                }
            }
            let proxy = BerryProxy(target: self)
            self.link = CADisplayLink(target: proxy, selector: #selector(BerryAnimateImageView.render))
            self.link!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
    }
}

//MARK: 
extension Berry where Base == BerryAnimateImageView {
    func setImage(image: UIImage) {
        self.submitTransaction {
            self.base.image = image
        }
    }
}


