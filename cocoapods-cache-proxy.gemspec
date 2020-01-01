# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-cache-proxy/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-cache-proxy'
  spec.version       = CocoapodsCacheProxy::VERSION
  spec.authors       = ['0x1306a94']
  spec.email         = ['0x1306a94@gmail.com']
  spec.description   = %q{A short description of cocoapods-cache-proxy.}
  spec.summary       = %q{A longer description of cocoapods-cache-proxy.}
  spec.homepage      = 'https://github.com/0x1306a94/cocoapods-cache-proxy'
  spec.license       = 'MIT'

  # spec.files         = `git ls-files`.split($/)
  spec.files         = Dir['lib/**/*.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cocoapods'
  spec.add_dependency 'cocoapods-core'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
