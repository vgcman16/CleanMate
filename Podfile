project 'CleanMate/CleanMate.xcodeproj'

platform :ios, '18.1'

# Add this at the top level to prevent duplicate frameworks
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true,
         :generate_multiple_pod_projects => false

target 'CleanMate' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for CleanMate
  pod 'Firebase', '~> 10.29.0'
  pod 'FirebaseCore', '~> 10.29.0'
  pod 'FirebaseAuth', '~> 10.29.0'
  pod 'FirebaseFirestore', '~> 10.29.0'
  pod 'FirebaseStorage', '~> 10.29.0'
  pod 'FirebaseMessaging', '~> 10.29.0'
  pod 'FirebaseCoreInternal', '~> 10.29.0'
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
        config.build_settings['DEFINES_MODULE'] = 'YES'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        
        # Handle gRPC-specific settings
        if target.name.include?('gRPC-Core') || target.name.include?('gRPC-C++')
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GRPC_PUBLIC_HEADERS_ONLY=1'
          config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
          config.build_settings['HEADER_SEARCH_PATHS'] << '"${PODS_ROOT}/Headers/Private/gRPC-Core"'
          config.build_settings['HEADER_SEARCH_PATHS'] << '"${PODS_ROOT}/Headers/Private/gRPC-C++"'
          config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
          config.build_settings['SKIP_INSTALL'] = 'NO'
          config.build_settings['COPY_PHASE_STRIP'] = 'NO'
          config.build_settings['DEFINES_MODULE'] = 'NO' # Disable module definition for gRPC
          
          # Disable header copying for gRPC
          if target.respond_to?(:build_phases)
            target.build_phases.each do |phase|
              if phase.is_a?(Xcodeproj::Project::Object::PBXHeadersBuildPhase)
                phase.files.clear
              end
            end
          end
        end
      end
    end
  end
end
