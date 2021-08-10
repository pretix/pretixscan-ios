platform :ios, '12.1'

target 'pretixSCAN' do
  use_frameworks!

  # Pods for PretixScan
  pod 'SwiftMessages', :git => 'https://github.com/SwiftKickMobile/SwiftMessages.git', :branch => 'work/9.0.4', :commit => '7ef6043a9bd7e72308a27ef40645fd6df3942ba2'
  pod 'FMDB'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '7.1.4'

  pre_install do |installer|
    installer.analysis_result.specifications.each do |s|
      s.swift_version = '5.0'
    end
  end

  target 'PretixScanTests' do
    inherit! :search_paths
    # Pods for testing
  end
end
