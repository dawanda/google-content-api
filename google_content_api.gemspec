# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_content_api/version'

Gem::Specification.new do |spec|
  spec.name          = "google_content_api"
  spec.version       = GoogleContentApi::VERSION
  spec.authors       = ["DaWanda GmbH"]
  spec.email         = ["amir@dawanda.com"]
  spec.description   = %q{Gem for interacting with Google's Content API.}
  spec.summary       = %q{Gem for interacting with Google's Content API.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13"
  spec.add_dependency  "google-api-client", "~> 0.4"
  spec.add_dependency  "nokogiri", "~> 1.5"

end
