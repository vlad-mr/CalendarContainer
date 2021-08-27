source 'git@github.com:Adaptavant/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
install! 'cocoapods', :disable_input_output_paths => true
use_frameworks!
inhibit_all_warnings! 

target 'CalendarContainer' do
  pod 'AnywhereSchedulingEngineModule', :git => 'git@github.com:Adaptavant/Anywhere-IOS-Module.git', :branch => 'appointmentModule/eventModuleCopy'
  pod 'AnywhereAppointmentModule', :git => 'git@github.com:Adaptavant/Anywhere-IOS-Module.git', :branch => 'appointmentModule/eventModuleCopy'
  # pod 'AnywhereCalendarSDK', :git => 'git@github.com:Adaptavant/iOS-Calendar-SDK.git', :branch => 'dev_redesign'
end

target 'CalendarSDK' do
  use_frameworks!(:linkage => :static)
  pod 'SwiftDate', :git => 'https://github.com/Vignesh-Thangamariappan/SwiftDate.git'
  pod 'InterfaceModule'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

