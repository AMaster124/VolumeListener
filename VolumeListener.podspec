#
# Be sure to run `pod lib lint VolumeListener.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VolumeListener'
  s.version          = '0.1.2'
  s.summary          = 'Volume change listener.'
#  s.description      = <<-DESC
#TODO: Use to catch volume change in the both of foreground and background.
#                       DESC

  s.homepage         = 'https://github.com/AMaster124/VolumeListener'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AMaster124' => 'bestfriend1990124@hotmail.com' }
  s.source           = { :git => 'https://github.com/AMaster124/VolumeListener.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.3'
  s.source_files     = "VolumeListener/Classes/**/*"
 
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

#   s.resource_bundles = {
#     'VolumeListener' => ['VolumeListener/Assets/*.png']
#   }
#
#   s.public_header_files = 'Pod/Classes/**/*.h'
#   s.frameworks = 'UIKit', 'AVFoundation', 'CoreLocation'
#   s.dependency 'AFNetworking', '~> 2.3'
end
