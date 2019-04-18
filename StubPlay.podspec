Pod::Spec.new do |s|
  s.name             = 'StubPlay'
  s.version          = '0.0.1'
  s.swift_version = '5.0'
  s.summary          = 'Stub http requests. Saves requests and replays them. Handles various http responses and includes text, html, json, videos, and images'
  s.description      = <<-DESC
Mock http requests. Saves requests and replays them. Handles various http responses and includes text, html, json, videos, and images
                       DESC

  s.homepage = 'https://github.com/mokten/StubPlay'
  s.license       = { :type => 'MIT' }
  s.author        = { 'mokten' => 'support@mokten.com' }
  s.source       = { :git => 'https://github.com/mokten/StubPlay.git', :tag => s.version }

  s.ios.deployment_target  = '11.0'
  s.tvos.deployment_target = '11.0'
  s.source_files = 'Source/*.swift'

end
