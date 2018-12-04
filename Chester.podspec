Pod::Spec.new do |s|

  s.name         = "Chester"
  s.version      = "0.8.0"
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
  s.swift_version = "4.2"

  s.source       = { :git => "https://github.com/JanGorman/Chester.git", :tag => s.version }

  s.source_files  = "Classes", "Sources/Chester/*.swift"

end
