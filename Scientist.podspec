Pod::Spec.new do |spec|
  spec.name         = 'Scientist'
  spec.version      = '0.4.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/junkpiano/scientist'
  spec.authors      = { 'Yusuke Ohashi' => 'github@junkpiano.me' }
  spec.summary      = 'A Swift library for carefully refactoring critical paths.'
  spec.source       = { :git => 'https://github.com/junkpiano/scientist.git', :tag => spec.version.to_s }
  spec.source_files = 'Sources/**/*.swift'

  spec.swift_versions = ['5.3', '5.4', '5.5']
  spec.ios.deployment_target  = '10.0'
  spec.osx.deployment_target = '10.12'
  spec.tvos.deployment_target = '10.0'
  spec.watchos.deployment_target = '3.0'  
end
