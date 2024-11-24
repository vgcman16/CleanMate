platform :ios, '15.0'
use_frameworks!

project 'CleanMate/CleanMate.xcodeproj'

target 'CleanMate' do
  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  
  # UI
  pod 'IQKeyboardManagerSwift'
  
  # Utilities
  pod 'SwiftLint'

  target 'CleanMateTests' do
    inherit! :search_paths
  end

  target 'CleanMateUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      
      # Fix for duplicate symbols in BoringSSL-GRPC and gRPC-C++
      if target.name.include?('BoringSSL-GRPC') || target.name.include?('gRPC-C++')
        config.build_settings['HEADER_SEARCH_PATHS'] = '$(inherited) ${PODS_ROOT}/BoringSSL-GRPC/src/include ${PODS_ROOT}/gRPC-C++/include'
        config.build_settings['COPY_PHASE_STRIP'] = 'NO'
        config.build_settings['SKIP_INSTALL'] = 'YES'
        config.build_settings['PRESERVE_PATHS'] = '${PODS_ROOT}/**/*.h'
        config.build_settings['EXCLUDED_SOURCE_FILE_NAMES'] = '*.upb.h *.upb_minitable.h'
      end
    end
  end
end
