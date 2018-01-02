Pod::Spec.new do |s|
  s.name         = "Gauges"
  s.version      = "0.0.1"
  s.summary      = "Gauges gives you a nice looking circular progress view."

  s.homepage     = "https://github.com/ilyapuchka/Gauges"
  # s.screenshots  = "https://github.com/ilyapuchka/Gauges/example.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author    = "Ilya Puchka"
  s.social_media_url   = "http://twitter.com/ilyapuchka"

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/ilyapuchka/Gauges.git", :tag => s.version.to_s }

  s.source_files  = "Sources"

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0'
  }

end
