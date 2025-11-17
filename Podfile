# Define minimum iOS version to avoid libarclite issues
platform :ios, '12.0'

use_frameworks!

source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/PopcornTimeTV/Specs'

def pods
    pod 'PopcornTorrent'
    pod 'MobileVLCKit'
end

target 'grabber' do
    pods
    pod 'Kanna', :git => 'https://github.com/tid-kijyun/Kanna'
end

# Post install script to fix deployment target issues
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
    end
end

