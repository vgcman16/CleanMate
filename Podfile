project 'CleanMate/CleanMate.xcodeproj'

platform :ios, '18.1'

# Add this at the top level to prevent duplicate frameworks
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true

# Add the Firebase pod for Google Analytics
use_frameworks! :linkage => :static

def shared_pods
  pod 'Firebase/Core', '10.17.0'
  pod 'Firebase/Auth', '10.17.0'
  pod 'Firebase/Firestore', '10.17.0'
  pod 'Firebase/Storage', '10.17.0'
  pod 'Firebase/Messaging', '10.17.0'
  pod 'Stripe', '~> 23.18.0'
  pod 'SDWebImage', '~> 5.18.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.0'
end

target 'CleanMate' do
  shared_pods
  
  # Configuration to prevent duplicate frameworks
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
      end
    end
    
    # Fix for duplicate frameworks
    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.xcconfigs.each do |config_name, config_file|
        config_file.frameworks.clear
        config_file.weak_frameworks.clear
        config_file.libraries.clear
      end
    end
    
    installer.pods_project.targets.each do |target|
      if ['gRPC-Core', 'gRPC-C++', 'BoringSSL-GRPC', 'abseil', 'FirebaseFirestoreInternal'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
      end
    end
  end
end
