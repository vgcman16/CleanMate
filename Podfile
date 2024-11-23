project 'CleanMate.xcodeproj'

platform :ios, '18.1'

target 'CleanMate' do
  use_frameworks!

  # Firebase - using specific versions known to be compatible
  pod 'Firebase/Core', '10.17.0'
  pod 'Firebase/Auth', '10.17.0'
  pod 'Firebase/Firestore', '10.17.0'
  pod 'Firebase/Storage', '10.17.0'
  pod 'Firebase/Messaging', '10.17.0'
  pod 'FirebaseStorage', '10.17.0'  # Explicit version
  
  # Payment
  pod 'Stripe', '~> 23.18.0'  # Last version before 24.x

  # UI
  pod 'SDWebImage', '~> 5.18.0'  # Last version before 5.20
  pod 'IQKeyboardManagerSwift', '~> 6.5.0'  # More stable version

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
      
      # Fix for 'Create Symlinks to Header Folders' warning
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.framework"
        target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
      
      # Additional build settings
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # Swift compiler flags
      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-Xfrontend -warn-long-expression-type-checking=100']
      
      # Suppress warnings
      config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
