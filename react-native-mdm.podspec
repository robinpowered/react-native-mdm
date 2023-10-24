
require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = package['author']
  s.homepage     = "https://github.com/robinpowered/react-native-mdm"
  s.platforms    = { :ios => "12.0", :osx => "10.14" }
  s.source       = { :git => "https://github.com/robinpowered/react-native-mdm.git", :tag => "v#{s.version}" }
  s.source_files  = "ios/**/*.{h,m}"
  s.dependency 'React'
  s.dependency 'AppConfigSettingsFramework'
end
