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

  # Firebase
  pod 'Firebase/Core', '~> 10.29.0'
  pod 'Firebase/Auth', '~> 10.29.0'
  pod 'Firebase/Firestore', '~> 10.29.0'
  pod 'Firebase/Storage', '~> 10.29.0'
  pod 'Firebase/Messaging', '~> 10.29.0'
  
  # UI/UX
  pod 'SDWebImage', '~> 5.18.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.0'
  pod 'lottie-ios', '~> 4.4.0'  # For animations
  pod 'SkeletonView', '~> 1.30.0'  # For loading states
  pod 'SwiftMessages', '~> 9.0.0'  # For in-app notifications
  
  # Payments and Analytics
  pod 'Stripe', '~> 23.18.0'
  pod 'StripePaymentSheet', '~> 23.18.0'
  pod 'StripeApplePay', '~> 23.18.0'
  pod 'Analytics', '~> 4.1.0'  # Segment analytics
  
  # Calendar and Scheduling
  pod 'CalendarKit', '~> 1.1.9'  # For booking interface
  pod 'FSCalendar', '~> 2.8.4'  # For date selection
  
  # Utilities
  pod 'SwiftDate', '~> 7.0.0'  # For date handling
  pod 'PhoneNumberKit', '~> 3.7.0'  # For phone number validation
  pod 'KeychainSwift', '~> 20.0.0'  # For secure credential storage

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.1'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        
        # Handle gRPC-specific settings
        if target.name.include?('gRPC-Core') || target.name.include?('gRPC-C++')
          config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'GRPC_PUBLIC_HEADERS_ONLY=1']
          config.build_settings['USER_HEADER_SEARCH_PATHS'] = '"${PODS_ROOT}/gRPC-Core/include" "${PODS_ROOT}/gRPC-C++/include"'
          config.build_settings['HEADER_SEARCH_PATHS'] = [
            '$(inherited)',
            '"${PODS_ROOT}/gRPC-Core/include"',
            '"${PODS_ROOT}/gRPC-C++/include"'
          ]
          config.build_settings['COPY_PHASE_STRIP'] = 'NO'
          config.build_settings['DEFINES_MODULE'] = 'NO'
          config.build_settings['SKIP_INSTALL'] = 'NO'
          
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
