Pod::Spec.new do |s|
  s.name         = "PFPageView"
  s.version      = "0.0.1"
  s.summary      = "Photo browser"
  s.description  = "A simple iOS photo browser"
  s.homepage     = "https://github.com/pulpfingers/PFPageView"
  s.license      = 'MIT'
  s.author       = { "Jerome Scheer" => "jerome@pulpfingers.com" }
  s.source       = { :git => "git@github.com:pulpfingers/PFPageView.git", :tag => "0.0.1" }
  s.platform     = :ios
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end