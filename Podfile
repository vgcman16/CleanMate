project 'CleanMate/CleanMate.xcodeproj'

platform :ios, '18.1'

# Add this at the top level to prevent duplicate frameworks
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true,
         :generate_multiple_pod_projects => true

target 'CleanMate' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for CleanMate
  pod 'Firebase', '~> 10.17.0'
  pod 'FirebaseCore', '~> 10.17.0'
  pod 'FirebaseAuth', '~> 10.17.0'
  pod 'FirebaseFirestore', '~> 10.17.0'
  pod 'FirebaseStorage', '~> 10.17.0'
  pod 'FirebaseMessaging', '~> 10.17.0'
  pod 'Stripe', '~> 23.18.0'
  pod 'SDWebImage', '~> 5.18.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
        config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        
        # Handle gRPC-specific settings
        if target.name.include?('gRPC-Core') || target.name.include?('gRPC-C++')
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GRPC_PUBLIC_HEADERS_ONLY=1'
          config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
          config.build_settings['HEADER_SEARCH_PATHS'] << '"${PODS_ROOT}/Headers/Public/gRPC-Core"'
          config.build_settings['HEADER_SEARCH_PATHS'] << '"${PODS_ROOT}/Headers/Public/gRPC-C++"'
          
          # Set all headers to private to prevent duplicates
          target.build_phases.each do |phase|
            if phase.is_a?(Xcodeproj::Project::Object::PBXHeadersBuildPhase)
              phase.files.each do |file|
                file.settings ||= {}
                file.settings['ATTRIBUTES'] = ['Private']
              end
            end
          end
          
          # Additional gRPC settings
          config.build_settings['SKIP_INSTALL'] = 'NO'
          config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
          config.build_settings['DEFINES_MODULE'] = 'YES'
          config.build_settings['MODULEMAP_FILE'] = '${PODS_ROOT}/Headers/Public/#{target.name}/#{target.name}.modulemap'
        end
      end
    end
  end
end
