# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'env_bang/version'

Gem::Specification.new do |spec|
  spec.name          = "env_bang"
  spec.version       = ENV_BANG::VERSION
  spec.authors       = ["Jonathan Camenisch"]
  spec.email         = ["jonathan@camenisch.net"]
  spec.summary       = %q{Do a bang-up job managing your environment variables}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.1"
end
