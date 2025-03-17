source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

target 'GPUImageAdventures' do
  # 外部第三方库
  pod 'GPUImage'
  pod 'Masonry'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end
