#
#  Be sure to run `pod spec lint Chester.podspec.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "Chester"
  s.version      = "0.5.0"
  s.summary      = "Chester is a Swift GraphQL query builder."
  s.description  = <<-DESC
                  Work in progress: Simplify building GraphQL queries with Chester.
                   DESC

  s.homepage     = "https://github.com/JanGorman/Chester"
  s.license      = "MIT"

  s.author             = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.social_media_url   = "http://twitter.com/JanGorman"

  s.platform     = :ios, "8.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/JanGorman/Chester.git", :tag => s.version }

  s.source_files  = "Classes", "Chester/*.swift"

end
