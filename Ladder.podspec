Pod::Spec.new do |s|

  s.name        = "Ladder"
  s.version     = "0.3.3"
  s.summary     = "Checking app's version on the AppStore or Fir.im every particular time interval"

  s.description = <<-DESC
                  Checking app's version on the AppStore or Fir.im every particular time interval.
                  DESC

  s.homepage    = "https://github.com/Limon-O-O/Ladder"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "Limon" => "fengninglong@gmail.com" }
  s.social_media_url  = "https://twitter.com/Limon______"

  s.ios.deployment_target   = "8.0"
  # s.osx.deployment_target = "10.7"

  s.source          = { :git => "https://github.com/Limon-O-O/Ladder.git", :tag => s.version }
  s.source_files    = "Ladder/*.swift"
  s.requires_arc    = true

end
