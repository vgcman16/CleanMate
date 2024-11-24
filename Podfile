project 'CleanMate/CleanMate.xcodeproj'

platform :ios, '18.1'

# Add this at the top level to prevent duplicate frameworks
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true

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
  use_frameworks! :linkage => :static
  
  # Pods for CleanMate
  shared_pods
  
  # Fix for duplicate symbols and framework issues
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # Set deployment target for all pods
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
        
        # Disable bitcode for all pods
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        
        # Fix for duplicate symbols in gRPC
        if target.name.include?('gRPC') || target.name.include?('Firebase')
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
        
        # Fix for arm64 architecture
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        
        # Framework build settings
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
        config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
        config.build_settings['SKIP_INSTALL'] = 'NO'
        config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        
        # Fix script phase warnings
        target.build_phases.each do |build_phase|
          if build_phase.respond_to?(:name)
            if ['[CP] Copy XCFrameworks', '[CP] Copy Pods Resources'].include?(build_phase.name)
              build_phase.always_out_of_date = "1"
            end
            if build_phase.respond_to?(:output_paths)
              build_phase.output_paths ||= []
              build_phase.output_paths.uniq!
            end
          end
        end
      end
      
      # Special handling for gRPC
      if ['gRPC-Core', 'gRPC-C++'].include? target.name
        target.build_phases.each do |build_phase|
          if build_phase.respond_to?(:name) && build_phase.name == 'Create Symlinks to Header Folders'
            build_phase.always_out_of_date = "1"
          end
        end
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
    
    # Special handling for problematic frameworks
    installer.pods_project.targets.each do |target|
      if ['gRPC-Core', 'gRPC-C++', 'BoringSSL-GRPC', 'abseil', 'FirebaseFirestoreInternal'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          config.build_settings['ENABLE_BITCODE'] = 'NO'
          config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1']
          config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
          config.build_settings['COPY_PHASE_STRIP'] = 'NO'
          config.build_settings['SKIP_INSTALL'] = 'NO'
          config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
          config.build_settings['FRAMEWORK_SEARCH_PATHS'] = ['$(inherited)', '$(PODS_ROOT)', '$(PODS_CONFIGURATION_BUILD_DIR)']
        end
      end
    end
  end
end
