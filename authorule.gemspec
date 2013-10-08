# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authorule/version'

Gem::Specification.new do |spec|
  spec.name          = "authorule"
  spec.version       = Authorule::VERSION
  spec.authors       = ["Joost Lubach"]
  spec.email         = ["joost@yoazt.com"]
  spec.description   = %q[Rule-based programmable permission system.]
  spec.summary       = %q[Rule-based programmable permission system.]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activerecord", "~> 3.2"
  spec.add_development_dependency "rspec", "~> 2.14"
end
