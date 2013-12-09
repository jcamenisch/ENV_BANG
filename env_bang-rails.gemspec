# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'env_bang/version'

Gem::Specification.new do |spec|
  spec.name          = "env_bang-rails"
  spec.version       = ENV_BANG::VERSION
  spec.authors       = ["Jonathan Camenisch"]
  spec.email         = ["jonathan@camenisch.net"]
  spec.summary       = %q{Use ENV! in Rails}
  spec.description   = %q{ENV! provides a thin wrapper around ENV to encourage central, self-documenting configuration and helpful error message.}
  spec.homepage      = "https://github.com/jcamenisch/ENV_BANG"
  spec.license       = "MIT"

  spec.files         = %w[lib/env_bang-rails.rb]
  spec.require_paths = ["lib"]

  spec.add_dependency 'env_bang', ENV_BANG::VERSION
end
