#
# Be sure to run `pod lib lint Berry.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BerryPlant'
    s.version          = '1.0.2'
    s.summary          = 'Image Kit for decode/display WEBP, APNG, PNG, GIF, JPG and more write by swift'
    s.description      = 'A swift image kit for iOS to display/decode WebP,APNG,GIF,PNG,JPG and more.\
    Decode image on async thread and render when runloop idle.'
    s.homepage         = 'https://github.com/czqasngit/BerryPlant'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'czqasn' => 'czqasn_6@163.com' }
    s.source           = { :git => 'https://github.com/czqasngit/BerryPlant.git', :tag => s.version.to_s }
    s.swift_version = '4.0'
    s.ios.deployment_target = '9.0'
    s.libraries = 'z'
    s.source_files = 'BerryPlant/Classes/**/*'
end
