# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Muzonchik' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for VKMusic
  pod 'SwiftSoup', :inhibit_warnings => true
  pod 'RMQClient', '~> 0.10.0', :inhibit_warnings => true
  pod 'MGSwipeTableCell', :inhibit_warnings => true
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
