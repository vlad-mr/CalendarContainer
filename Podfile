source 'git@github.com:Adaptavant/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!(:linkage => :static)
inhibit_all_warnings! 

target 'CalendarContainer' do
  pod 'AnywhereSchedulingEngineModule', :git => 'git@github.com:Adaptavant/Anywhere-IOS-Module.git', :branch => 'appointmentModule/eventModule'
  pod 'AnywhereAppointmentModule', :git => 'git@github.com:Adaptavant/Anywhere-IOS-Module.git', :branch => 'appointmentModule/eventModule'
  pod 'AnywhereCalendarSDK', :git => 'git@github.com:Adaptavant/iOS-Calendar-SDK.git', :branch => 'dev_redesign'
end
