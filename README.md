# BerryPlant

[![CI Status](https://img.shields.io/travis/czqasngit/BerryPlant.svg?style=flat)](https://travis-ci.org/czqasngit/BerryPlant)&nbsp;
[![Version](https://img.shields.io/cocoapods/v/BerryPlant.svg?style=flat)](https://cocoapods.org/pods/BerryPlant)
[![License](https://img.shields.io/cocoapods/l/BerryPlant.svg?style=flat)](https://cocoapods.org/pods/BerryPlant)
[![Platform](https://img.shields.io/cocoapods/p/BerryPlant.svg?style=flat)](https://cocoapods.org/pods/BerryPlant)

A swift image kit for iOS to display/decode WebP,APNG,GIF,PNG,JPG and more.
基于Swift的解码与显示WEBP, APNG, PNG, GIF, JPG 等更多格式图片的工具包

Decode image on async thread and render when runloop idle.
子线程解码图片并且在Runloop空闲的时候显示图片

![apng](http://pba6dsu9x.bkt.clouddn.com/apng.gif)


## Futures
Decode and display WEBP,APNG,GIF,PNG and so on
解码WEBP, APNG, GIF, PNG等更多格式的图片

## Usage
```
self.imageView = BerryAnimateImage(data, frame: CGRect(x: 0, y: 200, width: self.view.frame.size.width, height: 300), cache: BerryAnimateImage.Policy.noCache)
self.view.addSubview(self.imageView)
self.imageView.contentMode = .scaleAspectFit
self.imageView.animationRepeatCount = 0
```
## Animation control
```
self.imageView.startAnimating()
self.imageView.stopAnimating()
```

## Get real format 
```
static public func getImageFormat(_ data: Data) -> BerryImageFormat 
```

Find image decoder
```
public func FindImageDecoder(with data: Data) -> BerryImageProvider
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

Berry is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:
# **Don't use 'use_frameworks!'**

```ruby
pod 'Berry'
```

### Add fix code 

```
post_install do |installer|
    FixBerryUmbrella()
end


def FixBerryUmbrella
berry_unbrella_file_path = (Dir::pwd + '/Pods/Headers/Public/BerryPlant/BerryPlant-umbrella.h')
File.open(berry_unbrella_file_path,"r:utf-8") do |lines|
    buffer = lines.read
    buffer = buffer.gsub("decode.h","WebP/decode.h")
    buffer = buffer.gsub("encode.h","WebP/encode.h")
    buffer = buffer.gsub("types.h","WebP/types.h")
    File.open(berry_unbrella_file_path,"w"){|l|
    l.write(buffer)
}
end
end
```

## Author

czqasn, czqasn_6@163.com

## License

Berry is available under the MIT license. See the LICENSE file for more info.


