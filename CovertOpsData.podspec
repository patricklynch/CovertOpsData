#
# Be sure to run `pod lib lint CovertOpsData.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CovertOpsData'
  s.version          = '0.1.2'
  s.summary          = 'An extension of the `CovertOps` pod which includes a compatible CoreData expansion pack.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The original `CovertOps` framework uses operations from Apple's Foundation framework for achieving precise timing, exclusivity, thread safety, asynchronous behavior and dependency management.  This add-on uses that architecture to create a thread-safe implementation of a CoreData stack that uses operations to read and write from a persistent store.
                       DESC

  s.homepage         = 'https://github.com/patricklynch/CovertOpsData'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'patricklynch' => 'pdlynch@gmail.com' }
  s.source           = { :git => 'https://github.com/patricklynch/CovertOpsData.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
  s.source_files = 'CovertOpsData/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CovertOpsData' => ['CovertOpsData/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'CovertOps'
end
