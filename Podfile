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
    pod 'Kanna', '~> 5.2.0'
end

# Post install script to fix deployment target and Swift module issues
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
            
            # Fix Swift module compilation issues
            if target.name == 'Kanna'
                config.build_settings['SWIFT_VERSION'] = '5.0'
                config.build_settings['DEFINES_MODULE'] = 'YES'
                config.build_settings['SWIFT_INSTALL_OBJC_HEADER'] = 'YES'
                config.build_settings['SWIFT_OBJC_INTERFACE_HEADER_NAME'] = '$(SWIFT_MODULE_NAME)-Swift.h'
            end
        end
    end
end

