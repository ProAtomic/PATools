Pod::Spec.new do |s|
  s.name             = 'PATools'
  s.version          = '0.1.3'
  s.summary          = 'Common tools'
  s.description      = 'Common tools of PA'
  s.homepage         = 'https://proatomicdev.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '942v' => 'gsaenz@proatomicdev.com' }
  s.source           = { :git => 'https://github.com/ProAtomic/PATools.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_versions = '5.1'
  s.source_files = 'PATools/Classes/**/*.{swift}'
  s.dependency 'CocoaLumberjack/Swift'
end
