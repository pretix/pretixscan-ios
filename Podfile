platform :ios, '12.1'

target 'PretixScan' do
  use_frameworks!

  # Pods for PretixScan
  pod 'SwiftMessages', :inhibit_warnings => true
  pod 'FMDB'

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
