project 'CleanMate/CleanMate.xcodeproj'

platform :ios, '18.1'

# Add this at the top level to prevent duplicate frameworks
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true,
         :generate_multiple_pod_projects => true

def shared_pods
  # Firebase
  pod 'Firebase', '10.17.0'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseMessaging'
  
  # Other dependencies
  pod 'Stripe', '~> 23.18.0'
  pod 'SDWebImage', '~> 5.18.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.0'
end

target 'CleanMate' do
  use_frameworks!
  
  # Pods for CleanMate
  shared_pods
  
  # Fix for duplicate symbols and framework issues
  post_install do |installer|
    installer.pod_target_subprojects.flat_map { |project| project.targets }.each do |target|
      target.build_configurations.each do |config|
        # Set deployment target for all pods
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
        
        # Disable bitcode for all pods
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        
        # Fix for duplicate symbols in gRPC
        if target.name.include?('gRPC') || target.name.include?('Firebase')
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
          config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
          config.build_settings['SKIP_INSTALL'] = 'NO'
        end
        
        # Fix for arm64 architecture
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        
        # Additional build settings
        config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
        config.build_settings['COPY_PHASE_STRIP'] = 'NO'
        config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
      end
    end
    
    # Fix for duplicate file issues
    installer.pods_project.targets.each do |target|
      if target.name.include?('gRPC-Core')
        target.build_phases.each do |phase|
          if phase.is_a?(Xcodeproj::Project::Object::PBXHeadersBuildPhase)
            phase.files.each do |file|
              file.settings ||= {}
              file.settings['ATTRIBUTES'] = ['Private']
            end
          end
        end
      end
    end
  end
end
